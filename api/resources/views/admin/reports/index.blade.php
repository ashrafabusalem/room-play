@extends('admin.layout')
@section('title', 'Reports')
@section('heading', 'User reports')
@section('content')
<div class="mb-6 flex flex-wrap gap-2">
    @foreach(['pending' => 'Pending', 'reviewed' => 'Reviewed', 'actioned' => 'Actioned', 'dismissed' => 'Dismissed', 'all' => 'All'] as $value => $label)
        <a href="{{ route('admin.reports.index', ['status' => $value]) }}" class="rounded-xl px-4 py-2 text-sm {{ $status === $value ? 'bg-[#634bf7] text-white' : 'bg-[#14172b] text-[#9ca3ae]' }}">{{ $label }}</a>
    @endforeach
</div>
<div class="space-y-4">
@forelse($reports as $report)
    <article class="rounded-2xl border border-[#202638] bg-[#0e131d] p-5">
        <div class="flex flex-wrap items-start justify-between gap-4">
            <div>
                <p class="font-semibold">{{ $report->reporter->name }} reported <a class="text-[#8f7cff] hover:underline" href="{{ route('admin.users.edit', $report->reported) }}">{{ $report->reported->name }}</a></p>
                <p class="mt-1 text-sm text-[#9ca3ae]">{{ ucfirst($report->reason) }} · {{ $report->created_at->diffForHumans() }}</p>
                @if($report->details)<p class="mt-3 whitespace-pre-wrap text-sm">{{ $report->details }}</p>@endif
            </div>
            <span class="rounded-full bg-[#14172b] px-3 py-1 text-xs uppercase tracking-wide text-[#9ca3ae]">{{ $report->status }}</span>
        </div>
        <form method="POST" action="{{ route('admin.reports.update', $report) }}" class="mt-5 grid gap-3 md:grid-cols-[180px_1fr_auto]">@csrf @method('PUT')
            <select name="status" class="admin-input"><option value="reviewed">Reviewed</option><option value="actioned">Actioned</option><option value="dismissed">Dismissed</option></select>
            <input name="admin_notes" value="{{ $report->admin_notes }}" maxlength="2000" placeholder="Private moderation note" class="admin-input">
            <button class="rounded-xl bg-[#634bf7] px-5 py-2 text-sm font-semibold">Save</button>
        </form>
    </article>
@empty
    <div class="rounded-2xl border border-[#202638] bg-[#0e131d] p-10 text-center text-[#9ca3ae]">No reports in this queue.</div>
@endforelse
</div>
<div class="mt-6">{{ $reports->links() }}</div>
@endsection
