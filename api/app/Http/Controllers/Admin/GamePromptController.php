<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AdminAudit;
use App\Models\GamePrompt;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class GamePromptController extends Controller
{
    public function index(Request $request): View
    {
        $game = $request->query('game') === 'spy' ? 'spy' : 'truth_or_dare';
        $query = GamePrompt::where('game', $game);
        if ($request->filled('type')) {
            $query->where('type', $request->query('type'));
        }

        return view('admin.game-prompts.index', ['prompts' => $query->latest()->paginate(30)->withQueryString(), 'game' => $game]);
    }

    public function create(Request $request): View
    {
        return view('admin.game-prompts.form', ['prompt' => new GamePrompt(['game' => $request->query('game') === 'spy' ? 'spy' : 'truth_or_dare'])]);
    }

    public function store(Request $request): RedirectResponse
    {
        $prompt = GamePrompt::create($this->data($request));
        $this->audit($request, 'game_prompt.created', $prompt);

        return redirect()->route('admin.game-prompts.edit', $prompt)->with('success', 'Game content created.');
    }

    public function edit(GamePrompt $gamePrompt): View
    {
        return view('admin.game-prompts.form', ['prompt' => $gamePrompt]);
    }

    public function update(Request $request, GamePrompt $gamePrompt): RedirectResponse
    {
        $gamePrompt->update($this->data($request));
        $this->audit($request, 'game_prompt.updated', $gamePrompt);

        return back()->with('success', 'Game content updated.');
    }

    public function destroy(Request $request, GamePrompt $gamePrompt): RedirectResponse
    {
        $game = $gamePrompt->game;
        $this->audit($request, 'game_prompt.deleted', $gamePrompt);
        $gamePrompt->delete();

        return redirect()->route('admin.game-prompts.index', ['game' => $game])->with('success', 'Game content deleted.');
    }

    private function data(Request $request): array
    {
        $request->mergeIfMissing(['game' => 'truth_or_dare']);
        $data = $request->validate(['game' => ['required', Rule::in(['truth_or_dare', 'spy'])], 'type' => ['required', Rule::in(['truth', 'dare', 'word'])], 'text_en' => ['required', 'string', 'max:1000'], 'text_ar' => ['required', 'string', 'max:1000'], 'minimum_age' => ['required', 'integer', 'min:13', 'max:18'], 'is_active' => ['nullable', 'boolean']]);
        abort_if(($data['game'] === 'spy') !== ($data['type'] === 'word'), 422, 'Choose a valid content type for this game.');
        $data['is_active'] = $request->boolean('is_active');

        return $data;
    }

    private function audit(Request $request, string $action, GamePrompt $prompt): void
    {
        AdminAudit::create(['admin_id' => $request->user()->id, 'action' => $action, 'target_type' => GamePrompt::class, 'target_id' => $prompt->id, 'ip_address' => $request->ip(), 'user_agent' => $request->userAgent()]);
    }
}
