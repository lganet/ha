# Implementation Plan: Office Presets Persistence, Wall LEDs Night Lighting & NSPanel Audio Chime Fix

## Context & Motivation
1. **Audio Feedback**: When pressing "Turn Lights On" or "Turn Lights Off" from the NSPanel Pro master card, the audio chime no longer plays. This occurred because live Home Assistant script definitions for `office_adaptive_lights_toggle` and `office_activate_day_preset` omitted the `sound: true` payload, while `den_all_lights_on` and `den_all_lights_off` default `sound` to `false`.
2. **Wall LEDs / Night Preset**: After saving the preset on NSPanel with Wall LEDs (`light.office_desk_leds`) on, both FP300 presence and the NSPanel "Night Lights" button turned the Wall LEDs off. This happened because `scene.create` generates in-memory scenes that are deleted on Home Assistant restarts/reloads. When the scene was missing, `script.office_activate_night_preset` fell back to a hardcoded `else:` block that explicitly turned off `light.office_desk_leds`.
3. **Save Button Usability**: The "Save Day Lights" and "Save Night Lights" buttons in `dashboards/nspanel-office.yaml` were conditionally disabled using `pointer-events: none` whenever `input_boolean.office_*_preset_changed` was `off`, preventing users from intentionally saving manual lighting adjustments at will.

## Proposed Changes

### 1. `scripts/office_activate_night_preset.yaml`
- Update the fallback (`else:`) block to include `light.office_desk_leds` under `light.turn_on` rather than `light.turn_off`.
- Ensure Wall LEDs remain illuminated in ambient mode during night transitions when custom scenes are absent.

### 2. `scripts/office_save_day_preset.yaml` & `scripts/office_save_night_preset.yaml`
- Include `light.office_ceiling_fan_backlight` in `snapshot_entities` so all ambient fixtures on the dashboard are captured.

### 3. `scripts/office_adaptive_lights_toggle.yaml` & `scripts/office_activate_day_preset.yaml`
- Ensure `sound: "{{ sound | default(true) }}"` is propagated cleanly to `den_all_lights_off`, `office_activate_day_preset`, and `den_all_lights_on`.

### 4. `dashboards/nspanel-office.yaml`
- In master lights toggle card (`script.office_adaptive_lights_toggle`), add explicit `data: { sound: true }` to guarantee audio feedback on panel touch.
- In Presets Management cards, remove `pointer-events: none` so users can tap "Save Day Lights" or "Save Night Lights" at any time to re-snapshot current light states.

### 5. Persistent Scene Registration in Live Home Assistant
- Register persistent Home Assistant scene configurations for `scene.office_night_preset` and `scene.office_day_preset` using `ha_config_set_scene`, ensuring they survive system restarts.
- Sync live Home Assistant scripts (`ha_config_set_script`) to reflect the updated configurations.

### 6. Versioning & Documentation
- Bump `VERSION` (PATCH increment: 0.13.1 -> 0.13.2).
- Add changelog entry in `CHANGELOG.md`.

## Verification Plan
1. Validate YAML syntax for all modified scripts and dashboard.
2. Verify live script execution in Home Assistant:
   - Call `script.office_adaptive_lights_toggle` and confirm chime triggers on NSPanel.
   - Call `script.office_activate_night_preset` and confirm Wall LEDs (`light.office_desk_leds`) remain ON.
   - Test Save buttons and confirm scenes are properly updated and persistent.
