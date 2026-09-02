<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContentController;
use App\Http\Controllers\Api\DirectMessageController;
use App\Http\Controllers\Api\FriendController;
use App\Http\Controllers\Api\GiftController;
use App\Http\Controllers\Api\GameRequestController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\RankingController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\RoomInvitationController;
use App\Http\Controllers\Api\RoomRewardController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\SpyGameController;
use App\Http\Controllers\Api\TruthOrDareController;
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
    Route::get('/rankings', RankingController::class);
    Route::get('/search', SearchController::class)->middleware('throttle:60,1');
    Route::get('/gifts', [GiftController::class, 'index']);
    Route::post('/rooms/{room}/gifts/{gift}', [GiftController::class, 'send'])->middleware('throttle:30,1');
    Route::get('/rooms/{room}/reward', [RoomRewardController::class, 'show']);
    Route::post('/rooms/{room}/reward', [RoomRewardController::class, 'claim'])->middleware('throttle:10,1');
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/read-all', [NotificationController::class, 'readAll']);
    Route::patch('/notifications/{notification}', [NotificationController::class, 'read']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/rooms', [RoomController::class, 'index']);
    Route::post('/rooms', [RoomController::class, 'store'])->middleware('throttle:10,1');
    Route::get('/rooms/{room}', [RoomController::class, 'show']);
    Route::post('/rooms/{room}/join', [RoomController::class, 'join']);
    Route::delete('/rooms/{room}/leave', [RoomController::class, 'leave']);
    Route::put('/rooms/{room}/seats/{position}', [RoomController::class, 'takeSeat']);
    Route::delete('/rooms/{room}/seat', [RoomController::class, 'leaveSeat']);
    Route::patch('/rooms/{room}/microphone', [RoomController::class, 'microphone']);
    Route::patch('/rooms/{room}/seats/{position}/lock', [RoomController::class, 'lockSeat']);
    Route::delete('/rooms/{room}/members/{user:public_id}', [RoomController::class, 'removeMember'])->withoutScopedBindings();
    Route::post('/rooms/{room}/bans/{user:public_id}', [RoomController::class, 'banMember'])->withoutScopedBindings();
    Route::get('/rooms/{room}/bans', [RoomController::class, 'bans']);
    Route::delete('/rooms/{room}/bans/{user:public_id}', [RoomController::class, 'unban'])->withoutScopedBindings();
    Route::patch('/rooms/{room}/settings', [RoomController::class, 'updateSettings']);
    Route::delete('/rooms/{room}', [RoomController::class, 'close']);
    Route::get('/rooms/{room}/messages', [RoomController::class, 'messages']);
    Route::post('/rooms/{room}/messages', [RoomController::class, 'sendMessage'])->middleware('throttle:60,1');
    Route::post('/rooms/{room}/game-requests', [GameRequestController::class, 'store'])->middleware('throttle:10,1');
    Route::get('/rooms/{room}/game-requests/pending', [GameRequestController::class, 'pending']);
    Route::patch('/game-requests/{gameRequest}', [GameRequestController::class, 'respond']);
    Route::get('/users/search', [DirectMessageController::class, 'search']);
    Route::get('/profiles/{user:public_id}', [ProfileController::class, 'show']);
    Route::patch('/profile', [ProfileController::class, 'update']);
    Route::get('/profile/blocked-users', [ProfileController::class, 'blocked']);
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
    Route::get('/rooms/{room}/games/truth-or-dare', [TruthOrDareController::class, 'show']);
    Route::post('/rooms/{room}/games/truth-or-dare', [TruthOrDareController::class, 'store']);
    Route::post('/game-sessions/{session}/start', [TruthOrDareController::class, 'start']);
    Route::post('/game-sessions/{session}/choose', [TruthOrDareController::class, 'choose']);
    Route::post('/game-sessions/{session}/next', [TruthOrDareController::class, 'next']);
    Route::post('/game-sessions/{session}/finish', [TruthOrDareController::class, 'finish']);
    Route::get('/rooms/{room}/games/spy', [SpyGameController::class, 'show']);
    Route::post('/rooms/{room}/games/spy', [SpyGameController::class, 'store']);
    Route::post('/spy-game-sessions/{session}/start', [SpyGameController::class, 'start']);
    Route::post('/spy-game-sessions/{session}/reveal', [SpyGameController::class, 'reveal']);
    Route::get('/conversations', [DirectMessageController::class, 'index']);
    Route::post('/conversations', [DirectMessageController::class, 'store']);
    Route::get('/conversations/{conversation}', [DirectMessageController::class, 'show']);
    Route::post('/conversations/{conversation}/messages', [DirectMessageController::class, 'send'])->middleware('throttle:60,1');
});
