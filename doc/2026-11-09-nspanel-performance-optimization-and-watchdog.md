# Implementation Plan: NSPanel Dashboard Performance Optimization & Always-On Fan Relay Watchdog

- **Date:** 2026-11-09
- **Author:** Antigravity & User Pair Programming
- **Scope:** 
  1. NSPanel Dashboard Streamlining (Option A: Clean & Fast).
  2. Creation of unified Shared Diagnostics Dashboard (`dashboards/nspanel-system-diagnostics.yaml`).
  3. Main Bedroom Fan Line Relay (`light.main_bedroom_light_1`) Always-On Watchdog & Voice Isolation.

---

## 1. Context & Motivation

### A. NSPanel Pro Performance Issues
The Sonoff NSPanel Pro 120 devices in the Office and Main Bedroom were exhibiting significant lag and delayed dashboard updates.
- **Root Cause:**
  - Both dashboards were monolithic files containing 8 views and 230+ cards (over 3,500 lines of YAML each).
  - Background WebSocket polling from high-frequency entities (e.g. smart plug wattage sensors reporting every 1–3s on the Energy tab, closet thermal metrics on Homelab tab) saturated the single-threaded JavaScript event loop in Android WebView on the low-power Cortex-A35 processor.
  - Client-side JavaScript evaluation in `custom:button-card` templates repeatedly computed math on the client on every sensor update.
- **Solution (Option A):**
  - Streamline each room panel to only its primary room interaction views: **Main**, **Lights**, and **Climate**.
  - Extract the diagnostic views (**Sensors**, **Battery**, **Alerts**, **Homelab**, **Energy**) into a standalone shared dashboard: `dashboards/nspanel-system-diagnostics.yaml` (`/nspanel-system-diagnostics`).
  - Provide convenient cross-navigation chips/tiles on both main panels to jump to Diagnostics when needed.

### B. Ceiling Light 1 / Ceiling Fan Light State Cutoff
The user reported that turning off bedroom lights caused the ceiling fan light to stop responding to Alexa commands.
- **Root Cause:**
  - `light.main_bedroom_light_1` ("Ceiling Light 1" - TP-Link KS220M) acts as the in-wall physical power relay supplying 120V mains electricity to the smart ceiling fan fixture (`light.main_bedroom_ceiling_fan_light`).
  - While the custom toggle script `script.main_bedroom_lights_toggle` protects it, `light.main_bedroom_light_1` was exposed to voice assistants and assigned to the "Main Bedroom" area with domain `light`.
  - When voice commands or external apps issued "turn off bedroom lights", `light.main_bedroom_light_1` was switched off, cutting mains power to the ceiling fan and dropping its Wi-Fi controller offline.
  - Unlike `switch.office_fan_light_switch` in the Office, `light.main_bedroom_light_1` had no always-on auto-recovery watchdog.
- **Solution:**
  - Add `light.main_bedroom_light_1` to `automations/always_on_switch_watchdog.yaml` using `homeassistant.turn_on` so power is restored instantly if ever cut.
  - Unexpose `light.main_bedroom_light_1` from Home Assistant voice assistants (`expose_to: {conversation: false}`).

### C. Alexa & Tuya Fan Light Lockout Resolution
- **Root Cause:**
  - Tuya Local exposes both a master DP switch (`switch.smart_fan_lights_2`, "Lights") and a primary Light entity (`light.main_bedroom_ceiling_fan_light`, "Ceiling Fan").
  - Alexa is linked to Tuya cloud and exclusively toggles `switch.smart_fan_lights_2`.
  - When NSPanel called `light.turn_off` on `light.main_bedroom_ceiling_fan_light`, the Tuya controller entered a disabled state ignoring Alexa's switch toggle commands.
  - Standby power verification via Office fan relay (`sensor.den_fan_light_power`) showed 2.0W baseline power regardless of light entity state, confirming keeping the light ready consumes zero extra energy.
- **Solution:**
  - Created Template Light `light.main_bedroom_fan_light` mirroring `switch.smart_fan_lights_2` for on/off state while routing brightness and color temp to `light.main_bedroom_ceiling_fan_light`.
  - Added bidirectional sync automation `automation.main_bedroom_fan_light_state_sync` to auto-wake `light.main_bedroom_ceiling_fan_light` whenever Alexa turns on `switch.smart_fan_lights_2`.
  - Updated `scripts/main_bedroom_lights_toggle.yaml` and NSPanel tiles to control `light.main_bedroom_fan_light`.
  - Updated `sensor.main_bedroom_lights_on` and `sensor.main_bedroom_lights_off` helpers so Alexa toggles accurately update the badge count.

---

## 2. Work Breakdown

1. **Automation Update (`automations/always_on_switch_watchdog.yaml`):**
   - Add `light.main_bedroom_light_1` to trigger list.
   - Use `action: homeassistant.turn_on` to handle both `switch.*` and `light.*` entities.
   - Deploy to Home Assistant live via MCP and reload automations.

2. **Office NSPanel Dashboard (`dashboards/nspanel-office.yaml`):**
   - Retain:
     - View 1: `office` (path: `office`)
     - View 2: `lights` (path: `lights`)
     - View 3: `climate` (path: `climate`)
   - Remove Views: `sensors`, `battery`, `alerts`, `homelab`, `energy`.
   - Add a "Diagnostics & Energy ➔" navigation tile to the `office` view.

3. **Main Bedroom NSPanel Dashboard (`dashboards/nspanel-main-bedroom.yaml`):**
   - Retain:
     - View 1: `bedroom` (path: `bedroom`)
     - View 2: `lights` (path: `lights`)
     - View 3: `climate` (path: `climate`)
   - Remove Views: `sensors`, `battery`, `alerts`, `homelab`, `energy`.
   - Add a "Diagnostics & Energy ➔" navigation tile to the `bedroom` view.

4. **New Shared Dashboard (`dashboards/nspanel-system-diagnostics.yaml`):**
   - Title: `System & Diagnostics`
   - URL: `nspanel-system-diagnostics`
   - Views:
     - View 1: `sensors` (Environmental & Room Sensors)
     - View 2: `battery` (Device Battery Levels)
     - View 3: `alerts` (Security, Perimeter & Alert History)
     - View 4: `homelab` (Closet Thermals, Network & Server Watchdog)
     - View 5: `energy` (Real-Time Power & Energy Billing Monitoring)
   - Add quick-return header navigation back to `/nspanel-office/office` and `/nspanel-main-bedroom/bedroom`.
   - Register in Home Assistant storage mode via MCP.

5. **Validation:**
   - Verify YAML syntax and indentation across all modified dashboards.
   - Validate live dashboard updates in Home Assistant via MCP.
   - Validate automation reload in Home Assistant via MCP.
   - Verify `git diff`.
   - Bump version in `VERSION` and record changes in `CHANGELOG.md`.
   - Push branch and create Pull Request via `gh pr create`.
