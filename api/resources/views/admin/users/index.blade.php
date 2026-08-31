@extends('admin.layout')
@section('title', 'Users')
@section('heading', 'Users')
@section('content')
<div class="mb-6 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
    <form class="flex flex-1 gap-3" method="GET">
        <input class="admin-input max-w-lg" name="search" value="{{ $search }}" placeholder="Search name, email or public ID">
        <select class="admin-input max-w-40" name="status" onchange="this.form.submit()"><option value="">All users</option><option value="active" @selected($status==='active')>Active</option><option value="blocked" @selected($status==='blocked')>Blocked</option><option value="deleted" @selected($status==='deleted')>Deleted</option></select>
        <button class="admin-secondary">Search</button>
    </form>
    <a class="admin-primary text-center" href="{{ route('admin.users.create') }}">Add user</a>
</div>
<div class="admin-card overflow-x-auto p-0">
    <table class="w-full min-w-[760px] text-left text-sm">
        <thead class="border-b border-[#2a3140] text-xs uppercase tracking-wider text-[#9ca3ae]"><tr><th class="p-4">User</th><th>Public ID</th><th>Level</th><th>Status</th><th>Joined</th><th class="p-4 text-right">Action</th></tr></thead>
        <tbody class="divide-y divide-[#202638]">@forelse($users as $user)<tr class="hover:bg-white/[.02]"><td class="p-4"><div class="font-semibold">{{ $user->name }}</div><div class="text-xs text-[#9ca3ae]">{{ $user->email }}</div></td><td class="font-mono text-[#9ca3ae]">{{ $user->public_id }}</td><td>{{ $user->level }}</td><td>@if($user->trashed())<span class="admin-badge bg-[#e5484d]/15 text-[#ff8589]">Deleted</span>@elseif($user->blocked_at)<span class="admin-badge bg-[#f6810d]/15 text-[#ffb35b]">Blocked</span>@else<span class="admin-badge bg-[#30a46c]/15 text-[#71d9a5]">Active</span>@endif</td><td class="text-[#9ca3ae]">{{ $user->created_at->format('M j, Y') }}</td><td class="p-4 text-right"><a class="text-[#7361e9] hover:text-white" href="{{ route('admin.users.edit',$user->id) }}">Manage</a></td></tr>@empty<tr><td colspan="6" class="p-10 text-center text-[#9ca3ae]">No users match your search.</td></tr>@endforelse</tbody>
    </table>
</div>
<div class="mt-5">{{ $users->links() }}</div>
@endsection
