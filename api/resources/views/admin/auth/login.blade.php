<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin sign in · Room Play</title>
    @vite(['resources/css/app.css'])
</head>
<body class="grid min-h-screen place-items-center bg-[#01050e] p-5 text-white antialiased">
    <div class="pointer-events-none fixed inset-0 bg-[radial-gradient(circle_at_50%_0%,rgba(99,75,247,.25),transparent_42%)]"></div>
    <main class="relative w-full max-w-md rounded-[28px] border border-[#2a3140] bg-[#0e131d]/95 p-7 shadow-2xl shadow-black/50 sm:p-9">
        <div class="mb-8 flex items-center gap-4">
            <span class="grid size-12 place-items-center rounded-2xl bg-gradient-to-br from-[#634bf7] to-[#4a9bf7] font-black">RP</span>
            <div><h1 class="text-2xl font-bold">Welcome back</h1><p class="text-sm text-[#9ca3ae]">Sign in to the Room Play control center.</p></div>
        </div>
        <form method="POST" action="{{ route('admin.login.store') }}" class="space-y-5">@csrf
            <label class="block"><span class="admin-label">Email address</span><input class="admin-input" type="email" name="email" value="{{ old('email') }}" required autofocus autocomplete="username"></label>
            <label class="block"><span class="admin-label">Password</span><input class="admin-input" type="password" name="password" required autocomplete="current-password"></label>
            <label class="flex items-center gap-2 text-sm text-[#9ca3ae]"><input type="checkbox" name="remember" value="1" class="accent-[#634bf7]"> Keep me signed in</label>
            @if($errors->any())<p class="rounded-xl bg-[#e5484d]/10 px-4 py-3 text-sm text-[#ff8589]">{{ $errors->first() }}</p>@endif
            <button class="admin-primary w-full" type="submit">Sign in securely</button>
        </form>
    </main>
</body>
</html>
