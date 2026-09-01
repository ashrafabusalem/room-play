<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\DirectMessageController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\FriendController;
use App\Http\Controllers\Api\RoomInvitationController;
use App\Http\Controllers\Api\WalletController;
use Illuminate\Support\Facades\Route;

/*
| Room Play API
|
| Everything here is prefixed with /api by the framework. Auth is Sanctum
| personal access tokens — the Flutter app sends `Authorization: Bearer <token>`.
*/

Route::post('/register', [AuthController::class, 'register'])
    // Coarse per-IP cap on account creation. The login endpoint has its own,
    // tighter, per-email limiter inside LoginRequest.
    ->middleware('throttle:10,1');

Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:20,1');

Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])
    // Sending mail is expensive and abusable, so this one is deliberately tight.
    ->middleware('throttle:5,1');

Route::get('/content', ContentController::class)->middleware('throttle:120,1');

Route::middleware(['auth:sanctum', 'active'])->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/wallet', WalletController::class);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/rooms', [RoomController::class, 'index']);
    Route::post('/rooms', [RoomController::class, 'store'])->middleware('throttle:10,1');
    Route::get('/rooms/{room}', [RoomController::class, 'show']);
    Route::post('/rooms/{room}/join', [RoomController::class, 'join']);
    Route::delete('/rooms/{room}/leave', [RoomController::class, 'leave']);
    Route::put('/rooms/{room}/seats/{position}', [RoomController::class, 'takeSeat']);
    Route::delete('/rooms/{room}/seat', [RoomController::class, 'leaveSeat']);
    Route::patch('/rooms/{room}/microphone', [RoomController::class, 'microphone']);
    Route::get('/rooms/{room}/messages', [RoomController::class, 'messages']);
    Route::post('/rooms/{room}/messages', [RoomController::class, 'sendMessage'])->middleware('throttle:60,1');
    Route::get('/users/search', [DirectMessageController::class, 'search']);
    Route::get('/profiles/{user:public_id}', [ProfileController::class, 'show']);
    Route::patch('/profile', [ProfileController::class, 'update']);
    Route::post('/profile/avatar', [ProfileController::class, 'avatar'])->middleware('throttle:10,1');
    Route::post('/profiles/{user:public_id}/follow', [ProfileController::class, 'follow']);
    Route::delete('/profiles/{user:public_id}/follow', [ProfileController::class, 'unfollow']);
    Route::post('/profiles/{user:public_id}/block', [ProfileController::class, 'block']);
    Route::delete('/profiles/{user:public_id}/block', [ProfileController::class, 'unblock']);
    Route::post('/profiles/{user:public_id}/reports', [ProfileController::class, 'report'])->middleware('throttle:10,1');
    Route::get('/social/followers', [FriendController::class, 'followers']);
    Route::get('/social/following', [FriendController::class, 'following']);
    Route::get('/friends', [FriendController::class, 'index']);
    Route::get('/friend-requests', [FriendController::class, 'requests']);
    Route::post('/friend-requests/{user:public_id}', [FriendController::class, 'store'])->middleware('throttle:20,1');
    Route::patch('/friend-requests/{friendRequest}', [FriendController::class, 'respond']);
    Route::delete('/friends/{user:public_id}', [FriendController::class, 'destroy']);
    Route::get('/room-invitations', [RoomInvitationController::class, 'index']);
    Route::post('/rooms/{room}/invitations/{user:public_id}', [RoomInvitationController::class, 'store'])->withoutScopedBindings()->middleware('throttle:30,1');
    Route::patch('/room-invitations/{invitation}', [RoomInvitationController::class, 'respond']);
    Route::get('/conversations', [DirectMessageController::class, 'index']);
    Route::post('/conversations', [DirectMessageController::class, 'store']);
    Route::get('/conversations/{conversation}', [DirectMessageController::class, 'show']);
    Route::post('/conversations/{conversation}/messages', [DirectMessageController::class, 'send'])->middleware('throttle:60,1');
});
