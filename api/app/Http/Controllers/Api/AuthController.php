<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;

/**
 * Token auth for the Flutter app.
 *
 * The response shape is fixed: `{ token, user }` on success. The app's
 * `AuthController` already expects exactly this.
 */
class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create($request->safe()->only(['name', 'email', 'password']));

        return response()->json([
            'token' => $user->createToken(
                User::tokenName($request->input('device_name'))
            )->plainTextToken,
            'user' => new UserResource($user),
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        // Throws a 422 on bad credentials or too many attempts.
        $user = $request->authenticate();

        return response()->json([
            'token' => $user->createToken(
                User::tokenName($request->input('device_name'))
            )->plainTextToken,
            'user' => new UserResource($user),
        ]);
    }

    /**
     * Revoke only the token that made this request, so signing out on a phone
     * does not sign the user out everywhere else.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Signed out.']);
    }

    /**
     * Wrapped in `user` rather than returned as a bare resource, which would
     * arrive as `{ "data": ... }` — every endpoint here answers with the same
     * key so the client never has to special-case one of them.
     */
    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => new UserResource($request->user()),
        ]);
    }

    /**
     * Always reports success, whether or not the address has an account.
     *
     * Anything else turns this into an account-enumeration endpoint: send an
     * address, read the response, learn whether that person is a user. The mail
     * either goes out or it doesn't; the caller cannot tell.
     */
    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        Password::sendResetLink($request->safe()->only('email'));

        return response()->json([
            'message' => 'If that email has an account, a reset link is on its way.',
        ]);
    }
}
