<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
use App\Services\CoinLedger;

class UserController extends Controller
{
    public function index(Request $request): View
    {
        $query = User::withTrashed()->where('is_admin', false);
        $search = trim((string) $request->query('search'));

        if ($search !== '') {
            $query->where(fn ($q) => $q
                ->where('name', 'like', "%{$search}%")
                ->orWhere('email', 'like', "%{$search}%")
                ->orWhere('public_id', 'like', "%{$search}%"));
        }

        match ($request->query('status')) {
            'active' => $query->whereNull('blocked_at')->whereNull('deleted_at'),
            'blocked' => $query->whereNotNull('blocked_at')->whereNull('deleted_at'),
            'deleted' => $query->onlyTrashed(),
            default => null,
        };

        return view('admin.users.index', [
            'users' => $query->latest()->paginate(20)->withQueryString(),
            'search' => $search,
            'status' => (string) $request->query('status'),
        ]);
    }

    public function create(): View
    {
        return view('admin.users.form', ['managedUser' => new User]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:80'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'level' => ['required', 'integer', 'min:1', 'max:999'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);
        $data['email'] = strtolower(trim($data['email']));
        $data['must_change_password'] = true;
        $user = User::create($data);
        $user->level = $data['level'];
        $user->must_change_password = true;
        $user->save();

        $this->audit($request, 'user.created', $user, ['email' => $user->email]);

        return redirect()->route('admin.users.edit', $user)->with('success', 'User created.');
    }

    public function edit(string $user): View
    {
        $managedUser = $this->findUser($user);
        $managedUser->load('wallet');
        return view('admin.users.form', [
            'managedUser' => $managedUser,
            'coinTransactions' => $managedUser->wallet?->transactions()->with('creator')->limit(20)->get() ?? collect(),
        ]);
    }

    public function update(Request $request, string $user): RedirectResponse
    {
        $managedUser = $this->findUser($user);
        abort_if($managedUser->trashed(), 409);
        $data = $request->validate([
            'name' => ['required', 'string', 'min:2', 'max:80'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users')->ignore($managedUser->id)],
            'level' => ['required', 'integer', 'min:1', 'max:999'],
        ]);
        $data['email'] = strtolower(trim($data['email']));
        $before = $managedUser->only(['name', 'email', 'level']);
        $managedUser->forceFill($data)->save();
        $this->audit($request, 'user.updated', $managedUser, ['before' => $before, 'after' => $managedUser->only(array_keys($before))]);

        return back()->with('success', 'User updated.');
    }

    public function toggleBlock(Request $request, string $user): RedirectResponse
    {
        $managedUser = $this->findUser($user);
        abort_if($managedUser->trashed() || $managedUser->is_admin, 409);
        $blocking = $managedUser->blocked_at === null;

        DB::transaction(function () use ($managedUser, $blocking) {
            $managedUser->forceFill(['blocked_at' => $blocking ? now() : null])->save();
            if ($blocking) {
                $managedUser->tokens()->delete();
                DB::table('sessions')->where('user_id', $managedUser->id)->delete();
            }
        });

        $this->audit($request, $blocking ? 'user.blocked' : 'user.unblocked', $managedUser);

        return back()->with('success', $blocking ? 'User blocked and signed out.' : 'User unblocked.');
    }

    public function password(Request $request, string $user): RedirectResponse
    {
        $managedUser = $this->findUser($user);
        abort_if($managedUser->trashed() || $managedUser->is_admin, 409);
        $data = $request->validate(['password' => ['required', 'string', 'min:8', 'confirmed']]);

        DB::transaction(function () use ($managedUser, $data) {
            $managedUser->forceFill(['password' => $data['password'], 'must_change_password' => true])->save();
            $managedUser->tokens()->delete();
            DB::table('sessions')->where('user_id', $managedUser->id)->delete();
        });

        $this->audit($request, 'user.password_changed', $managedUser);

        return back()->with('success', 'Temporary password set and all sessions revoked.');
    }

    public function coins(Request $request, string $user, CoinLedger $ledger): RedirectResponse
    {
        $managedUser = $this->findUser($user);
        abort_if($managedUser->trashed() || $managedUser->is_admin, 409);
        $data = $request->validate([
            'amount' => ['required', 'integer', 'not_in:0', 'min:-1000000000', 'max:1000000000'],
            'reason' => ['required', 'string', 'min:3', 'max:255'],
        ]);
        $transaction = $ledger->post($managedUser, (int) $data['amount'], 'admin_adjustment', trim($data['reason']), $request->user());
        $this->audit($request, 'wallet.adjusted', $managedUser, [
            'reference' => $transaction->reference, 'amount' => $transaction->amount, 'balance_after' => $transaction->balance_after,
        ]);
        return back()->with('success', 'Gold balance adjusted.');
    }

    public function destroy(Request $request, string $user): RedirectResponse
    {
        $managedUser = $this->findUser($user);
        abort_if($managedUser->is_admin || $managedUser->trashed(), 409);
        $managedUser->tokens()->delete();
        DB::table('sessions')->where('user_id', $managedUser->id)->delete();
        $managedUser->delete();
        $this->audit($request, 'user.deleted', $managedUser);

        return redirect()->route('admin.users.index')->with('success', 'User moved to deleted users.');
    }

    public function restore(Request $request, string $user): RedirectResponse
    {
        $managedUser = $this->findUser($user);
        abort_unless($managedUser->trashed(), 409);
        $managedUser->restore();
        $this->audit($request, 'user.restored', $managedUser);

        return back()->with('success', 'User restored.');
    }

    private function findUser(string $id): User
    {
        return User::withTrashed()->where('is_admin', false)->findOrFail($id);
    }

    private function audit(Request $request, string $action, User $target, array $metadata = []): void
    {
        AdminAudit::create([
            'admin_id' => $request->user()->id,
            'action' => $action,
            'target_type' => User::class,
            'target_id' => $target->id,
            'metadata' => $metadata ?: null,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);
    }
}
