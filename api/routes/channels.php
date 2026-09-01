<?php

use Illuminate\Support\Facades\Broadcast;
use App\Models\Room;
use App\Models\RoomMember;

Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});

Broadcast::channel('user.{id}', fn ($user, $id) => $user->public_id === (string) $id);

Broadcast::channel('room.{publicId}', function ($user, string $publicId) {
    $room = Room::where('public_id', $publicId)->whereNull('closed_at')->first();
    if (! $room || ! RoomMember::where('room_id', $room->id)->where('user_id', $user->id)->exists()) {
        return false;
    }

    return [
        'id' => $user->public_id,
        'name' => $user->name,
        'level' => $user->level,
    ];
});
