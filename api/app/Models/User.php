<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * `public_id` and `level` are intentionally absent from $fillable — they
     * are assigned by the application, never by request input.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Defaults applied to a new model instance.
     *
     * The migration sets a database default too, but that only fills the
     * column — the object returned by `create()` would still carry a null
     * level, and that is what gets serialised into the registration response.
     *
     * @var array<string, mixed>
     */
    protected $attributes = [
        'level' => 1,
        'dm_privacy' => 'everyone',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'level' => 'integer',
            'is_admin' => 'boolean',
            'blocked_at' => 'datetime',
            'must_change_password' => 'boolean',
        ];
    }

    public function followers()
    {
        return $this->belongsToMany(self::class, 'user_follows', 'followed_id', 'follower_id')->withTimestamps();
    }

    public function following()
    {
        return $this->belongsToMany(self::class, 'user_follows', 'follower_id', 'followed_id')->withTimestamps();
    }

    public function blockedUsers()
    {
        return $this->belongsToMany(self::class, 'user_blocks', 'blocker_id', 'blocked_id')->withTimestamps();
    }

    public function avatarUrl(): ?string
    {
        return $this->avatar_path ? asset('storage/'.$this->avatar_path) : null;
    }

    protected static function booted(): void
    {
        static::creating(function (User $user) {
            $user->public_id ??= static::generatePublicId();
        });
        static::created(fn (User $user) => CoinWallet::firstOrCreate(['user_id' => $user->id]));
    }

    public function wallet() { return $this->hasOne(CoinWallet::class); }

    /**
     * A six-digit id that does not start with zero, so it survives being
     * copied into anything that treats it as a number.
     *
     * Retries on collision rather than trusting randomness; the unique index is
     * the real guarantee, this just avoids handing the user an error.
     */
    protected static function generatePublicId(): string
    {
        do {
            $candidate = (string) random_int(100000, 999999);
        } while (static::where('public_id', $candidate)->exists());

        return $candidate;
    }

    /**
     * Name for a Sanctum token, derived from what the client says it is.
     * Used so a user can see and revoke individual devices later.
     */
    public static function tokenName(?string $device): string
    {
        $device = trim((string) $device);

        return $device === '' ? 'mobile' : Str::limit($device, 60, '');
    }
}
