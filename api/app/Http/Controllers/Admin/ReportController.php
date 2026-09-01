<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\UserReport;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class ReportController extends Controller
{
    public function index(Request $request): View
    {
        $status = (string) $request->query('status', 'pending');
        $reports = UserReport::with(['reporter', 'reported', 'reviewer'])
            ->when($status !== 'all', fn ($q) => $q->where('status', $status))
            ->latest()->paginate(20)->withQueryString();
        return view('admin.reports.index', compact('reports', 'status'));
    }

    public function update(Request $request, UserReport $report): RedirectResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['reviewed', 'actioned', 'dismissed'])],
            'admin_notes' => ['nullable', 'string', 'max:2000'],
        ]);
        $report->update([...$data, 'reviewed_by' => $request->user()->id, 'reviewed_at' => now()]);
        AdminAudit::create([
            'admin_id' => $request->user()->id, 'action' => 'report.'.$data['status'],
            'target_type' => UserReport::class, 'target_id' => $report->id,
            'metadata' => ['reported_user_id' => $report->reported_id],
            'ip_address' => $request->ip(), 'user_agent' => $request->userAgent(),
        ]);
        return back()->with('success', 'Report updated.');
    }
}
