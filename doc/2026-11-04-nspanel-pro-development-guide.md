# Sonoff NSPanel Pro Dashboard & Hardware Development Guide

This document captures hard-won architectural principles, hardware quirks, and UI best practices discovered while building and refining the Sonoff NSPanel Pro 120 dashboard (`dashboards/nspanel-office.yaml`). Use this guide when building dashboards for subsequent panels (e.g., Main Bedroom, Kitchen, Living Room).

---

## 1. Hardware Profile & Screen Geometry

You are using the **Sonoff NSPanel Pro 120 Type** (US / North American vertical wall box standard):

| Model | Form Factor | Display Size | Physical Resolution | Typical Webview Viewport |
| :--- | :--- | :--- | :--- | :--- |
| **NSPanel Pro 120** *(Yours)* | US Rectangular (120mm) | 4.7 inches (Portrait) | **750 × 1334 px** | **~375 × 667 px** (at 2x density) |
| **NSPanel Pro 86** | EU/UK Square (86mm) | 3.95 inches (Square) | 480 × 480 px | ~360–400 px |
| **NSPanel (Standard)** | US/EU with 2 Buttons | 3.5 inches (Landscape) | 480 × 320 px | ~480 × 320 px |

### Viewport & Grid Geometry on the NSPanel Pro 120:
- **Orientation**: Portrait (vertical).
- **Usable Webview Width**: ~360–375px after container padding.
- **Two-Column Grid (`columns: 2`)**:
  - Each column is only **~165–175px wide**.
  - This narrow width makes vertical icon-over-text stacking prone to clipping.
- **Touch Target Heights**:
  - Primary single-action tiles: `height: 56px` to `60px`.
  - Half-width pill buttons (e.g., Presets): `height: 44px` to `46px`.
  - Hero master buttons (e.g., Master Lights Toggle): `height: 130px` to `140px`.
  - Icon sizes: `18px`–`24px` for pills/tiles, `64px`–`72px` for master hero buttons.

---

## 2. Layout, Typography & Ellipsis Prevention

### Never Stack Icons Over Text in Half-Width Buttons
- In a ~200px column, vertical stacking (`grid-template-areas: "i" "n"`) severely constrains the horizontal width of text.
- If text exceeds ~10–12 characters, Home Assistant / `custom:button-card` cuts it off with an ellipsis (`Day Pr...`, `Night Pr...`).
- **Best Practice**: Always configure horizontal pill layout:
  ```yaml
  type: custom:button-card
  layout: icon_name
  styles:
    card:
      - height: 44px
      - padding: 0 10px
      - border-radius: 12px
    icon:
      - width: 18px
      - height: 18px
      - margin-right: 6px
    name:
      - font-size: 13px
      - font-weight: 600
  ```

### Avoid Duplicate Emojis in Names
- If a card specifies an icon (e.g., `icon: mdi:white-balance-sunny`), **do not** include an emoji in the `name:` field (e.g. `name: "☀️ Day Preset"`).
- The emoji consumes ~16–20px of width, pushes text into truncation, and creates a redundant "two suns" appearance.
- Use clean strings: `name: "Day Preset"`.

---

## 3. Audio Feedback Architecture (Touch vs. Motion)

Physical wall panels feel significantly more premium with tactile audible feedback upon touch, but **automated motion detection must remain completely silent**.

### The Pattern:
1. All underlying room scripts accept an optional `sound` boolean field (defaulting to `false`):
   ```yaml
   fields:
     sound:
       description: "Whether to play audio feedback chime on NSPanel"
       default: false
       selector:
         boolean: {}
   ```
2. When called by automations (e.g. FP300 presence detected / cleared):
   - Omit `sound` or pass `sound: false`. The room transitions silently.
3. When called by NSPanel dashboard cards:
   - Configure `tap_action`:
     ```yaml
     tap_action:
       action: call-service
       haptic: selection
       service: script.office_activate_day_preset
       data:
         sound: true
     ```
4. Centralized Sound Dispatcher (`scripts/nspanel_audio_feedback.yaml`):
   - Maps tones to Google Action audio URIs (`https://actions.google.com/sounds/v1/...`).
   - Plays immediately via `button.<panel_id>_speaker_start`.
   - Supports instant cutoff via `button.<panel_id>_speaker_stop` when tones or warnings clear.

---

## 4. Screen Power, Screensaver & Alert Loops

The NSPanel Pro exposes several Zigbee2Cube entities governing display and sleep:

- `switch.<panel_id>_screen_state` (Screen Power): Turns the LCD backlight on/off.
- `number.<panel_id>_custom_duration` (Custom Duration): Auto-sleep / screensaver timeout in seconds (min: 1s, max: 1800s / 30m; default: 60s).
- `switch.<panel_id>_proximity_wake`: Automatically wakes the screen when a hand approaches.
- `switch.<panel_id>_screen_automatic`: Automatic brightness based on ambient light.

### Keeping the Screen Awake During Security Warnings
- **Hardware Quirk**: If you only call `switch.turn_on` once when an alert starts, the panel's internal timer (`custom_duration`) will time out after 60 seconds of no physical touch and revert the screen to the clock screensaver.
- **The Fix**: Pulse `switch.turn_on` **inside the repeat loop** of the alert automation:
  ```yaml
  sequence:
    - repeat:
        while:
          - condition: state
            entity_id: binary_sensor.active_security_warnings
            state: "on"
        sequence:
          - action: switch.turn_on
            target:
              entity_id: switch.zigbee2cube_<id>_screen_state
          - action: script.nspanel_audio_feedback
            data:
              tone: warning
          - delay:
              seconds: "{{ states('input_number.warning_alert_repeat_interval') | int(30) }}"
  ```
  Since the repeat interval (e.g. 30s) is shorter than `custom_duration` (60s), the screen remains actively illuminated displaying the warning banner until all warnings clear.

---

## 5. What is "Turbo Mode" (`transmit_power`)?

- Entity: `switch.zigbee2cube_<id>_transmit_power` ("Wall Panel Turbo").
- **Function**: Boosts the NSPanel Pro's internal Zigbee coordinator radio output from standard (+10 dBm) to maximum power (+20 dBm).
- **Rule of Thumb**: **Leave it OFF** unless you have battery Zigbee sensors directly paired to the panel that suffer from packet loss. Max power generates extra RF noise that can degrade 2.4 GHz Wi-Fi channels (especially Wi-Fi channels 1, 6, and 11).

---

## 6. Dynamic Security Warnings & Template Helpers

When building perimeter warnings (doors unlocked, gates/windows open for extended periods):

### Dynamic Delays in Helpers
- Home Assistant UI Template Binary Sensor helpers have an internal `additional_options.delay_on` setting that only accepts static durations.
- To allow users to configure threshold minutes via sliders (`input_number` helpers):
  1. Clear `additional_options.delay_on` (set `{hours: 0, minutes: 0, seconds: 0}`).
  2. Implement elapsed time math in the `state` template:
     ```jinja2
     {% set t = now() %}
     {% set dur = states('input_number.warning_patio_door_unlocked_delay') | float(30) * 60 %}
     {{ is_state('lock.patio_door_lock', 'unlocked') and (t - states.lock.patio_door_lock.last_changed).total_seconds() >= dur }}
     ```

### Dynamic Dashboard Warning Banners
- Standard `tile` cards do not support template strings in `name:`.
- Use `custom:button-card` to dynamically display the configured threshold:
  ```yaml
  name: >-
    [[[
      var min = states['input_number.warning_patio_door_unlocked_delay'] ? Math.round(states['input_number.warning_patio_door_unlocked_delay'].state) : 30;
      return `Warning: Patio Door Unlocked > ${min}m`;
    ]]]
  state_display: >-
    [[[
      return entity.state.charAt(0).toUpperCase() + entity.state.slice(1);
    ]]]
  ```

---

## 7. Resilient UI Patterns (Graceful Failure)

### Always Wrap Cloud Integrations in Conditional Cards
- Cloud weather integrations (like Met.no / `weather.forecast_home`) or external cloud APIs occasionally experience brief server rate-limiting or network drops, rendering the entity `unavailable`.
- A raw `weather-forecast` card will display an ugly full-width red/gray error: `"Entity is currently unavailable"`.
- **Best Practice**: Wrap potentially flaky entities in a conditional card checking `state_not: unavailable` and `state_not: unknown`:
  ```yaml
  - type: conditional
    conditions:
      - condition: state
        entity: weather.forecast_home
        state_not: unavailable
      - condition: state
        entity: weather.forecast_home
        state_not: unknown
    card:
      type: weather-forecast
      entity: weather.forecast_home
      forecast_type: daily
  ```
  If the API drops, the card cleanly disappears; when the API recovers, the forecast seamlessly re-appears.

---

## 8. Dashboard Synchronization & Cache Management

- **Storage Mode**: NSPanel Pro dashboards should be maintained in Home Assistant storage mode (`ha_config_set_dashboard`) while mirroring clean YAML in Git (`dashboards/nspanel-<area>.yaml`).
- **Aggressive Webview Caching**: The embedded Android webview on the NSPanel Pro aggressively caches Lovelace resources and card structures:
  - After deploying changes via MCP, the user must **swipe down from the top edge** or tap the top-right menu and select **Refresh**.
  - If a change is not visible, check whether the URL configured on the panel matches the updated dashboard (`nspanel-<area>`).
