# Implementation Plan: Den Panel Govee Cloud Integration & Lighting State Preservation

**Date**: 2026-09-26  
**Status**: Approved  
**Target Hardware**: Sonoff NSPanel 120 Pro (Den Panel)  
**Location**: Den room  

---

## 1. Overview & Background

Following the migration from the local Govee integration (`govee_light_local`) to the HACS **Govee Cloud Integration** (`goveelife` / Govee API):
1. **Broken Dashboard Cards**:
   - The Den Panel dashboard (`dashboards/nspanel-den.yaml`) displays 3 `Entity not found` warnings.
   - The former entities (`light.h60b0`, `light.h6061`, `light.h6076`) were removed and replaced by Govee Cloud integration entities:
     - **Den Floor Lamp** (Model `H60B0`, 23 entities)
     - **Floor Lamp** (Model `H6076`, 19 entities)
     - **Office LEDs** (Model `H6061`, 27 entities)
2. **Light Count Badge Explosion**:
   - The "All Lights Off" badge shows **35 lights**, because the HACS Govee Cloud integration exposes every individual segment (Segments 1–8), sub-light (Side light, Bottom light, Ripple light), and effect as separate `light` entities in the `den` area.
   - The badge template (`templates/den_sensors.yaml`) uses `area_entities('den') | selectattr('domain', 'eq', 'light')`, which counts all 35+ segment entities individually.
3. **Lighting State Preservation ("All Lights Off" / "All Lights On")**:
   - The user requires the dashboard to represent each physical fixture cleanly.
   - For Den Floor Lamp, the primary lamp dimmer should be displayed alongside direct controls for physical sub-lights (Side Light, Bottom Light, Ripple Light, DreamView), while keeping the 8 segments cleanly hidden.
   - When pressing "All Lights Off", Home Assistant must **save the current configuration and status** of all active sub-lights, segments, and settings across all devices.
   - When pressing "All Lights On", Home Assistant must **restore those exact configurations** rather than resetting them to generic defaults.

---

## 2. Technical Architecture

### 2.1 State Preservation Architecture (`scene.create`)
To remember the full multi-segment and multi-light configuration without hardcoding or overwriting user preferences:
1. **Dynamic Snapshot on "All Lights Off"**:
   - Implemented via `script.den_all_lights_off` (`scripts/den_all_lights_off.yaml`).
   - Checks if any lights in the Den area are currently `on`.
   - If lights are active, creates an in-memory snapshot with `scene.create`:
     ```yaml
     action: scene.create
     data:
       scene_id: den_lights_snapshot
       snapshot_entities: >-
         {{ expand(area_entities('den')) | selectattr('domain', 'eq', 'light') | map(attribute='entity_id') | list }}
     ```
   - This records the exact state (power, brightness, RGB color, color temp, and active segments/sub-lights) in memory under `scene.den_lights_snapshot`.
   - Then turns off all lights in the Den area (`light.turn_off` on `area_id: den`) and ensures night light helper is reset.

2. **State Restoration on "All Lights On"**:
   - Implemented via `script.den_all_lights_on` (`scripts/den_all_lights_on.yaml`):
     - Turns off `input_boolean.den_night_light_active` to ensure night mode is disengaged.
     - Checks if `scene.den_lights_snapshot` exists:
       - If yes: invokes `scene.turn_on` on `scene.den_lights_snapshot`. All segments, side lights, base lights, and strip segments resume their previous states.
       - If no (e.g. after HA restart or initial run): turns on the primary master light entities with bare `light.turn_on` calls (allowing Govee hardware memory to restore last DIY/app mode) and turns on `light.den_fan_light`.

---

### 2.2 Light Count Badges Refactoring (`templates/den_sensors.yaml`)
The Den lighting is grouped into **4 logical fixtures**:
1. **Den Floor Lamp** (`light.den_floor_lamp`, plus sub-lights & segments)
2. **Floor Lamp** (`light.floor_lamp`, plus segments)
3. **Office LEDs** (`light.office_leds`, plus segments)
4. **Smart Fan** (`light.smart_fan_3`, `light.smart_fan_backlight`, `light.smart_fan_nightlight`)

**Logic**:
- **`sensor.den_lights_on`**:
  - Each fixture counts as **1** if its master entity OR any of its sub-lights/segments are `on`.
  - Max count: **4**.
- **`sensor.den_lights_off`**:
  - Each fixture counts as **1** if all its sub-lights and master entity are `off`.
  - Max count: **4**.

---

### 2.3 Dashboard Configuration Updates (`dashboards/nspanel-den.yaml`)
1. **All Lights Buttons**:
   - "All Lights Off" tap action calls `script.den_all_lights_off`.
   - "All Lights On" tap action calls `script.den_all_lights_on`.
2. **Den Floor Lamp Stacked Card (`custom:stack-in-card`)**:
   - Primary Tile for `light.den_floor_lamp` with brightness slider and `more-info` tap action.
   - Sub-grid with direct controls for:
     - Side Light (`light.den_floor_lamp_side_light`)
     - Bottom Light (`light.den_floor_lamp_bottom_light`)
     - Ripple Light (`light.den_floor_lamp_ripple_light`)
     - DreamView (`switch.den_floor_lamp_dreamview`)
3. **Primary Room Lights**:
   - `light.floor_lamp` (Floor Lamp) with brightness slider.
   - `light.office_leds` (Office LEDs) with brightness slider.
   - `light.den_fan_light` (Fan Light).
   - `light.den_night_light` (Night Light).
   - `custom:stack-in-card` for Fan Backlight + Fan Scene.
