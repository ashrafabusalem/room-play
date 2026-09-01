<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FriendRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FriendController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $id = $request->user()->id;
        $rows = FriendRequest::where('status', 'accepted')
            ->where(fn ($q) => $q->where('requester_id', $id)->orWhere('addressee_id', $id))
            ->with(['requester', 'addressee'])->latest('responded_at')->get();
        return response()->json(['friends' => $rows->map(function ($row) use ($id) {
            $user = $row->requester_id === $id ? $row->addressee : $row->requester;
            return $this->user($user);
        })->values()]);
    }

    public function requests(Request $request): JsonResponse
    {
        $rows = FriendRequest::where('addressee_id', $request->user()->id)->where('status', 'pending')->with('requester')->latest()->get();
        return response()->json(['requests' => $rows->map(fn ($row) => [
            'id' => (string) $row->id, 'user' => $this->user($row->requester), 'created_at' => $row->created_at->toISOString(),
        ])->values()]);
    }

    public function followers(Request $request): JsonResponse
    {
        return response()->json(['users' => $request->user()->followers()->latest('user_follows.created_at')->get()->map(fn ($u) => $this->user($u))->values()]);
    }

    public function following(Request $request): JsonResponse
    {
        return response()->json(['users' => $request->user()->following()->latest('user_follows.created_at')->get()->map(fn ($u) => $this->user($u))->values()]);
    }

    public function store(Request $request, User $user): JsonResponse
    {
        $me = $request->user();
        abort_if($me->is($user), 422, 'You cannot add yourself.');
        abort_if(DB::table('user_blocks')->where(fn ($q) => $q->where(['blocker_id' => $me->id, 'blocked_id' => $user->id])->orWhere(['blocker_id' => $user->id, 'blocked_id' => $me->id]))->exists(), 403);
        $existing = FriendRequest::where(fn ($q) => $q
            ->where(['requester_id' => $me->id, 'addressee_id' => $user->id])
            ->orWhere(['requester_id' => $user->id, 'addressee_id' => $me->id]))->first();
        abort_if($existing?->status === 'accepted', 409, 'You are already friends.');
        abort_if($existing?->status === 'pending', 409, 'A friend request already exists.');
        if ($existing) $existing->delete();
        $friendRequest = FriendRequest::create(['requester_id' => $me->id, 'addressee_id' => $user->id]);
        return response()->json(['request_id' => (string) $friendRequest->id], 201);
    }

    public function respond(Request $request, FriendRequest $friendRequest): JsonResponse
    {
        abort_unless($friendRequest->addressee_id === $request->user()->id && $friendRequest->status === 'pending', 403);
        $data = $request->validate(['accept' => ['required', 'boolean']]);
        $friendRequest->update(['status' => $data['accept'] ? 'accepted' : 'declined', 'responded_at' => now()]);
        return response()->json(['message' => $data['accept'] ? 'Friend request accepted.' : 'Friend request declined.']);
    }

    public function destroy(Request $request, User $user): JsonResponse
    {
        FriendRequest::where('status', 'accepted')->where(fn ($q) => $q
            ->where(['requester_id' => $request->user()->id, 'addressee_id' => $user->id])
            ->orWhere(['requester_id' => $user->id, 'addressee_id' => $request->user()->id]))->delete();
        return response()->json(['message' => 'Friend removed.']);
    }

    private function user(User $user): array
    {
        return ['id' => $user->public_id, 'name' => $user->name, 'level' => $user->level, 'avatar_url' => $user->avatarUrl()];
    }
}
