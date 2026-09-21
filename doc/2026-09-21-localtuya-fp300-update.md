# Implementation Plan: Update Den NSPanel Dashboard for LocalTuya & AQARA FP300

The user replaced the cloud Tuya integration with LocalTuya and added an **AQARA FP300** multi-sensor in the Den. This caused entity ID changes resulting in "Entity not found" errors on the dashboard. Additionally, the user requested incorporating environmental data (Humidity, Illuminance with human-readable semantic levels, and Temperature), removing redundant light tiles while keeping dedicated controls for Smart Fan Nightlight and Scene selector.

## User Review Required

> [!IMPORTANT]
> **Illuminance Readability (Human-Friendly Lux Sensor)**:
> Rather than showing raw numbers like `97 lx`, we propose creating a Template Sensor helper `sensor.den_light_level` that translates lux into human-readable conditions:
> - `< 10 lx`: **Dark** (🌙)
> - `10 – 50 lx`: **Dim / Poor Light** (💡)
> - `50 – 300 lx`: **Normal / Good Light** (☀️)
> - `300 – 1000 lx`: **Bright / Recommended Reading** (📖)
> - `> 1000 lx`: **Very Bright / Daylight** (🔆)
> The card or badge can display both the readable descriptor and the exact lux in parentheses (e.g. `Good Light (97 lx)`).

> [!NOTE]
> **Smart Fan Lighting & Controls Structure**:
> - Per user request, the generic fan light tile is removed from the "Lights" grid.
> - Kept the 3 core Govee room lights in a clean layout: **Ceiling Light** (`light.h60b0`), **Wall Lights** (`light.h6061`), and **Floor Light** (`light.h6076`).
> - In the **Fan & Air** section:
>   - **Smart Fan** (`fan.smart_fan`): On/off, speed slider, and direction toggle.
>   - **Air Purifier** (`fan.air_purifier_2`): updated entity ID replacing broken `fan.air_purifier`.
>   - **Nightlight** (`light.smart_fan_nightlight`): Dedicated button/tile card for the Smart Fan nightlight.
>   - **Fan Scene** (`select.smart_fan_scene`): Selector for fan scenes (`Colorful`, `reading`, `night`, `working`, `leisure`, etc.).

---

## Entity Mapping Breakdown

| Previous Entity (Cloud Tuya / Missing) | New LocalTuya / AQARA Entity | Purpose / Destination |
|---|---|---|
| `sensor.air_purifier_air_quality` (missing) | `sensor.air_purifier_air_quality_2` | Top View Badge |
| `sensor.air_purifier_pm2_5` (missing) | `sensor.air_purifier_pm2_5_2` | Top View Badge |
| *(New)* | `sensor.fp300_den_temperature` | Environmental Badge / Card |
| *(New)* | `sensor.fp300_den_humidity` | Environmental Badge / Card |
| *(New)* | `sensor.den_light_level` (from `sensor.fp300_den_illuminance`) | Environmental Badge / Card (Human Readable) |
| `light.smart_fan` (missing) | `light.smart_fan_3` | Removed from main lighting grid as requested |
| `light.smart_fan_night_light` (missing) | `light.smart_fan_nightlight` | Dedicated Fan Nightlight tile card |
| *(New)* | `select.smart_fan_scene` | Fan Scene selector feature / tile card |
| `fan.air_purifier` (missing) | `fan.air_purifier_2` | Air Purifier control |
| `fan.smart_fan` | `fan.smart_fan` | Active LocalTuya entity (speed + direction) |

---

## Proposed Changes

### Helpers & Configuration

#### [NEW] Template Helper: Semantic Illuminance (`sensor.den_light_level`)
- Create template sensor helper via Home Assistant MCP `ha_config_set_helper`:
  - Name: `Den Light Level`
  - Entity ID: `sensor.den_light_level`
  - Icon: `mdi:brightness-6`
  - Template logic:
    ```jinja2
    {% set lx = states('sensor.fp300_den_illuminance') | float(0) %}
    {% if lx < 10 %}Dark
    {% elif lx < 50 %}Poor Light
    {% elif lx < 300 %}Good Light
    {% elif lx < 1000 %}Bright
    {% else %}Daylight{% endif %}
    ```

---

### Dashboard Definition

#### [MODIFY] [`dashboards/nspanel-den.yaml`](file:///Users/gustavo/src/ha/dashboards/nspanel-den.yaml)

1. **Top Badges**:
   - Update Air Quality: `sensor.air_purifier_air_quality_2`
   - Update PM2.5: `sensor.air_purifier_pm2_5_2`
   - Add Temperature: `sensor.fp300_den_temperature`
   - Add Humidity: `sensor.fp300_den_humidity`
   - Add Light Level: `sensor.den_light_level`

2. **Section: Lights**:
   - Clean 3-light layout (or 2-column with a room toggle / cleaner symmetry):
     - `light.h60b0` (Ceiling Light)
     - `light.h6061` (Wall Lights)
     - `light.h6076` (Floor Light)
   - Remove broken `light.smart_fan` and old `light.smart_fan_night_light` from this section.

3. **Section: Fan & Air**:
   - **Smart Fan** (`fan.smart_fan`): Tile card with speed slider, direction control.
   - **Air Purifier** (`fan.air_purifier_2`): Tile card with preset mode dropdown.
   - **Fan Nightlight** (`light.smart_fan_nightlight`): Dedicated tile card with toggle.
   - **Fan Scene** (`select.smart_fan_scene`): Tile or select card with dropdown or buttons for scenes (`Colorful`, `night`, `reading`, etc.).

---

### Documentation & Versioning

#### [NEW] [`doc/2026-09-21-localtuya-fp300-update.md`](file:///Users/gustavo/src/ha/doc/2026-09-21-localtuya-fp300-update.md)
- Detail the entity migrations and FP300 additions.

#### [MODIFY] [`VERSION`](file:///Users/gustavo/src/ha/VERSION)
- Bump version from `0.2.2` to `0.2.3`.

#### [MODIFY] [`CHANGELOG.md`](file:///Users/gustavo/src/ha/CHANGELOG.md)
- Add entry for `0.2.3 - 2026-09-21`.

---

## Verification Plan

### Automated / Tool Verification
- Validate YAML structure of [`dashboards/nspanel-den.yaml`](file:///Users/gustavo/src/ha/dashboards/nspanel-den.yaml).
- Push changes live to Home Assistant via `ha_config_set_dashboard`.
- Verify template sensor helper state evaluates properly (`sensor.den_light_level`).
- Confirm zero "Entity not found" errors on the rendered dashboard.

### Manual Verification
- Ask user to review the dashboard on the NSPanel 120 Pro and confirm the new environmental badges, illuminance readability, fan controls, nightlight button, and scene selector.
