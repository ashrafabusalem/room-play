@extends('admin.layout')
@php($editing = $managedUser->exists)
@section('title', $editing ? 'Manage user' : 'Add user')
@section('heading', $editing ? 'Manage user' : 'Add user')
@section('content')
<div class="mb-5"><a class="text-sm text-[#9ca3ae] hover:text-white" href="{{ route('admin.users.index') }}">← Back to users</a></div>
@if($errors->any())<div class="mb-6 rounded-2xl border border-[#e5484d]/40 bg-[#e5484d]/10 p-4 text-sm text-[#ff8589]"><ul class="list-disc pl-5">@foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></div>@endif
<div class="grid gap-6 xl:grid-cols-[1fr_380px]">
    <section class="admin-card">
        <div class="mb-6 flex items-center justify-between"><div><h2 class="text-lg font-bold">Account details</h2>@if($editing)<p class="mt-1 font-mono text-xs text-[#9ca3ae]">Public ID {{ $managedUser->public_id }}</p>@endif</div>@if($editing)<span class="admin-badge {{ $managedUser->trashed() ? 'bg-[#e5484d]/15 text-[#ff8589]' : ($managedUser->blocked_at ? 'bg-[#f6810d]/15 text-[#ffb35b]' : 'bg-[#30a46c]/15 text-[#71d9a5]') }}">{{ $managedUser->trashed() ? 'Deleted' : ($managedUser->blocked_at ? 'Blocked' : 'Active') }}</span>@endif</div>
        @if(!$managedUser->trashed())
        <form method="POST" action="{{ $editing ? route('admin.users.update',$managedUser->id) : route('admin.users.store') }}" class="grid gap-5 sm:grid-cols-2">@csrf @if($editing)@method('PUT')@endif
            <label class="block sm:col-span-2"><span class="admin-label">Full name</span><input class="admin-input" name="name" value="{{ old('name',$managedUser->name) }}" required></label>
            <label class="block sm:col-span-2"><span class="admin-label">Email</span><input class="admin-input" type="email" name="email" value="{{ old('email',$managedUser->email) }}" required></label>
            <label class="block"><span class="admin-label">Level</span><input class="admin-input" type="number" min="1" max="999" name="level" value="{{ old('level',$managedUser->level ?? 1) }}" required></label>
            @if(!$editing)<label class="block"><span class="admin-label">Temporary password</span><input class="admin-input" type="password" name="password" required></label><label class="block sm:col-start-2"><span class="admin-label">Confirm password</span><input class="admin-input" type="password" name="password_confirmation" required></label>@endif
            <div class="sm:col-span-2"><button class="admin-primary">{{ $editing ? 'Save changes' : 'Create user' }}</button></div>
        </form>
        @else
        <p class="text-sm text-[#9ca3ae]">Restore this user before changing account details.</p>
        @endif
    </section>

    @if($editing)<aside class="space-y-6">
        @if(!$managedUser->trashed())
        <section class="admin-card"><div class="flex items-center justify-between"><div><h2 class="font-bold">Gold wallet</h2><p class="mt-1 text-sm text-[#9ca3ae]">Append-only Gold ledger balance</p></div><strong class="text-2xl text-[#ffd166]">{{ number_format($managedUser->wallet?->balance ?? 0) }}</strong></div><form class="mt-4 space-y-3" method="POST" action="{{ route('admin.users.coins',$managedUser->id) }}">@csrf<input class="admin-input" type="number" name="amount" min="-1000000000" max="1000000000" placeholder="Gold amount: positive to credit, negative to debit" required><input class="admin-input" name="reason" maxlength="255" placeholder="Required reason" required><button class="admin-primary w-full">Post adjustment</button></form>@if($coinTransactions->isNotEmpty())<div class="mt-5 space-y-2 border-t border-[#202638] pt-4">@foreach($coinTransactions as $entry)<div class="flex items-start justify-between gap-3 text-sm"><div><p class="{{ $entry->amount > 0 ? 'text-[#71d9a5]' : 'text-[#ff8589]' }}">{{ $entry->amount > 0 ? '+' : '' }}{{ number_format($entry->amount) }}</p><p class="text-xs text-[#9ca3ae]">{{ $entry->description }}</p></div><div class="text-right text-xs text-[#9ca3ae]"><p>{{ number_format($entry->balance_after) }}</p><p>{{ $entry->created_at->format('M j, H:i') }}</p></div></div>@endforeach</div>@endif</section>
        <section class="admin-card"><h2 class="font-bold">Access control</h2><p class="mt-2 text-sm text-[#9ca3ae]">Blocking signs the user out on every device immediately.</p><form class="mt-4" method="POST" action="{{ route('admin.users.block',$managedUser->id) }}">@csrf<button class="{{ $managedUser->blocked_at ? 'admin-secondary' : 'admin-danger' }} w-full">{{ $managedUser->blocked_at ? 'Unblock user' : 'Block user' }}</button></form></section>
        <section class="admin-card"><h2 class="font-bold">Set temporary password</h2><p class="mt-2 text-sm text-[#9ca3ae]">This revokes every active token and session.</p><form class="mt-4 space-y-3" method="POST" action="{{ route('admin.users.password',$managedUser->id) }}">@csrf @method('PUT')<input class="admin-input" type="password" name="password" placeholder="New password" required><input class="admin-input" type="password" name="password_confirmation" placeholder="Confirm password" required><button class="admin-secondary w-full">Change password</button></form></section>
        <section class="admin-card border-[#e5484d]/25"><h2 class="font-bold text-[#ff8589]">Delete user</h2><p class="mt-2 text-sm text-[#9ca3ae]">Moves the account to deleted users. It can be restored.</p><form class="mt-4" method="POST" action="{{ route('admin.users.destroy',$managedUser->id) }}" onsubmit="return confirm('Delete this user?')">@csrf @method('DELETE')<button class="admin-danger w-full">Delete user</button></form></section>
        @else
        <section class="admin-card"><h2 class="font-bold">Restore user</h2><p class="mt-2 text-sm text-[#9ca3ae]">Return this account to the active user list.</p><form class="mt-4" method="POST" action="{{ route('admin.users.restore',$managedUser->id) }}">@csrf<button class="admin-primary w-full">Restore user</button></form></section>
        @endif
    </aside>@endif
</div>
@endsection
