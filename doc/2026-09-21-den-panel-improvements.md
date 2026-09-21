# Implementation Plan: Den NSPanel Dashboard Improvements & Light State Management

**Date**: 2026-09-21  
**Status**: Completed & Verified  
**Branch**: `feature/den-panel-improvements`  
**Target Dashboard**: `dashboards/nspanel-den.yaml` (Sonoff NSPanel 120 Pro)

---

## 1. Overview & Goals

This plan addresses key improvements requested for the Den NSPanel Dashboard:
1. **Move "Night Light"**: Relocate the Night Light card from the "Fan & Air" section into the "Lights" section.
2. **Combine Fan Scene & Fan Backlight**: Visually and structurally link the Fan Scene selector (`select.smart_fan_scene`) directly with the Fan Backlight card (`light.smart_fan_backlight`) using `custom:stack-in-card`.
3. **Smart Light State Memory & Mutual Exclusivity (Fan Light vs. Night Light)**:
   - Preserve and restore the last-used color temperature (e.g., cool white 6000K-6500K) and dimmer (e.g., 77% or 40%) for the main Fan Light.
   - Provide independent dimmer and color temperature controls for Night Light (`light.den_night_light`) as well.
   - Ensure Night Light remembers its warm color (3000K) and dimmer level (e.g., 10% - 30%).
   - Seamless transition: when switching between Fan Light and Night Light, the lamp smoothly transitions to the requested mode's brightness and color temperature without shutting off the light fixture or causing race-condition loops.
   - Mutual exclusivity: on the dashboard, when Fan Light is active, Night Light reflects OFF; when Night Light is active, Fan Light reflects OFF; when the light is turned off, both reflect OFF.
   - Refactor "All Lights On" to turn on room lights and Fan Light (with cool white memory) while keeping Night Light off.
4. **Preserve External Govee App Settings**:
   - Ensure that whenever lighting attributes (custom colors, dynamic effects, or dimming levels) are altered via the official Govee app, turning lights off and back on via the NSPanel dashboard respects and restores those exact latest settings without overwriting them.

---

## 2. Technical Architecture & Resolution

### 2.1 The Tuya Hardware Dynamic & Root Cause Analysis
The Tuya ceiling fan (`type: orison_chanfok_neo_fan_light`) uses a single white light channel on the hardware:
- DP 20: Master light power switch (`light.smart_fan_3`)
- DP 21: Work mode (`white`, `colour`, `scene`)
- DP 22: Brightness (10–1000)
- DP 23: Color temperature (0 = 2700K warm, 1000 = 6500K cool)
- DP 53: Fixed nightlight mode switch (`light.smart_fan_nightlight`)

**Root Cause of the Previous Issue**:
1. When DP 53 was turned on by an automation, DP 20 also reported `power: true` in hardware. The previous automation (`automation.den_fan_light_mode_controller`) attempted to enforce exclusivity by calling `light.turn_off` on `light.smart_fan_3` whenever Night Light turned on.
2. Because DP 20 is the master power switch for the whole fixture, turning off DP 20 cut power to the lamp entirely, which immediately forced DP 53 off as well.
3. Furthermore, when DP 53 triggered, `light.smart_fan_3` state changes triggered the other automation branch, creating an immediate cascade that flipped Night Light back off and restored Fan Light cool white.
4. Additionally, DP 53 on the Tuya fan is fixed in hardware and does not expose brightness or color temperature adjustments.

### 2.2 Template Light Architecture
To provide full independent dimmer and color temperature controls for both modes without hardware conflicts:
1. **Helper Entities**:
   - `input_boolean.den_night_light_active`: Flags whether the lamp is in Night Light mode (`on`) or normal Fan Light mode (`off`).
   - `input_number.den_fan_light_last_brightness` (1–100%, default 77%).
   - `input_number.den_fan_light_last_color_temp` (3000K–6500K, default 6000K).
   - `input_number.den_night_light_last_brightness` (1–100%, default 10%–30%).
   - `input_number.den_night_light_last_color_temp` (3000K–6500K, default 3000K).
2. **Template Light `light.den_fan_light` (Fan Light)**:
   - State: `{{ is_state('light.smart_fan_3', 'on') and is_state('input_boolean.den_night_light_active', 'off') }}`
   - Features: Brightness slider & color temperature slider.
   - On activation: Clears `den_night_light_active`, turns on `light.smart_fan_3` with saved cool settings.
3. **Template Light `light.den_night_light` (Night Light)**:
   - State: `{{ is_state('light.smart_fan_3', 'on') and is_state('input_boolean.den_night_light_active', 'on') }}`
   - Features: Brightness slider & color temperature slider.
   - On activation: Sets `den_night_light_active`, turns on `light.smart_fan_3` with saved warm settings.
4. **State Tracker Automation (`automation.den_fan_light_state_tracker`)**:
   - Syncs any manual adjustments (from dashboard or physical remote) to the appropriate helper based on `input_boolean.den_night_light_active`.
5. **Script `script.den_all_lights_on`**:
   - Clears `den_night_light_active`.
   - Sends bare `light.turn_on` to Govee lights (`light.h60b0`, `light.h6061`, `light.h6076`) to preserve active Govee app scene/dimmer settings.
   - Turns on `light.den_fan_light` with restored cool white settings.

---

## 3. Dashboard Configuration (`dashboards/nspanel-den.yaml`)

- Night Light relocated to Lights section alongside Fan Light.
- Both Fan Light and Night Light have full brightness and color temperature controls (`features: light-brightness, light-color-temp`).
- Fan Backlight and Fan Scene combined seamlessly into a single vertical stack card (`custom:stack-in-card`).
- Fan & Air section streamlined for fan speed, fan direction, and air purifier modes.

---

## 4. Verification Results

- [x] **Night Light Activation**: Turns on warm 3000K dim light, Night Light tile shows ON, Fan Light tile shows OFF.
- [x] **Night Light Dimming**: Dragging dimmer updates `input_number.den_night_light_last_brightness` and physical bulb.
- [x] **Fan Light Switch**: Tapping Fan Light smoothly transitions to cool white (6493K, 77%), Night Light tile flips to OFF, Fan Light tile flips to ON. The lamp does not shut off.
- [x] **Night Light State Restoration**: Switching back to Night Light restores the exact saved warm dimmer (e.g. 30%, 3000K).
- [x] **All Lights Off**: Shuts down all 5 lights in the Den; both Fan Light and Night Light tiles reflect OFF.
- [x] **All Lights On**: Restores all Govee lights in their previous app state and restores Fan Light in cool white.
