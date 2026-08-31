@extends('admin.layout')
@section('title', 'Dashboard')
@section('heading', 'Dashboard')
@section('content')
<div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
    @foreach([['Users',$totalUsers,'#634bf7'],['New this week',$newUsers,'#4a9bf7'],['Blocked',$blockedUsers,'#f6810d'],['Deleted',$deletedUsers,'#e5484d']] as [$label,$value,$color])
        <div class="admin-card"><div class="mb-5 size-2 rounded-full" style="background:{{ $color }};box-shadow:0 0 18px {{ $color }}"></div><p class="text-sm text-[#9ca3ae]">{{ $label }}</p><p class="mt-1 text-3xl font-black">{{ number_format($value) }}</p></div>
    @endforeach
</div>
<div class="mt-6 grid gap-6 xl:grid-cols-[1.2fr_.8fr]">
    <section class="admin-card overflow-hidden p-0"><div class="flex items-center justify-between border-b border-[#2a3140] p-5"><h2 class="font-bold">Newest users</h2><a class="text-sm text-[#7361e9]" href="{{ route('admin.users.index') }}">View all</a></div>
        <div class="divide-y divide-[#202638]">@forelse($recentUsers as $user)<a href="{{ route('admin.users.edit',$user) }}" class="flex items-center gap-3 p-4 hover:bg-white/[.025]"><span class="grid size-10 place-items-center rounded-full bg-[#1f2532] font-semibold">{{ strtoupper(substr($user->name,0,1)) }}</span><span class="min-w-0 flex-1"><strong class="block truncate text-sm">{{ $user->name }}</strong><small class="truncate text-[#9ca3ae]">{{ $user->email }}</small></span><small class="text-[#5a6474]">{{ $user->created_at->diffForHumans() }}</small></a>@empty<p class="p-5 text-sm text-[#9ca3ae]">No users yet.</p>@endforelse</div>
    </section>
    <section class="admin-card overflow-hidden p-0"><div class="border-b border-[#2a3140] p-5"><h2 class="font-bold">Recent admin activity</h2></div>
        <div class="divide-y divide-[#202638]">@forelse($recentAudits as $audit)<div class="p-4"><p class="text-sm font-medium">{{ str_replace(['.','_'],' ',ucfirst($audit->action)) }}</p><p class="mt-1 text-xs text-[#9ca3ae]">{{ $audit->admin?->name ?? 'System' }} · {{ $audit->created_at->diffForHumans() }}</p></div>@empty<p class="p-5 text-sm text-[#9ca3ae]">No activity yet.</p>@endforelse</div>
    </section>
</div>
@endsection
