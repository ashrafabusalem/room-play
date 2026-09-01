@extends('admin.layout',['title'=>'Game content'])
@section('content')
<div class="mb-7">
  <h2 class="text-xl font-semibold text-white">Game content</h2>
  <p class="mt-1 text-sm text-[#9ca3ae]">Choose a game, then manage the content players receive.</p>
</div>

<section class="mb-8">
  <p class="admin-label mb-3">Choose a game</p>
  <div class="grid gap-3 sm:grid-cols-2">
    <a href="{{ route('admin.game-prompts.index',['game'=>'truth_or_dare']) }}" class="rounded-2xl border p-5 transition {{ $game==='truth_or_dare'?'border-[#634bf7] bg-[#634bf7]/10':'border-[#202638] bg-[#0e131d] hover:border-[#39425a]' }}">
      <div class="flex items-center gap-3"><span class="text-3xl">🎭</span><div><strong class="block text-white">Truth or Dare</strong><span class="text-sm text-[#9ca3ae]">Questions and challenges</span></div>@if($game==='truth_or_dare')<span class="ml-auto text-[#a99cff]">Selected</span>@endif</div>
    </a>
    <a href="{{ route('admin.game-prompts.index',['game'=>'spy']) }}" class="rounded-2xl border p-5 transition {{ $game==='spy'?'border-[#634bf7] bg-[#634bf7]/10':'border-[#202638] bg-[#0e131d] hover:border-[#39425a]' }}">
      <div class="flex items-center gap-3"><span class="text-3xl">🕵️</span><div><strong class="block text-white">Who’s the Spy?</strong><span class="text-sm text-[#9ca3ae]">Secret word pairs</span></div>@if($game==='spy')<span class="ml-auto text-[#a99cff]">Selected</span>@endif</div>
    </a>
  </div>
</section>

<div class="mb-6 flex flex-wrap items-end justify-between gap-4">
  @if($game==='truth_or_dare')
    <div><p class="admin-label mb-2">Prompt type</p><div class="flex flex-wrap gap-2"><a class="admin-secondary" href="{{ route('admin.game-prompts.index',['game'=>$game]) }}">All prompts</a><a class="admin-secondary" href="{{ route('admin.game-prompts.index',['game'=>$game,'type'=>'truth']) }}">Truth only</a><a class="admin-secondary" href="{{ route('admin.game-prompts.index',['game'=>$game,'type'=>'dare']) }}">Dare only</a></div></div>
  @else
    <div><p class="admin-label">Spy word pairs</p><p class="mt-1 text-sm text-[#9ca3ae]">Each row is the same secret word in English and Arabic.</p></div>
  @endif
  <a class="admin-primary" href="{{ route('admin.game-prompts.create',['game'=>$game]) }}">Add {{ $game==='spy'?'word pair':'prompt' }}</a>
</div>

<div class="space-y-3">@forelse($prompts as $prompt)<a href="{{ route('admin.game-prompts.edit',$prompt) }}" class="block rounded-2xl border border-[#202638] bg-[#0e131d] p-5 hover:border-[#634bf7]"><div class="flex items-start justify-between gap-4"><div><span class="admin-badge bg-[#634bf7]/20 text-[#a99cff]">{{ $prompt->game==='spy'?'Spy word':ucfirst($prompt->type) }}</span><p class="mt-3">{{ $prompt->text_en }}</p><p class="mt-2 text-[#9ca3ae]" dir="rtl">{{ $prompt->text_ar }}</p></div><span class="text-xs {{ $prompt->is_active?'text-[#71d9a5]':'text-[#9ca3ae]' }}">{{ $prompt->is_active?'Active':'Hidden' }}</span></div></a>@empty<div class="admin-card text-center text-[#9ca3ae]">No game content.</div>@endforelse</div>
<div class="mt-6">{{ $prompts->links() }}</div>
@endsection
