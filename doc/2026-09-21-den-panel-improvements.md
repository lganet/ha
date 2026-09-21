# Implementation Plan: Den NSPanel Dashboard Improvements & Light State Management

**Date**: 2026-09-21  
**Status**: Proposed  
**Branch**: `feature/den-panel-improvements`  
**Target Dashboard**: `dashboards/nspanel-den.yaml` (Sonoff NSPanel 120 Pro)

---

## 1. Overview & Goals

This plan addresses four key improvements requested for the Den NSPanel Dashboard:
1. **Move "Night Light"**: Relocate the Night Light card (`light.smart_fan_nightlight`) from the "Fan & Air" section into the "Lights" section.
2. **Combine Fan Scene & Fan Backlight**: Visually and structurally link the Fan Scene selector (`select.smart_fan_scene`) directly with the Fan Backlight card (`light.smart_fan_backlight`).
3. **Smart Light State Memory & Mutual Exclusivity (Fan Light vs. Night Light)**:
   - Preserve and restore the last-used color temperature (e.g., cool white) and dimmer (e.g., 40%) for the main Fan Light (`light.smart_fan_3`).
   - Prevent the Fan Light from being stuck in warm nightlight mode when turned back on or when "All Lights On" is triggered.
   - Ensure Night Light remembers its warm/hot color and dimmer level (e.g., 30%).
   - Make Fan Light and Night Light mutually exclusive so turning on one turns off the other, avoiding hardware state collisions on the Tuya fan controller.
   - Refactor "All Lights On" to exclude the Night Light so turning on room lights never activates night mode.
4. **Preserve External Govee App Settings**:
   - Ensure that whenever lighting attributes (custom colors, dynamic effects, or dimming levels) are altered via the official Govee app, turning lights off and back on via the NSPanel dashboard respects and restores those exact latest settings.

---

## 2. Technical Architecture & Analysis

### 2.1 Dashboard Layout Architecture

#### Section: Lights
Currently contains 5 cards in a 2-column grid:
- `light.h60b0` (Ceiling Light)
- `light.h6061` (Wall Lights)
- `light.h6076` (Floor Light)
- `light.smart_fan_backlight` (Fan Backlight)
- `light.smart_fan_3` (Fan Light)

**Proposed Structure**:
1. **Primary Room Lights**:
   - `light.h60b0` (Ceiling Light) — Tile card with brightness slider, tap for more-info.
   - `light.h6061` (Wall Lights) — Tile card with brightness slider, tap for more-info.
   - `light.h6076` (Floor Light) — Tile card with brightness slider, tap for more-info.
2. **Smart Fan White Lighting**:
   - `light.smart_fan_3` (Fan Light) — Tile card with brightness slider, color temp slider, and smart restoration logic.
   - `light.smart_fan_nightlight` (Night Light) — Tile card with toggle action and warm dimming restoration logic.
3. **Smart Fan Ambient & Scene Control (Combined Unit)**:
   - `vertical-stack` card containing:
     - Tile card for `light.smart_fan_backlight` (RGB ambient light with brightness slider).
     - Tile card for `select.smart_fan_scene` (Scene selector with `select-options` chips/dropdown).
   - This groups the RGB backlight and its corresponding animation/color scenes into a single stacked column.

#### Section: Fan & Air
Streamlined strictly for environmental air and fan motor controls:
- `fan.smart_fan` (Smart Fan) — Speed slider, direction toggle, preset modes.
- `fan.air_purifier_2` (Air Purifier) — Power toggle, preset modes dropdown.

---

### 2.2 Light State Restoration & Memory Logic

#### The Smart Fan Hardware Dynamic
The Tuya ceiling fan (`type: orison_chanfok_neo_fan_light`) uses a shared controller:
- DP 20: Master light power
- DP 21: Work mode (`white`, `colour`, `scene`)
- DP 22: Brightness (10–1000)
- DP 23: Color temperature (0 = 2700K warm, 1000 = 6500K cool)
- DP 24: Backlight RGB/HSV
- DP 53: Night Light mode (boolean toggle)

When `light.smart_fan_nightlight` (DP 53) turns on, the hardware switches the main LED array to warm 2700K at a dim output. If the user subsequently turns on `light.smart_fan_3` with a bare `light.turn_on`, the hardware remains in 2700K warm white rather than reverting to the user's previously configured cool white (e.g., 6000K, 40% brightness).

Furthermore, calling `light.turn_on` on `area_id: den` inadvertently turns on DP 53 alongside DP 20, causing unpredictable behavior and leaving the night light on during full room lighting.

#### State Tracking & Synchronization Mechanism
1. **Helpers**:
   - `input_number.den_fan_light_last_brightness`: Stores `light.smart_fan_3` brightness (0–100%).
   - `input_number.den_fan_light_last_color_temp`: Stores `light.smart_fan_3` color temperature in Kelvin (3000K–6500K, default 6000K).
   - `input_number.den_night_light_last_brightness`: Stores user's desired Night Light brightness (default 30%).
2. **State Tracking Automation (`automation.den_record_light_states`)**:
   - Triggers on state changes of `light.smart_fan_3` when state is `on`.
   - Records active `brightness` and `color_temp_kelvin` into the helpers only when Night Light is `off`.
3. **Mutual Exclusivity & Smart Restoration Automation (`automation.den_fan_light_mode_controller`)**:
   - **Trigger 1**: `light.smart_fan_nightlight` turns `on`.
     - Action: Turn off `light.smart_fan_3`. Ensure warm color temp (2700K/3000K) and nightlight brightness (30% or saved helper).
   - **Trigger 2**: `light.smart_fan_3` turns `on`.
     - Action: Turn off `light.smart_fan_nightlight`. Apply saved cool color temperature and saved brightness from helpers.
4. **Dedicated Room Lighting Script (`script.den_all_lights_on`)**:
   - Turns on `light.h60b0`, `light.h6061`, `light.h6076`, and `light.smart_fan_3` (with restored state).
   - Explicitly ensures `light.smart_fan_nightlight` is `off`.
   - Update NSPanel "All Lights On" button to invoke `script.den_all_lights_on`.

---

### 2.3 Govee Light App State Respect

`govee_light_local` receives UDP broadcasts and polls Govee hardware on LAN.
- When colors, DIY effects, or dimming changes are applied in the Govee mobile app, the hardware stores these in its non-volatile controller memory.
- Sending a bare `light.turn_on` (without `brightness`, `rgb_color`, or `color_temp` arguments) commands the Govee hardware via UDP `{"msg":{"cmd":"turn","data":{"value":1}}}`. The Govee hardware will wake up resuming its active scene, DIY effect, or custom palette.
- NSPanel buttons and scripts will invoke bare `turn_on` commands for Govee entities, avoiding overriding their state unless the user intentionally drags a brightness slider.

---

## 3. Implementation Steps

1. **Create State Persistence Helpers**:
   - `input_number.den_fan_light_last_brightness`
   - `input_number.den_fan_light_last_color_temp`
   - `input_number.den_night_light_last_brightness`
2. **Implement Automations & Scripts**:
   - Automation for recording fan light state when active.
   - Automation for mutually exclusive fan light / night light switching with state restoration.
   - Script `script.den_all_lights_on` for whole-room activation without night light conflict.
3. **Update NSPanel Den Dashboard (`dashboards/nspanel-den.yaml`)**:
   - Relocate `light.smart_fan_nightlight` into Lights section.
   - Group `light.smart_fan_backlight` and `select.smart_fan_scene` inside a `vertical-stack`.
   - Update "All Lights On" tap action to call `script.den_all_lights_on`.
4. **Sync with Home Assistant Storage Mode**:
   - Push updated dashboard config via `ha_config_set_dashboard`.
5. **Update Project Version & Documentation**:
   - Bump version in `VERSION` to `0.3.0` (MINOR: new feature automations, scripts, and layout restructuring).
   - Document changes in `CHANGELOG.md`.

---

## 4. Verification Plan

1. **Dashboard Structure Verification**:
   - Validate YAML syntax of `dashboards/nspanel-den.yaml`.
   - Confirm card order and visual grouping on the NSPanel 120 Pro.
2. **Fan Light vs. Night Light Mutual Exclusivity**:
   - Set Fan Light to cool white (6000K, 40%). Turn on Night Light. Confirm Fan Light turns off and Night Light engages in warm 30% mode.
   - Turn Fan Light back on. Confirm Night Light turns off and Fan Light restores 6000K cool white at 40%.
3. **All Lights On Test**:
   - Trigger "All Lights On" from NSPanel. Confirm ceiling, wall, floor, and fan lights turn on, while Night Light remains OFF.
4. **Govee App Synchronization**:
   - Change Govee light to an animated scene/effect in the Govee app. Turn it off from NSPanel. Turn it on from NSPanel. Confirm it resumes the dynamic effect without resetting to plain white.
