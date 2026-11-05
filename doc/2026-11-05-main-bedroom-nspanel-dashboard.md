# Implementation Plan: Main Bedroom NSPanel Pro Dashboard

**Date:** 2026-11-05  
**Feature Branch:** `feature/main-bedroom-nspanel`  
**Target File:** `dashboards/nspanel-main-bedroom.yaml`  
**Status:** In Review / Ready for Approval  

---

## 1. Goal Description

Create a dedicated Sonoff NSPanel 120 Pro dashboard for the **Main Bedroom** (`nspanel-main-bedroom`) that matches the design, visual fidelity, and modular multi-panel architecture of the existing Office dashboard (`dashboards/nspanel-office.yaml`).

Key characteristics:
1. **Visual & Architectural Parity with Office**: High-contrast iOS Dark Mode theme (`ios-dark-mode`), single-column sections layout (`max_columns: 1`), resilient cached weather card, conditional security warning alerts, and unified corner radiuses (`12px` - `20px`).
2. **Room Lighting Hierarchy**:
   - Primary Light: Smart Ceiling Fan Light (`light.main_bedroom_ceiling_fan_light`) with full brightness and color temperature controls.
   - Secondary Room Lights: Ceiling Light 1 (`light.main_bedroom_light_1` / KS220M), Ceiling Light 2 (`light.main_bedroom_light_2` / KS225), and Closet Light (`light.main_bedroom_closet_light` / KS225).
   - Fan Accents: Backlight RGB (`light.smart_fan_backlight_2`), Nightlight (`light.smart_fan_nightlight_2`), and Scenes (`select.smart_fan_scene_2`).
   - Master Dynamic Light Card: Aggregated ON/OFF counter pill (`sensor.main_bedroom_lights_on`), single-tap toggle for all bedroom fixtures while preserving brightness/color state.
3. **Independent Patio Left Light Tile**:
   - The NSPanel Pro was physically installed where the wall switch for the Patio Left Light (`light.patio_left_light`) previously resided.
   - The dashboard will provide a prominent, completely independent control tile on the main view for `light.patio_left_light` that is **never** affected by bedroom lighting toggles or all-off commands.
4. **Perimeter Security & Patio Access**:
   - Full Alarmo security tile (`alarm_control_panel.alarmo`) with arm/disarm modes.
   - Patio door deadbolt tile (`lock.patio_door_lock`) with secure PIN modal integration matching the office panel.
   - Resilient cached weather card (`weather.forecast_home`) with local storage offline persistence.
5. **Air Quality & Environment Header Badges**:
   - Badges in the view header displaying ambient light (`sensor.zigbee2cube_1002c15147_illuminance`), outdoor temperature, and humidity, pre-configured with placeholder bindings ready to seamlessly connect to the air quality monitor being installed later today (Air Quality, PM2.5, Temperature, Humidity).
6. **Future-Proof Motion & Day/Night Extensibility**:
   - No Day/Night preset switching or motion automation logic will be enforced for now, as requested.
   - Hardware proximity wake (`switch.zigbee2cube_1002c15147_proximity_wake`) will wake the display upon physical approach.
   - The layout is modular so that when the external Aqara/radar motion sensor is installed later, Day/Night presets and presence automations can be added seamlessly.
7. **Complete Suite of Shared Sub-Panels**:
   - Incorporates the other 7 panel views from the office dashboard: **Lights**, **Climate**, **Sensors**, **Battery**, **Alerts**, **Homelab**, and **Energy**, adapted to bedroom/household context.

---

## 2. User Review Required

> [!IMPORTANT]
> **Independent Patio Left Light Isolation**: `light.patio_left_light` will have a standalone, independent tile on the bedroom main panel and will be strictly excluded from the `sensor.main_bedroom_lights_on` counter and room toggle scripts. Tapping "Turn Bedroom Lights Off" will never turn off the Patio light.

> [!TIP]
> **NSPanel Display Proximity Wake**: While the room does not yet have an external motion/presence sensor, the NSPanel Pro hardware features an onboard front proximity sensor (`switch.zigbee2cube_1002c15147_proximity_wake`). Enabling this will automatically wake the screen when you approach the switch.

> [!NOTE]
> **Upcoming Air Quality Monitor**: The header badges will display Illuminance from the panel plus outdoor Temperature and Humidity as temporary live values, structured with clean template entity hooks so that once your new air quality device is added later today, we only need to map its entity IDs.

---

## 3. Open Questions

1. **Ceiling Light 1 vs Ceiling Light 2**:
   - The bedroom has both `light.main_bedroom_light_1` (TP-Link KS220M dimmer) and `light.main_bedroom_light_2` (TP-Link KS225 dimmer), in addition to the Smart Ceiling Fan Light (`light.main_bedroom_ceiling_fan_light`) and Closet Light (`light.main_bedroom_closet_light`).
   - On the main view, should both Ceiling Light 1 and Ceiling Light 2 appear as direct tiles alongside the Fan Light, or is one of them the primary secondary light?
   - *Recommendation:* Place Fan Light + Ceiling Light 2 as a row, and Closet Light + Patio Left Light as a row, with Ceiling Light 1 also accessible on the main view grid and fully accessible on the Lights sub-panel.
2. **NSPanel Pro Audio Chime in Bedroom**:
   - The office NSPanel plays audible chimes on button taps and security alerts. In the bedroom, do you prefer touch sounds / chimes to be enabled or kept silent by default to avoid disturbing sleep?

---

## 4. Proposed Changes

### 1. Dashboard Configuration (`dashboards/`)

#### [NEW] `dashboards/nspanel-main-bedroom.yaml`
- Complete Lovelace configuration for the Main Bedroom NSPanel Pro (`url_path: nspanel-main-bedroom`).
- **Views**:
  1. `Main Bedroom` (path: `bedroom`, icon: `mdi:bed-king`):
     - Badges: Illuminance (`sensor.zigbee2cube_1002c15147_illuminance`), outdoor temperature, outdoor humidity, air quality placeholder.
     - Conditional security warning banners (`binary_sensor.active_security_warnings`).
     - Master bedroom lighting card (`sensor.main_bedroom_lights_on` with tap toggle calling `script.main_bedroom_lights_toggle`).
     - Independent Patio Left Light tile (`light.patio_left_light`).
     - Bedroom fixtures: Ceiling Fan Light (`light.main_bedroom_ceiling_fan_light`), Ceiling Light 2 (`light.main_bedroom_light_2`), Ceiling Light 1 (`light.main_bedroom_light_1`), Closet Light (`light.main_bedroom_closet_light`).
     - Ceiling Fan circulation tile (`fan.main_bedroom_ceiling_fan` with speed slider).
     - Security & Access: Alarmo security modes (`alarm_control_panel.alarmo`) + Patio Lock (`lock.patio_door_lock`) with PIN modal keypad.
     - Resilient cached weather forecast card (`weather.forecast_home`).
  2. `Lights` (path: `lights`, icon: `mdi:lightbulb-multiple`):
     - Main Bedroom Task & Ambient fixtures: Fan Light (brightness + color temp), Fan Backlight (RGB + brightness), Fan Scene selector (`select.smart_fan_scene_2`), Fan Nightlight (`light.smart_fan_nightlight_2`), Ceiling Light 1, Ceiling Light 2, Closet Light.
     - Patio Left Light section: dedicated controls for the patio light.
  3. `Climate` (path: `climate`, icon: `mdi:fan`):
     - Main Bedroom Ceiling Fan speed, direction, nature/fresh presets.
     - Humidifier control (`humidifier.humidifier`).
  4. `Sensors` (path: `sensors`, icon: `mdi:shield-check`):
     - Perimeter doors, fence gate, window sensors, locks, and motion detectors across the house.
  5. `Battery` (path: `battery`, icon: `mdi:battery-high`):
     - Low battery attention section (< 60%) and categorized battery monitoring for all household battery devices.
  6. `Alerts` (path: `alerts`, icon: `mdi:shield-alert-outline`):
     - Perimeter security alert management, delay adjustment sliders, and alarm trigger status.
  7. `Homelab` (path: `homelab`, icon: `mdi:server-network`):
     - Kitchen closet cooling watchdog, Proxmox VE telemetry, VM and LXC container statuses.
  8. `Energy` (path: `energy`, icon: `mdi:lightning-bolt-circle`):
     - Live total load, BC Hydro billing period cycle-to-date cost, and consumption breakdown for all 12 monitored plugs and relays.

---

### 2. Template Sensors & Helpers (`templates/`, `scripts/`)

#### [NEW] `templates/main_bedroom_sensors.yaml`
- Add template sensors for bedroom lights aggregation:
  - `sensor.main_bedroom_lights_on`: counts active lights among `light.main_bedroom_ceiling_fan_light`, `light.main_bedroom_light_1`, `light.main_bedroom_light_2`, `light.main_bedroom_closet_light`, and `light.smart_fan_backlight_2`. Excludes `light.patio_left_light`.
  - `sensor.main_bedroom_lights_off`: complementary count for inactive bedroom lights.
  - `sensor.main_bedroom_light_level`: friendly illuminance descriptor derived from `sensor.zigbee2cube_1002c15147_illuminance`.

#### [NEW] `scripts/main_bedroom_lights_toggle.yaml`
- Toggle script for master button:
  - If `sensor.main_bedroom_lights_on > 0`, turns off all bedroom lights (`light.main_bedroom_ceiling_fan_light`, `light.main_bedroom_light_1`, `light.main_bedroom_light_2`, `light.main_bedroom_closet_light`, `light.smart_fan_backlight_2`, `light.smart_fan_nightlight_2`).
  - If `0` on, turns on primary light (`light.main_bedroom_ceiling_fan_light`) bare `light.turn_on` without overwriting brightness/color temperature (preserving user state memory).
  - Explicitly protects and leaves `light.patio_left_light` untouched.

---

### 3. Repository Documentation & Versioning

#### [MODIFY] `VERSION`
- Bump version from `0.12.0` to `0.13.0` (MINOR increment for new dashboard, scripts, and template sensors).

#### [MODIFY] `CHANGELOG.md`
- Record addition of Main Bedroom NSPanel dashboard and associated components under `## 0.13.0 - 2026-11-05`.

---

## 5. Verification Plan

### Automated / Syntax Validation
1. **YAML Validation**:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('dashboards/nspanel-main-bedroom.yaml'))"
   python3 -c "import yaml; yaml.safe_load(open('templates/main_bedroom_sensors.yaml'))"
   python3 -c "import yaml; yaml.safe_load(open('scripts/main_bedroom_lights_toggle.yaml'))"
   ```
2. **HA MCP Dashboard Registration**:
   - Register dashboard `nspanel-main-bedroom` in Home Assistant using `ha_config_set_dashboard` MCP tool.
   - Verify dashboard load and cards via `ha_config_get_dashboard`.

### Manual / Hardware Verification
1. Open `http://<ha-url>/nspanel-main-bedroom/bedroom` in browser and directly on the Main Bedroom NSPanel 120 Pro.
2. Verify:
   - Header badges render clean values.
   - Patio Left Light toggle functions completely independently without affecting room light count.
   - Bedroom master light button toggles bedroom lights while preserving last brightness/color temp.
   - Ceiling fan speed and direction controls respond accurately.
   - Patio security (Alarmo) and lock cards display current status and allow interaction.
   - Resilient weather card displays live data.
   - Navigation between views (Lights, Climate, Sensors, Battery, Alerts, Homelab, Energy) works smoothly.
