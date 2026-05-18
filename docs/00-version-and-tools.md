# Versions and Tools

Status: `Draft`

## Godot Check on May 18, 2026

According to the official Godot archive:

- latest stable version: **Godot 4.6.2-stable**, released on April 1, 2026;
- latest release candidate: **Godot 4.6.3-rc2**, released on May 16, 2026;
- latest beta branch: **Godot 4.7-beta2**, released on May 11, 2026.

Project decision: **start on Godot 4.6.2-stable** or the latest stable patch in the `4.6.x` branch once `4.6.3` becomes stable. Do not use beta or RC builds as the main project version unless there is a specific feature that justifies the risk.

Sources:

- https://godotengine.org/download/archive/
- https://docs.godotengine.org/en/stable/about/release_policy.html

## Local Environment

Earlier local check:

```text
/Applications/Godot.app/Contents/MacOS/Godot --version
4.3.stable.official.77dcf97d8
```

A later check during the first Godot skeleton setup showed that this path no longer exists. Install or use Godot 4.6.x stable before runtime smoke testing.

Recommendation: update the local Godot installation to **4.6.2-stable** or a newer stable `4.6.x` patch before regular development.

## Base Stack

- Engine: Godot 4.6.x stable.
- Language: GDScript for the first prototype.
- Rendering: 2D top-down with `Camera2D`.
- Physics: built-in Godot 2D physics, no external engine.
- Data format: `.tres`/`.res` for Godot resources; JSON/CSV only for external balance tables if needed.
- Save format: versioned JSON or binary Resource save; decide after the first save prototype.
- Version control: Git.

## Why GDScript First

GDScript is faster for iteration in Godot, integrates well with editor tooling, and is enough for MVP-level systems. C# can be considered later if heavy simulation, C# editor tooling, or stronger large-scale typing becomes necessary.

## Godot Update Rules

Updating is allowed:

- before a milestone starts;
- after making a backup or commit;
- after reading release notes;
- when the target version is stable;
- when the project passes a smoke test after opening in the new version.

Do not update:

- during build stabilization;
- right before a playtest without time for regression checks;
- to beta/RC builds without a separate experimental branch.

## Minimum Development Tools

- Godot 4.6.x stable.
- Git.
- Code editor: Godot script editor, VS Code, or Cursor.
- Balance tables: LibreOffice, Google Sheets, or CSV in the repository.
- Diagrams: Mermaid in Markdown or Excalidraw.
- Task tracker: Markdown backlog at the start; GitHub Issues or Linear can be adopted later.

## Project Settings to Lock Early

- Window stretch mode: `canvas_items`.
- Window stretch aspect: `expand`.
- Physics ticks per second: start with the default and change only after profiling.
- Input map: define action names early; do not bind gameplay directly to specific keys.
- Rendering: keep the 2D pipeline simple until custom shaders are truly needed.

## Target Platforms

Start:

- Windows desktop.
- macOS desktop.
- Linux desktop.

Later:

- Steam Deck, if controls and UI work well with gamepad.

Not planned at the start:

- mobile;
- web export;
- console ports.
