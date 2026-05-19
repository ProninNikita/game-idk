# Agent Session Instructions

This file is the persistent handoff document for future AI/coding sessions on Project Hearthline. When a new session starts, read this file first, then read `README.md`, `TODO.md`, `CHANGELOG.md`, and `docs/INDEX.md` before making changes.

## Communication Rules

- Talk with the user in Russian.
- Keep all project documentation in English.
- Keep all in-game UI text in English unless the user explicitly changes the language direction.
- Be concise in final reports, but include what changed, what was tested, and whether anything remains unstaged or blocked.

## Project Rules

- Engine target: Godot 4.6.x stable.
- Current known working local Godot binary: `/Users/likit/Desktop/Godot.app/Contents/MacOS/Godot`.
- Main repository: `https://github.com/ProninNikita/game-idk`, branch `main`.
- The game is a top-down survival automation sandbox inspired by gathering, crafting, base building, station crafting, and survival pressure.
- Preserve placeholder/code-drawn visuals until the user asks for art assets, but write systems so graphics can be swapped in later.
- Prefer data-driven definitions for future items, recipes, buildings, resources, UI labels, costs, stack sizes, and save ids.

## Start-of-Session Checklist

1. Run `git status --short` and identify existing user/editor changes before editing.
2. Read the current task state in `TODO.md`.
3. Read the current feature summary in `README.md`.
4. Read recent development history in `CHANGELOG.md`.
5. Read `docs/INDEX.md` if the task touches design, architecture, content, UI, testing, or production rules.
6. Treat existing dirty files as user/editor changes unless you made them in the current session.

## Task Management

- Keep `TODO.md` as the live task checklist.
- Add new tasks before or during implementation when the user asks for new systems.
- Mark tasks complete only after implementation and verification.
- If an architecture review finds risks, convert those risks into actionable TODO items.
- Do not leave completed work only in chat; reflect it in `TODO.md` when it affects the project backlog.

## Documentation Rules

- Documentation must stay in English.
- Update relevant docs when behavior, architecture, workflows, or testing changes.
- Update `README.md` when the current prototype feature list, setup flow, or verification flow changes.
- Update `CHANGELOG.md` under `Unreleased` for player-facing changes, notable fixes, and technical pipeline changes.
- Do not add noisy changelog entries for purely mechanical formatting or language-cleanup changes unless the user asks.
- Update design docs in `docs/` when implementation changes the intended design or future plan.

## Implementation Rules

- Use existing project patterns before inventing new architecture.
- Keep gameplay text, ids, costs, recipes, and definitions moving toward shared data resources.
- Keep UI modes explicit: normal play, inventory, station UI, building placement, pause, and menu should not fight each other.
- Building placement must validate occupancy, range, footprint, and cost through safe paths.
- Station crafting outputs should drop near the station and remain on the ground until picked up unless a future automation/storage system changes that rule.
- Avoid hardcoded duplicate costs or recipe text when adding new systems; if duplication is unavoidable for a prototype step, add a TODO to remove it.

## Testing Rules

After code changes, run the strongest relevant checks available:

```sh
git diff --check
bash -n scripts/qa/run_pre_commit_smoke.sh .githooks/pre-commit
rg -n ':=' scripts
scripts/qa/run_pre_commit_smoke.sh
```

- Treat `rg -n ':=' scripts` returning no matches as success.
- Run the headless smoke test before committing gameplay, UI, world, inventory, crafting, building, or QA changes.
- If documentation is touched, check that docs and UI-facing files do not accidentally contain Russian/Ukrainian text unless explicitly intended.
- Report any check that could not be run and why.

## Git Rules

- Do not revert user/editor changes unless the user explicitly asks.
- Be careful with `project.godot`: the Godot editor may rewrite InputMap formatting. Do not stage it unless the change is intentional and relevant.
- Stage only files that belong to the completed task.
- If the user expects repository work to be finished, commit and push after checks pass.
- Let the pre-commit hook run; do not bypass it unless the user explicitly asks and the reason is documented.

## Agent Delegation Rules

- When the user asks to create agents or work in parallel, split work into independent tasks with clear ownership.
- Keep documentation updates, TODO updates, changelog updates, final verification, commit, and push in the main agent unless the user says otherwise.
- Review agent changes before committing.
- Close completed agents after integrating their work.

## Final Response Checklist

In the final Russian response, include:

- short summary of implemented changes;
- documentation updates made;
- verification commands and results;
- commit hash and push status, if committed;
- any remaining dirty files or known risks.
