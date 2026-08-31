<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\AppSetting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class SettingController extends Controller
{
    public function edit(): View
    {
        return view('admin.settings.edit', ['settings' => AppSetting::current()]);
    }

    public function update(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'maintenance_message_en' => ['nullable', 'string', 'max:500'],
            'maintenance_message_ar' => ['nullable', 'string', 'max:500'],
            'support_email' => ['nullable', 'email', 'max:255'],
            'support_url' => ['nullable', 'url', 'max:500'],
            'terms_url' => ['nullable', 'url', 'max:500'],
            'privacy_url' => ['nullable', 'url', 'max:500'],
            'minimum_android_version' => ['nullable', 'regex:/^\d+(\.\d+){0,3}$/', 'max:30'],
            'minimum_ios_version' => ['nullable', 'regex:/^\d+(\.\d+){0,3}$/', 'max:30'],
        ]);
        $data['registration_enabled'] = $request->boolean('registration_enabled');
        $data['maintenance_enabled'] = $request->boolean('maintenance_enabled');
        $data['force_update'] = $request->boolean('force_update');

        $settings = AppSetting::current();
        $before = $settings->only(array_keys($data));
        $settings->update($data);

        AdminAudit::create([
            'admin_id' => $request->user()->id,
            'action' => 'settings.updated',
            'target_type' => AppSetting::class,
            'target_id' => $settings->id,
            'metadata' => ['before' => $before, 'after' => $settings->only(array_keys($data))],
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return back()->with('success', 'App settings updated.');
    }
}
