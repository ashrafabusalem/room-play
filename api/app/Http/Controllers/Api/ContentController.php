<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use App\Models\Offer;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ContentController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $locale = str_starts_with(strtolower($request->header('Accept-Language', 'en')), 'ar') ? 'ar' : 'en';
        $settings = AppSetting::current();

        return response()->json([
            'banners' => Banner::currentlyVisible()->orderBy('sort_order')->get()->map(fn (Banner $banner) => [
                'id' => (string) $banner->id,
                'title' => $banner->{"title_{$locale}"},
                'subtitle' => $banner->{"subtitle_{$locale}"},
                'cta' => $banner->{"cta_{$locale}"},
                'image_url' => $this->url($banner->image_path),
                'action_type' => $banner->action_type,
                'action_value' => $banner->action_value,
            ])->values(),
            'offers' => Offer::currentlyVisible()->orderBy('sort_order')->get()->map(fn (Offer $offer) => [
                'id' => (string) $offer->id,
                'title' => $offer->{"title_{$locale}"},
                'description' => $offer->{"description_{$locale}"},
                'badge' => $offer->{"badge_{$locale}"},
                'image_url' => $this->url($offer->image_path),
                'price' => $offer->price,
                'original_price' => $offer->original_price,
                'currency' => $offer->currency,
                'reward_coins' => $offer->reward_coins,
                'action_value' => $offer->action_value,
            ])->values(),
            'settings' => [
                'registration_enabled' => $settings->registration_enabled,
                'maintenance_enabled' => $settings->maintenance_enabled,
                'maintenance_message' => $settings->{"maintenance_message_{$locale}"},
                'support_email' => $settings->support_email,
                'support_url' => $settings->support_url,
                'terms_url' => $settings->terms_url,
                'privacy_url' => $settings->privacy_url,
                'minimum_android_version' => $settings->minimum_android_version,
                'minimum_ios_version' => $settings->minimum_ios_version,
                'force_update' => $settings->force_update,
            ],
        ]);
    }

    private function url(?string $path): ?string
    {
        return $path ? Storage::disk('public')->url($path) : null;
    }
}
