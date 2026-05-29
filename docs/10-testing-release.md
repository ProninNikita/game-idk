# Testing and Release

Status: `Draft`

## Goal

Testing should catch broken core loop behavior: gathering, crafting, building, automation, saving, night/threats.

## Test Pyramid for the Project

### Unit-Like Tests

For pure logic:

- inventory operations;
- item stack merge/split;
- recipe validation;
- craft cost checks;
- building placement rules;
- save migration;
- deterministic world generation.

### Scene Tests

For Godot scenes:

- player movement scene loads;
- building ghost validates placement;
- machine accepts input and produces output;
- UI opens/closes without errors.

### Automated Pre-Commit Smoke Test

The repository includes a headless gameplay smoke test:

```sh
scripts/qa/run_pre_commit_smoke.sh
```

The test loads the main scene, checks startup state, verifies shared data registry definitions, per-item stack sizes, resource drops and durability, verifies building scenes carry and apply definition ids, verifies typed inventory slot and item stack models, verifies inventory resize protection for occupied overflow slots, verifies atomic inventory removal and locked-slot protection, verifies time-of-day phase boundaries and dynamic advancement, moves the player, validates aim/facing behavior, verifies that the Multitool Cutter rejects empty-ground activation, verifies in-range cutter retargeting, verifies the Training Drone damage path, locks the cutter onto a resource while the button is held, verifies gradual cutter damage, verifies release stops damage, verifies beam steering and player movement while cutting, verifies ground drops and pickup, opens and clicks every current inventory category button, uses every current Building Create button, verifies failed building placement cost rollback including post-payment placement revalidation, places Furnace, Forge, Workbench, and Fence, opens station UI, clicks Load, Craft, Collect Outputs, and Close station buttons, verifies station recipe rows are reused during progress refreshes, fast-forwards station crafting, verifies outputs stay in station output slots until collection, verifies output overflow drops to the ground, checks station auto-close out of range, verifies inventory and station windows fit inside a 1024px viewport, verifies pause/resume behavior, and verifies building occupancy is released with refund drops when a building is destroyed.

Enable the versioned git hook once per clone:

```sh
git config core.hooksPath .githooks
```

After that, the smoke test runs before every commit. Use `SKIP_HEARTHLINE_SMOKE=1 git commit ...` only for emergency commits where the broken state is intentional and will be fixed immediately.

### Manual Playtests

For everything else:

- first day;
- first night;
- first automation;
- save/load after building;
- death/respawn;
- performance with many machines.

## Smoke Test Checklist

Before any build:

- project opens in the target Godot version;
- main scene runs without errors;
- a new game can start;
- player moves;
- a resource can be gathered;
- inventory works;
- an object can be built;
- save and load work;
- returning to menu does not break state;
- no red errors in Godot Output during 5 minutes of normal play.

## First Playable Readiness

Minimum readiness for the first playable build:

- the smoke test passes without failures;
- the core loop works from gathering to building to station crafting to output collection;
- inventory, station, build placement, pause, and normal play modes do not overlap;
- resource, building, station, and ground item counts remain consistent after destruction and collection;
- known limitations are documented in the changelog before sharing a build.

## Playtest Checklist: First 20 Minutes

Observe:

- did the player understand the first goal without explanation?
- did the player find food?
- did the player build a campfire?
- did the player understand night?
- did the player understand crafting?
- where did the first frustration occur?
- which elements did the player miss?

Post-playtest questions:

- What did you try to do that the game did not allow?
- Where was it unclear why something did not work?
- What did you want to automate first?
- Did night feel tense or dangerous?

## Performance Targets

For desktop MVP:

- 60 FPS on a mid-range machine;
- 500 simple buildings without noticeable slowdown;
- 1000 loose/conveyor items as a stress target after optimization pass;
- save/load under 3 seconds for a small world;
- no frame spikes when opening inventory/build menu.

These numbers will be refined after the real prototype.

## Save/Load Tests

Required scenarios:

- save near base;
- save while a machine is working;
- save with a blocked conveyor;
- save during night;
- save after player death;
- load old schema after migration;
- corrupted save handling.

## Godot Version Upgrade Regression

After updating Godot:

- open the project and save a copy;
- run smoke test;
- check tilemap;
- check input;
- check shaders/materials, if any;
- check exports;
- check save/load;
- record result in the decisions log.

## Demo Release Checklist

- version number set;
- changelog written;
- controls screen up to date;
- known issues list ready;
- debug shortcuts disabled or hidden;
- crash/error logs accessible;
- save folder documented;
- build tested on a clean machine;
- archive naming is consistent.

## Bug Report Template

```md
## Summary

## Build version

## Steps to reproduce
1.
2.
3.

## Expected

## Actual

## Save/screenshots/logs

## Severity
Critical / High / Medium / Low
```

## Severity

- Critical: crash, save corruption, cannot continue.
- High: breaks core loop or a major system.
- Medium: noticeable issue with a workaround.
- Low: polish, visual, minor UX.
