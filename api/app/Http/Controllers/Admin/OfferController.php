<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\Offer;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class OfferController extends Controller
{
    public function index(): View
    {
        return view('admin.offers.index', ['offers' => Offer::orderBy('sort_order')->get()]);
    }

    public function create(): View { return view('admin.offers.form', ['offer' => new Offer]); }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);
        if ($request->hasFile('image')) $data['image_path'] = $request->file('image')->store('offers', 'public');
        $offer = Offer::create($data);
        $this->audit($request, 'offer.created', $offer);
        return redirect()->route('admin.offers.edit', $offer)->with('success', 'Offer created.');
    }

    public function edit(Offer $offer): View { return view('admin.offers.form', compact('offer')); }

    public function update(Request $request, Offer $offer): RedirectResponse
    {
        $data = $this->validated($request);
        if ($request->hasFile('image')) {
            $newPath = $request->file('image')->store('offers', 'public');
            if ($offer->image_path) Storage::disk('public')->delete($offer->image_path);
            $data['image_path'] = $newPath;
        }
        $offer->update($data);
        $this->audit($request, 'offer.updated', $offer);
        return back()->with('success', 'Offer updated.');
    }

    public function destroy(Request $request, Offer $offer): RedirectResponse
    {
        if ($offer->image_path) Storage::disk('public')->delete($offer->image_path);
        $this->audit($request, 'offer.deleted', $offer);
        $offer->delete();
        return redirect()->route('admin.offers.index')->with('success', 'Offer deleted.');
    }

    private function validated(Request $request): array
    {
        $data = $request->validate([
            'title_en' => ['required', 'string', 'max:120'], 'title_ar' => ['required', 'string', 'max:120'],
            'description_en' => ['nullable', 'string', 'max:1000'], 'description_ar' => ['nullable', 'string', 'max:1000'],
            'badge_en' => ['nullable', 'string', 'max:40'], 'badge_ar' => ['nullable', 'string', 'max:40'],
            'image' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:5120'],
            'price' => ['nullable', 'numeric', 'min:0', 'max:999999999'], 'original_price' => ['nullable', 'numeric', 'min:0', 'max:999999999'],
            'currency' => ['required', 'string', 'max:8'], 'reward_coins' => ['required', 'integer', 'min:0'],
            'action_value' => ['nullable', 'string', 'max:500'], 'sort_order' => ['required', 'integer', 'min:0', 'max:9999'],
            'starts_at' => ['nullable', 'date'], 'ends_at' => ['nullable', 'date', 'after:starts_at'],
        ]);
        $data['is_active'] = $request->boolean('is_active');
        $data['currency'] = strtoupper($data['currency']);
        unset($data['image']);
        return $data;
    }

    private function audit(Request $request, string $action, Offer $offer): void
    {
        AdminAudit::create(['admin_id' => $request->user()->id, 'action' => $action, 'target_type' => Offer::class, 'target_id' => $offer->id, 'ip_address' => $request->ip(), 'user_agent' => $request->userAgent()]);
    }
}
