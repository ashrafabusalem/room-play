@extends('admin.layout')
@section('title','Banners') @section('heading','Banners')
@section('content')
<div class="mb-6 flex items-center justify-between"><p class="text-sm text-[#9ca3ae]">Control the promotional carousel shown in the app.</p><a class="admin-primary" href="{{ route('admin.banners.create') }}">Add banner</a></div>
<div class="grid gap-4">@forelse($banners as $banner)<a href="{{ route('admin.banners.edit',$banner) }}" class="admin-card flex items-center gap-4 transition hover:border-[#634bf7]">
    <div class="grid h-20 w-32 shrink-0 place-items-center overflow-hidden rounded-xl bg-gradient-to-br from-[#1b1781] to-[#3b1d8a]">@if($banner->image_path)<img class="h-full w-full object-cover" src="{{ Storage::disk('public')->url($banner->image_path) }}">@else<span class="text-2xl">✦</span>@endif</div>
    <div class="min-w-0 flex-1"><div class="flex items-center gap-2"><h2 class="truncate font-bold">{{ str_replace("\n",' · ',$banner->title_en) }}</h2><span class="admin-badge {{ $banner->is_active ? 'bg-[#30a46c]/15 text-[#71d9a5]' : 'bg-white/5 text-[#9ca3ae]' }}">{{ $banner->is_active ? 'Active' : 'Hidden' }}</span></div><p dir="rtl" class="mt-1 truncate text-right text-sm text-[#9ca3ae]">{{ str_replace("\n",' · ',$banner->title_ar) }}</p><p class="mt-2 text-xs text-[#5a6474]">Order {{ $banner->sort_order }} · {{ ucfirst($banner->action_type) }}</p></div><span class="text-[#7361e9]">Edit</span>
</a>@empty<div class="admin-card py-12 text-center text-[#9ca3ae]">No banners yet.</div>@endforelse</div>
@endsection
