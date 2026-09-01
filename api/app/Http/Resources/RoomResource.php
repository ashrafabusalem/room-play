<?php

namespace App\Http\Resources;

use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Room */
class RoomResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $this->loadMissing(['host.wallet', 'members.user.wallet', 'seats.user.wallet']);

        return [
            'id' => $this->public_id,
            'name' => $this->name,
            'language' => $this->language,
            'tag' => $this->tag,
            'member_count' => $this->members->count(),
            'max_members' => $this->max_members,
            'is_locked' => $this->is_locked,
            'is_closed' => $this->closed_at !== null,
            'is_featured' => $this->is_featured,
            'host' => $this->user($this->host, true),
            'members' => $this->members->take(8)->map(fn ($member) => $this->user($member->user, $member->role === 'host'))->values(),
            'seats' => $this->seats->map(fn ($seat) => [
                'position' => $seat->position,
                'is_locked' => $seat->is_locked,
                'mic_muted' => $seat->mic_muted,
                'user' => $seat->user ? $this->user($seat->user, $seat->user_id === $this->host_user_id) : null,
            ])->values(),
        ];
    }

    private function user($user, bool $isHost): array
    {
        return ['id' => $user->public_id, 'name' => $user->name, 'level' => $user->level, 'avatar_url' => $user->avatarUrl(), 'coins' => $user->wallet?->balance ?? 0, 'is_host' => $isHost];
    }
}
