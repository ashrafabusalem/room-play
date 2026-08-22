<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class ForgotPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Note there is no `exists:users` rule. Rejecting an unknown address would
     * confirm which emails have accounts — the endpoint answers the same way
     * either way, and the controller does the same.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
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
}
