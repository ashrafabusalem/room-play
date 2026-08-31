<?php

namespace App\Http\Requests\Auth;

use App\Models\User;
use Illuminate\Auth\Events\Lockout;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class LoginRequest extends FormRequest
{
    /** Attempts allowed per email + IP before the pair is locked out. */
    private const MAX_ATTEMPTS = 5;

    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            // No length rule here on purpose. Applying the registration rules
            // to a login would tell an attacker that a short guess was not even
            // worth checking, and would lock out anyone whose password predates
            // a rule change.
            'password' => ['required', 'string'],
            'device_name' => ['sometimes', 'string', 'max:60'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => is_string($this->email)
                ? strtolower(trim($this->email))
                : $this->email,
        ]);
    }

    /**
     * Verify the credentials and return the user.
     *
     * Deliberately not `Auth::attempt()`: that boots a session, which a
     * token-authenticated API has no use for.
     *
     * @throws ValidationException
     */
    public function authenticate(): User
    {
        $this->ensureIsNotRateLimited();

        $user = User::where('email', $this->string('email'))->first();

        if (! $user || ! Hash::check((string) $this->string('password'), $user->password)) {
            RateLimiter::hit($this->throttleKey());

            // One message for "no such account" and for "wrong password".
            // Telling them apart turns this endpoint into a way to discover
            // which email addresses are registered.
            throw ValidationException::withMessages([
                'email' => __('auth.failed'),
            ]);
        }

        if ($user->blocked_at) {
            RateLimiter::hit($this->throttleKey());

            throw ValidationException::withMessages([
                'email' => __('auth.failed'),
            ]);
        }

        RateLimiter::clear($this->throttleKey());

        return $user;
    }

    /**
     * @throws ValidationException
     */
    protected function ensureIsNotRateLimited(): void
    {
        if (! RateLimiter::tooManyAttempts($this->throttleKey(), self::MAX_ATTEMPTS)) {
            return;
        }

        event(new Lockout($this));

        $seconds = RateLimiter::availableIn($this->throttleKey());

        throw ValidationException::withMessages([
            'email' => __('auth.throttle', [
                'seconds' => $seconds,
                'minutes' => ceil($seconds / 60),
            ]),
        ]);
    }

    /**
     * Keyed on email *and* IP. Email alone lets anyone lock a victim out of
     * their own account; IP alone lets one attacker spray many accounts.
     */
    protected function throttleKey(): string
    {
        return Str::transliterate(
            Str::lower((string) $this->string('email')).'|'.$this->ip()
        );
    }
}
