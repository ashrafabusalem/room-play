<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\Banner;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class BannerController extends Controller
{
    public function index(): View
    {
        return view('admin.banners.index', ['banners' => Banner::orderBy('sort_order')->get()]);
    }

    public function create(): View
    {
        return view('admin.banners.form', ['banner' => new Banner]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);
        if ($request->hasFile('image')) $data['image_path'] = $request->file('image')->store('banners', 'public');
        $banner = Banner::create($data);
        $this->audit($request, 'banner.created', $banner);
        return redirect()->route('admin.banners.edit', $banner)->with('success', 'Banner created.');
    }

    public function edit(Banner $banner): View
    {
        return view('admin.banners.form', compact('banner'));
    }

    public function update(Request $request, Banner $banner): RedirectResponse
    {
        $data = $this->validated($request);
        if ($request->hasFile('image')) {
            $newPath = $request->file('image')->store('banners', 'public');
            if ($banner->image_path) Storage::disk('public')->delete($banner->image_path);
            $data['image_path'] = $newPath;
        }
        $banner->update($data);
        $this->audit($request, 'banner.updated', $banner);
        return back()->with('success', 'Banner updated.');
    }

    public function destroy(Request $request, Banner $banner): RedirectResponse
    {
        if ($banner->image_path) Storage::disk('public')->delete($banner->image_path);
        $this->audit($request, 'banner.deleted', $banner);
        $banner->delete();
        return redirect()->route('admin.banners.index')->with('success', 'Banner deleted.');
    }

    private function validated(Request $request): array
    {
        $data = $request->validate([
            'title_en' => ['required', 'string', 'max:120'], 'title_ar' => ['required', 'string', 'max:120'],
            'subtitle_en' => ['nullable', 'string', 'max:300'], 'subtitle_ar' => ['nullable', 'string', 'max:300'],
            'cta_en' => ['nullable', 'string', 'max:40'], 'cta_ar' => ['nullable', 'string', 'max:40'],
            'image' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'action_type' => ['required', Rule::in(['none', 'games', 'rooms', 'offers', 'url'])],
            'action_value' => ['nullable', 'string', 'max:500'],
            'sort_order' => ['required', 'integer', 'min:0', 'max:9999'],
            'starts_at' => ['nullable', 'date'], 'ends_at' => ['nullable', 'date', 'after:starts_at'],
        ]);
        $data['is_active'] = $request->boolean('is_active');
        unset($data['image']);
        return $data;
    }

    private function audit(Request $request, string $action, Banner $banner): void
    {
        AdminAudit::create(['admin_id' => $request->user()->id, 'action' => $action, 'target_type' => Banner::class, 'target_id' => $banner->id, 'ip_address' => $request->ip(), 'user_agent' => $request->userAgent()]);
    }
}
