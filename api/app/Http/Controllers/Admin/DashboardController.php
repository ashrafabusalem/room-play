<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\User;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function __invoke(): View
    {
        return view('admin.dashboard', [
            'totalUsers' => User::where('is_admin', false)->count(),
            'newUsers' => User::where('is_admin', false)->where('created_at', '>=', now()->subDays(7))->count(),
            'blockedUsers' => User::where('is_admin', false)->whereNotNull('blocked_at')->count(),
            'deletedUsers' => User::onlyTrashed()->where('is_admin', false)->count(),
            'recentUsers' => User::where('is_admin', false)->latest()->limit(6)->get(),
            'recentAudits' => AdminAudit::with('admin')->latest()->limit(8)->get(),
        ]);
    }
}
