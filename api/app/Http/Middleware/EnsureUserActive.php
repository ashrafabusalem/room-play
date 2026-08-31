<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserActive
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->blocked_at || $request->user()?->trashed()) {
            $request->user()?->tokens()->delete();

            return new JsonResponse(['message' => 'This account is unavailable.'], 403);
        }

        return $next($request);
    }
}
