<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') · Room Play</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen bg-[#01050e] text-white antialiased">
    <div class="min-h-screen lg:grid lg:grid-cols-[260px_1fr]">
        <aside class="border-b border-[#202638] bg-[#0e131d] lg:min-h-screen lg:border-b-0 lg:border-r">
            <div class="flex h-20 items-center justify-between px-6 lg:justify-start">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-3">
                    <span class="grid size-10 place-items-center rounded-2xl bg-gradient-to-br from-[#634bf7] to-[#4a9bf7] font-black">RP</span>
                    <span><strong class="block text-lg">Room Play</strong><small class="text-[#9ca3ae]">Control center</small></span>
                </a>
            </div>
            <nav class="flex gap-2 overflow-x-auto px-4 pb-4 lg:block lg:space-y-2 lg:pb-0">
                <a class="admin-nav {{ request()->routeIs('admin.dashboard') ? 'admin-nav-active' : '' }}" href="{{ route('admin.dashboard') }}">Dashboard</a>
                <a class="admin-nav {{ request()->routeIs('admin.users.*') ? 'admin-nav-active' : '' }}" href="{{ route('admin.users.index') }}">Users</a>
                <a class="admin-nav {{ request()->routeIs('admin.rooms.*') ? 'admin-nav-active' : '' }}" href="{{ route('admin.rooms.index') }}">Rooms</a>
                <a class="admin-nav {{ request()->routeIs('admin.reports.*') ? 'admin-nav-active' : '' }}" href="{{ route('admin.reports.index') }}">Reports</a>
                <a class="admin-nav {{ request()->routeIs('admin.banners.*') ? 'admin-nav-active' : '' }}" href="{{ route('admin.banners.index') }}">Banners</a>
                <a class="admin-nav {{ request()->routeIs('admin.offers.*') ? 'admin-nav-active' : '' }}" href="{{ route('admin.offers.index') }}">Offers</a>
                <a class="admin-nav {{ request()->routeIs('admin.audit.*') ? 'admin-nav-active' : '' }}" href="{{ route('admin.audit.index') }}">Audit log</a>
                <a class="admin-nav {{ request()->routeIs('admin.settings.*') ? 'admin-nav-active' : '' }}" href="{{ route('admin.settings.edit') }}">App settings</a>
            </nav>
            <div class="mt-auto hidden p-5 lg:block lg:absolute lg:bottom-0 lg:w-[260px]">
                <div class="rounded-2xl border border-[#2a3140] bg-[#14172b] p-4">
                    <p class="truncate text-sm font-semibold">{{ auth()->user()->name }}</p>
                    <p class="truncate text-xs text-[#9ca3ae]">{{ auth()->user()->email }}</p>
                    <a class="mt-3 block text-sm text-[#9ca3ae] hover:text-white" href="{{ route('admin.password.edit') }}">Change password</a>
                    <form method="POST" action="{{ route('admin.logout') }}" class="mt-3">@csrf
                        <button class="text-sm text-[#9ca3ae] hover:text-white">Sign out</button>
                    </form>
                </div>
            </div>
        </aside>

        <main class="min-w-0">
            <header class="flex min-h-20 items-center justify-between border-b border-[#111928] px-5 lg:px-8">
                <div><p class="text-xs font-semibold uppercase tracking-[.2em] text-[#7361e9]">Room Play Admin</p><h1 class="mt-1 text-xl font-bold">@yield('heading', 'Dashboard')</h1></div>
                <div class="size-10 rounded-full bg-gradient-to-br from-[#31194e] to-[#6d2c8f] text-center text-sm font-bold leading-10">{{ strtoupper(substr(auth()->user()->name, 0, 1)) }}</div>
            </header>
            <div class="p-5 lg:p-8">
                @if(session('success'))<div class="mb-6 rounded-2xl border border-[#30a46c]/40 bg-[#30a46c]/10 px-4 py-3 text-sm text-[#71d9a5]">{{ session('success') }}</div>@endif
                @yield('content')
            </div>
        </main>
    </div>
</body>
</html>
