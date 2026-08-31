@extends('admin.layout')
@section('title', 'Change password')
@section('heading', 'Change password')
@section('content')
<div class="max-w-xl">
    @if(auth()->user()->must_change_password)<div class="mb-6 rounded-2xl border border-[#f6810d]/40 bg-[#f6810d]/10 p-4 text-sm text-[#ffb35b]">You are using a temporary password. Replace it now with a private password.</div>@endif
    @if($errors->any())<div class="mb-6 rounded-2xl border border-[#e5484d]/40 bg-[#e5484d]/10 p-4 text-sm text-[#ff8589]">{{ $errors->first() }}</div>@endif
    <section class="admin-card"><h2 class="text-lg font-bold">Secure your admin account</h2><p class="mt-2 text-sm text-[#9ca3ae]">Use at least 10 characters with letters and numbers.</p>
        <form method="POST" action="{{ route('admin.password.update') }}" class="mt-6 space-y-5">@csrf @method('PUT')
            <label class="block"><span class="admin-label">Current password</span><input class="admin-input" type="password" name="current_password" required autocomplete="current-password"></label>
            <label class="block"><span class="admin-label">New password</span><input class="admin-input" type="password" name="password" required autocomplete="new-password"></label>
            <label class="block"><span class="admin-label">Confirm new password</span><input class="admin-input" type="password" name="password_confirmation" required autocomplete="new-password"></label>
            <button class="admin-primary">Update password</button>
        </form>
    </section>
</div>
@endsection
