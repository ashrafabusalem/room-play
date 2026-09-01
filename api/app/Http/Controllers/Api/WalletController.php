<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CoinWallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $wallet = CoinWallet::firstOrCreate(['user_id' => $request->user()->id]);
        $transactions = $wallet->transactions()->paginate(30);
        return response()->json([
            'balance' => $wallet->balance,
            'transactions' => $transactions->getCollection()->map(fn ($item) => [
                'reference' => $item->reference, 'amount' => $item->amount,
                'balance_after' => $item->balance_after, 'type' => $item->type,
                'description' => $item->description, 'created_at' => $item->created_at->toISOString(),
            ])->values(),
            'next_page_url' => $transactions->nextPageUrl(),
        ]);
    }
}
