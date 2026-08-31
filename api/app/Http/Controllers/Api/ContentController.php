<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use App\Models\Offer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ContentController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $locale = str_starts_with(strtolower($request->header('Accept-Language', 'en')), 'ar') ? 'ar' : 'en';

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
        ]);
    }

    private function url(?string $path): ?string
    {
        return $path ? Storage::disk('public')->url($path) : null;
    }
}
