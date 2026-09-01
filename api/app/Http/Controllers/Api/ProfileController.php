<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Models\UserReport;
use App\Models\FriendRequest;
use App\Services\InAppNotifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    public function show(Request $request, User $user): JsonResponse
    {
        $viewer = $request->user();
        abort_if($user->blocked_at || $user->trashed(), 404);

        return response()->json(['profile' => $this->profile($user, $viewer)]);
    }

    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'min:2', 'max:80'],
            'bio' => ['nullable', 'string', 'max:240'],
            'dm_privacy' => ['sometimes', Rule::in(['everyone', 'followers', 'nobody'])],
            'avatar' => ['sometimes', 'nullable', 'image', 'max:4096'],
        ]);
        $user = $request->user();
        if ($request->hasFile('avatar')) {
            $data['avatar_path'] = $request->file('avatar')->store('avatars', 'public');
        }
        unset($data['avatar']);
        $user->forceFill($data)->save();

        return response()->json(['user' => new UserResource($user->refresh())]);
    }

    public function avatar(Request $request): JsonResponse
    {
        $request->validate(['avatar' => ['required', 'image', 'max:4096']]);
        $user = $request->user();
        $oldPath = $user->avatar_path;
        $user->forceFill([
            'avatar_path' => $request->file('avatar')->store('avatars', 'public'),
        ])->save();
        if ($oldPath) Storage::disk('public')->delete($oldPath);

        return response()->json(['user' => new UserResource($user->refresh())]);
    }

    public function follow(Request $request, User $user): JsonResponse
    {
        $viewer = $request->user();
        abort_if($viewer->is($user), 422, 'You cannot follow yourself.');
        abort_if($this->blockedEitherWay($viewer, $user), 403, 'This profile is unavailable.');
        $changes = $viewer->following()->syncWithoutDetaching([$user->id]);
        if ($changes['attached']) app(InAppNotifier::class)->send($user, 'new_follower', $viewer, ['user_id'=>$viewer->public_id]);
        return response()->json(['profile' => $this->profile($user, $viewer)]);
    }

    public function unfollow(Request $request, User $user): JsonResponse
    {
        $request->user()->following()->detach($user->id);
        return response()->json(['profile' => $this->profile($user, $request->user())]);
    }

    public function block(Request $request, User $user): JsonResponse
    {
        $viewer = $request->user();
        abort_if($viewer->is($user), 422, 'You cannot block yourself.');
        DB::transaction(function () use ($viewer, $user) {
            $viewer->blockedUsers()->syncWithoutDetaching([$user->id]);
            DB::table('user_follows')->where(fn ($q) => $q
                ->where(['follower_id' => $viewer->id, 'followed_id' => $user->id])
                ->orWhere(['follower_id' => $user->id, 'followed_id' => $viewer->id]))->delete();
            DB::table('friend_requests')->where(fn ($q) => $q
                ->where(['requester_id' => $viewer->id, 'addressee_id' => $user->id])
                ->orWhere(['requester_id' => $user->id, 'addressee_id' => $viewer->id]))->delete();
        });
        return response()->json(['message' => 'User blocked.']);
    }

    public function unblock(Request $request, User $user): JsonResponse
    {
        $request->user()->blockedUsers()->detach($user->id);
        return response()->json(['message' => 'User unblocked.']);
    }

    public function blocked(Request $request): JsonResponse
    {
        $users = $request->user()->blockedUsers()->latest('user_blocks.created_at')->get();

        return response()->json(['users' => $users->map(fn (User $user) => [
            'id' => $user->public_id,
            'name' => $user->name,
            'avatar_url' => $user->avatarUrl(),
        ])->values()]);
    }

    public function report(Request $request, User $user): JsonResponse
    {
        abort_if($request->user()->is($user), 422, 'You cannot report yourself.');
        $data = $request->validate([
            'reason' => ['required', Rule::in(['harassment', 'spam', 'impersonation', 'inappropriate', 'other'])],
            'details' => ['nullable', 'string', 'max:1000'],
        ]);
        UserReport::create([...$data, 'reporter_id' => $request->user()->id, 'reported_id' => $user->id]);
        return response()->json(['message' => 'Report submitted.'], 201);
    }

    private function profile(User $user, User $viewer): array
    {
        $friendship = FriendRequest::where(fn ($q) => $q
            ->where(['requester_id' => $viewer->id, 'addressee_id' => $user->id])
            ->orWhere(['requester_id' => $user->id, 'addressee_id' => $viewer->id]))->first();
        return [
            'id' => $user->public_id, 'name' => $user->name, 'level' => $user->level,
            'bio' => $user->bio, 'avatar_url' => $user->avatarUrl(),
            'followers_count' => $user->followers()->count(), 'following_count' => $user->following()->count(),
            'is_me' => $viewer->is($user),
            'is_following' => $viewer->following()->whereKey($user->id)->exists(),
            'is_blocked' => $viewer->blockedUsers()->whereKey($user->id)->exists(),
            'blocked_by' => $user->blockedUsers()->whereKey($viewer->id)->exists(),
            'dm_privacy' => $viewer->is($user) ? $user->dm_privacy : null,
            'friendship_status' => $friendship?->status,
            'friend_request_direction' => $friendship?->status === 'pending'
                ? ($friendship->requester_id === $viewer->id ? 'sent' : 'received') : null,
            'coin_balance' => $viewer->is($user) ? ($user->wallet?->balance ?? 0) : null,
        ];
    }

    private function blockedEitherWay(User $one, User $two): bool
    {
        return DB::table('user_blocks')->where(fn ($q) => $q
            ->where(['blocker_id' => $one->id, 'blocked_id' => $two->id])
            ->orWhere(['blocker_id' => $two->id, 'blocked_id' => $one->id]))->exists();
    }
}
