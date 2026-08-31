<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContentController;
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
    Route::post('/logout', [AuthController::class, 'logout']);
});
