# Implementation Plan: NSPanel Touch-Only Audio Feedback & Security Warning Alerts

**Date**: 2026-11-04  
**Author**: Antigravity  
**Branch**: `feature/office-nspanel-redesign`

## Objective
1. **Touch-Only Audio Feedback**: Ensure the NSPanel Pro speaker chimes exclusively when buttons are physically tapped on the panel. Suppress all chimes during automated presence transitions (FP300 motion detection / clearing / workday morning transition).
2. **Security Warning Screen Awakening**: Automatically turn ON the NSPanel Pro screen (`switch.zigbee2cube_1002a32fc7_screen_state`) when perimeter security warnings (`binary_sensor.active_security_warnings`) become active, and turn the screen OFF when all warnings are resolved.
3. **Repeating Gentle Warning Alert**: When security warnings are active, play a gentle repeating chime (two-tone chime every 30 seconds) through the NSPanel Pro speaker that halts immediately once perimeter warnings clear.

---

## Resources Affected
- [`scripts/nspanel_audio_feedback.yaml`](file:///Users/gustavo/src/ha/scripts/nspanel_audio_feedback.yaml): Add support for `warning` tone (`doors/doorbell_chime.ogg`) and `stop` action (`button.zigbee2cube_1002a32fc7_speaker_stop`).
- [`scripts/den_all_lights_on.yaml`](file:///Users/gustavo/src/ha/scripts/den_all_lights_on.yaml): Add `sound: false` boolean field (default `false`); only chime if `sound == true`.
- [`scripts/den_all_lights_off.yaml`](file:///Users/gustavo/src/ha/scripts/den_all_lights_off.yaml): Add `sound: false` boolean field (default `false`); only chime if `sound == true`.
- [`scripts/office_activate_night_preset.yaml`](file:///Users/gustavo/src/ha/scripts/office_activate_night_preset.yaml): Add `sound: false` boolean field (default `false`); only chime if `sound == true`.
- [`scripts/office_activate_day_preset.yaml`](file:///Users/gustavo/src/ha/scripts/office_activate_day_preset.yaml): Forward `sound` parameter to `den_all_lights_on`.
- [`scripts/office_adaptive_lights_toggle.yaml`](file:///Users/gustavo/src/ha/scripts/office_adaptive_lights_toggle.yaml): Pass `sound: true` when called from user tap.
- [`dashboards/nspanel-office.yaml`](file:///Users/gustavo/src/ha/dashboards/nspanel-office.yaml): Pass `sound: true` in `tap_action` for Day and Night preset buttons.
- [`automations/nspanel_security_warning_alert.yaml`](file:///Users/gustavo/src/ha/automations/nspanel_security_warning_alert.yaml): New automation controlling screen power and repeating warning sound loop.

---

## Detailed Implementation Steps
1. **Update `scripts/nspanel_audio_feedback.yaml`**:
   - Add `warning` and `stop` tone options.
   - Map `warning` to `https://actions.google.com/sounds/v1/doors/doorbell_chime.ogg`.
   - When `tone == 'stop'`, call `button.press` on `button.zigbee2cube_1002a32fc7_speaker_stop`.
2. **Add `sound` Guard to Light Control Scripts**:
   - In `den_all_lights_on.yaml`, `den_all_lights_off.yaml`, `office_activate_night_preset.yaml`: wrap `action: script.nspanel_audio_feedback` with `if: "{{ sound | default(false) }}"`.
   - Default `sound` to `false` so automated executions (e.g. from `automation.den_presence_adaptive_lighting`) are completely silent.
3. **Configure NSPanel Touch Targets**:
   - In `scripts/office_adaptive_lights_toggle.yaml`: supply `data: { sound: true }`.
   - In `dashboards/nspanel-office.yaml`: supply `data: { sound: true }` on `office_activate_day_preset` and `office_activate_night_preset` tap actions.
4. **Create Security Warning Automation**:
   - Create `automations/nspanel_security_warning_alert.yaml`.
   - Mode `restart`.
   - Trigger on `binary_sensor.active_security_warnings` -> `on` and `off`.
   - When `on`: turn on `switch.zigbee2cube_1002a32fc7_screen_state`, repeat chime every 30s while active.
   - When `off`: stop chime, turn off `switch.zigbee2cube_1002a32fc7_screen_state`.
5. **Deploy & Validate**:
   - Validate YAML syntax with `ruby -ryaml`.
   - Deploy automations and scripts to live Home Assistant using MCP tools.
   - Verify states in Home Assistant.
6. **Documentation & Changelog**:
   - Update `CHANGELOG.md`.
   - Commit and push to `feature/office-nspanel-redesign`.
