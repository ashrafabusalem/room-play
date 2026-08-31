<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Validation\Rules\Password;
use Illuminate\View\View;

class AuthController extends Controller
{
    public function create(): View
    {
        return view('admin.auth.login');
    }

    public function store(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);
        $email = strtolower(trim($credentials['email']));
        $key = 'admin-login:'.$email.'|'.$request->ip();

        if (RateLimiter::tooManyAttempts($key, 5)) {
            return back()->withErrors(['email' => 'Too many attempts. Try again later.'])->onlyInput('email');
        }

        $user = User::where('email', $email)->first();

        if (! $user || ! $user->is_admin || $user->blocked_at || ! Hash::check($credentials['password'], $user->password)) {
            RateLimiter::hit($key, 60);

            return back()->withErrors(['email' => 'The provided credentials are incorrect.'])->onlyInput('email');
        }

        RateLimiter::clear($key);
        Auth::login($user, $request->boolean('remember'));
        $request->session()->regenerate();

        AdminAudit::create([
            'admin_id' => $user->id,
            'action' => 'admin.login',
            'target_type' => User::class,
            'target_id' => $user->id,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return redirect()->intended(route('admin.dashboard'));
    }

    public function destroy(Request $request): RedirectResponse
    {
        AdminAudit::create([
            'admin_id' => $request->user()->id,
            'action' => 'admin.logout',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }

    public function password(): View
    {
        return view('admin.auth.password');
    }

    public function updatePassword(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'current_password'],
            'password' => ['required', 'confirmed', Password::min(10)->letters()->numbers()],
        ]);
        $request->user()->forceFill([
            'password' => $data['password'],
            'must_change_password' => false,
        ])->save();
        $request->session()->regenerate();

        AdminAudit::create([
            'admin_id' => $request->user()->id,
            'action' => 'admin.password_changed',
            'target_type' => User::class,
            'target_id' => $request->user()->id,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return back()->with('success', 'Your password has been changed.');
    }
}
