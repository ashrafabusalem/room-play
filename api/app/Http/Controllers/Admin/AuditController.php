<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AuditController extends Controller
{
    public function __invoke(Request $request): View
    {
        $query = AdminAudit::with('admin')->latest();
        $search = trim((string) $request->query('search'));
        if ($search !== '') {
            $query->where(fn ($q) => $q->where('action', 'like', "%{$search}%")
                ->orWhereHas('admin', fn ($admin) => $admin->where('name', 'like', "%{$search}%")->orWhere('email', 'like', "%{$search}%")));
        }

        return view('admin.audit.index', [
            'audits' => $query->paginate(30)->withQueryString(),
            'search' => $search,
        ]);
    }
}
