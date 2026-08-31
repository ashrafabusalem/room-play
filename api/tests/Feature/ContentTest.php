<?php

namespace Tests\Feature;

use App\Models\Banner;
use App\Models\Offer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ContentTest extends TestCase
{
    use RefreshDatabase;

    public function test_content_endpoint_localises_and_filters_scheduled_content(): void
    {
        Banner::query()->delete();
        Banner::create(['title_en' => 'Live', 'title_ar' => 'مباشر', 'cta_en' => 'Open', 'cta_ar' => 'افتح', 'sort_order' => 2, 'is_active' => true]);
        Banner::create(['title_en' => 'Future', 'title_ar' => 'لاحقاً', 'sort_order' => 1, 'is_active' => true, 'starts_at' => now()->addDay()]);
        Offer::create(['title_en' => 'Pack', 'title_ar' => 'حزمة', 'currency' => 'USD', 'reward_coins' => 500, 'is_active' => true]);

        $this->withHeader('Accept-Language', 'ar-JO')->getJson('/api/content')
            ->assertOk()
            ->assertJsonCount(1, 'banners')
            ->assertJsonPath('banners.0.title', 'مباشر')
            ->assertJsonPath('offers.0.title', 'حزمة')
            ->assertJsonPath('offers.0.reward_coins', 500);
    }

    public function test_admin_can_upload_and_manage_a_banner(): void
    {
        Storage::fake('public');
        $admin = User::factory()->create(['is_admin' => true]);

        $this->actingAs($admin)->post('/admin/banners', [
            'title_en' => 'Summer', 'title_ar' => 'الصيف', 'subtitle_en' => 'Hello', 'subtitle_ar' => 'مرحباً',
            'cta_en' => 'Open', 'cta_ar' => 'افتح', 'action_type' => 'offers', 'sort_order' => 5,
            'is_active' => '1',
            'image' => UploadedFile::fake()->createWithContent(
                'banner.png',
                base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='),
            ),
        ])->assertRedirect();

        $banner = Banner::where('title_en', 'Summer')->firstOrFail();
        Storage::disk('public')->assertExists($banner->image_path);
        $this->assertDatabaseHas('admin_audits', ['action' => 'banner.created', 'target_id' => $banner->id]);
    }

    public function test_admin_can_create_an_offer(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);

        $this->actingAs($admin)->post('/admin/offers', [
            'title_en' => 'Starter pack', 'title_ar' => 'حزمة البداية', 'description_en' => 'Coins', 'description_ar' => 'عملات',
            'currency' => 'usd', 'price' => '1.99', 'reward_coins' => 1000, 'sort_order' => 1, 'is_active' => '1',
        ])->assertRedirect();

        $this->assertDatabaseHas('offers', ['title_en' => 'Starter pack', 'currency' => 'USD', 'reward_coins' => 1000]);
    }
}
