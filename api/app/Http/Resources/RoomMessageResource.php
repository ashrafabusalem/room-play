<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RoomMessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'type' => $this->type,
            'text' => $this->body,
            'created_at' => $this->created_at?->toISOString(),
            'sender' => $this->user ? [
                'id' => $this->user->public_id,
                'name' => $this->user->name,
                'level' => $this->user->level,
                'avatar_url' => $this->user->avatarUrl(),
                'is_host' => $this->user_id === $this->room->host_user_id,
            ] : null,
        ];
    }
}
