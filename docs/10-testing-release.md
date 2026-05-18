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
