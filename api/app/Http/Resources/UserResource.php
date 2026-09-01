<?php

namespace App\Http\Resources;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * The single definition of what a user looks like on the wire.
 *
 * Everything the app needs and nothing it doesn't — no timestamps, no
 * `email_verified_at`, and never the password hash. Adding a field here is a
 * deliberate act, which is what stops internal columns leaking by accident.
 *
 * @mixin User
 */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->public_id,
            'name' => $this->name,
            'email' => $this->email,
            'level' => $this->level,
            'bio' => $this->bio,
            'avatar_url' => $this->avatarUrl(),
            'dm_privacy' => $this->dm_privacy,
            'followers_count' => $this->followers()->count(),
            'following_count' => $this->following()->count(),
            'coin_balance' => $this->wallet?->balance ?? 0,
        ];
    }
}
