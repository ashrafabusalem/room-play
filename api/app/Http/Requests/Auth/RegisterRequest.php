<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * These mirror the checks the Flutter app runs, but they are the ones that
     * actually matter — the client rules are a courtesy, trivially bypassed.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:3', 'max:32'],
            'email' => [
                'required',
                'string',
                'email:rfc',
                'max:255',
                'unique:users,email',
            ],
            // Length only, matching the app's 8-character rule. Composition
            // rules (a symbol, a digit, a capital) push people toward
            // predictable substitutions; length is what actually helps.
            'password' => ['required', 'string', Password::min(8)],
            'device_name' => ['sometimes', 'string', 'max:60'],
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'email' => is_string($this->email)
                ? strtolower(trim($this->email))
                : $this->email,
            'name' => is_string($this->name) ? trim($this->name) : $this->name,
        ]);
    }
}
