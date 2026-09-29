# Implementation Plan: Home Assistant Labels & Repository Provenance Governance

**Date**: 2026-09-28  
**Status**: Implemented  
**Scope**: Label strategy creation, Git repository provenance tagging, template sensor and script refactoring, and project governance documentation.

---

## 1. Overview & Context

This implementation fulfills **Step 2** of the Home Assistant architecture roadmap, building upon the label strategy proposal formulated in `doc/2026-09-28-label-strategy-proposal.md`.

In previous iterations, lighting automations, scripts, and template sensors relied on hardcoded lists of entity IDs (e.g., `switch.den_floor_lamp_side_light`, `light.floor_lamp`, `light.office_leds`, etc.). While functional, hardcoded lists present maintenance friction:
- Adding or replacing physical devices requires updating multiple YAML files and Jinja expressions.
- Broad broadcasts using `area_id` cause issues when multi-segment or cloud-dependent devices (such as Govee lights) receive dozens of segment commands simultaneously.
- Ad-hoc helpers created in the Home Assistant UI lacked clear visual indication of whether they were managed in Git.

This change introduces:
1. **Repository Provenance Governance (`git_managed`)**: All version-controlled helpers, scripts, template lights/sensors, and automations are tagged with the `git_managed` label in Home Assistant.
2. **Functional Lighting Grouping (`den_controlled_lights`)**: Physical fixtures in the Den are tagged with `den_controlled_lights` to enable dynamic targeting and state evaluation without hardcoded entity arrays.
3. **Decoupled Templates & Scripts**:
   - `templates/den_sensors.yaml` and live helpers (`sensor.den_lights_on`, `sensor.den_lights_off`) now query `label_entities('den_controlled_lights')`.
   - `scripts/den_all_lights_off.yaml` targets `label_id: den_controlled_lights` via `homeassistant.turn_off`.
4. **Governance Principles**: Updated `AGENTS.md` to establish standards for label usage, inspection, and mandatory provenance tagging.

---

## 2. Taxonomy & Core Labels Created

The following labels were created in Home Assistant via MCP tool `ha_config_set_label`:

| Label ID | Display Name | Icon | Color | Purpose / Description |
|---|---|---|---|---|
| `git_managed` | Git Managed | `mdi:git` | `cyan` | Applied to all version-controlled resources (`github.com/lganet/ha`) to indicate repository provenance. |
| `den_controlled_lights` | Den Controlled Lights | `mdi:lightbulb-group` | `amber` | Applied to physical lighting fixtures in the Den controlled by room-wide toggles and scripts. |

---

## 3. Inventory of Tagged Entities

### A. Repository Provenance (`git_managed`)
The following 17 version-controlled entities were tagged in the Home Assistant entity registry:

- **Scripts**:
  - `script.den_all_lights_on`
  - `script.den_all_lights_off`
- **Automations**:
  - `automation.den_fan_light_state_tracker`
  - `automation.den_floor_lamp_mutual_exclusion`
- **Helpers & Template Entities**:
  - `input_boolean.den_lights_snapshot_active`
  - `input_boolean.den_night_light_active`
  - `input_text.den_lights_last_state`
  - `input_number.den_fan_light_last_brightness`
  - `input_number.den_fan_light_last_color_temp`
  - `input_number.den_night_light_last_brightness`
  - `input_number.den_night_light_last_color_temp`
  - `sensor.den_lights_on`
  - `sensor.den_lights_off`
  - `sensor.den_pm2_5_level`
  - `sensor.den_light_level`
  - `light.den_fan_light`
  - `light.den_night_light`

### B. Functional Lighting Label (`den_controlled_lights`)
The active Den physical light fixtures were tagged in the entity registry:
- `light.floor_lamp`
- `light.office_leds`
- `switch.den_floor_lamp_side_light`
- `switch.den_floor_lamp_bottom_light`
- `switch.den_floor_lamp_ripple_light`
- `light.den_fan_light`

---

## 4. Configuration Changes

### A. Template Sensors (`templates/den_sensors.yaml` & live helpers)
Updated `sensor.den_lights_on` and `sensor.den_lights_off` to dynamically query `label_entities('den_controlled_lights')`:
- Den Floor Lamp sub-switches (`switch.den_floor_lamp_*`) are dynamically grouped to count as 1 physical fixture.
- Other tagged fixtures (`light.floor_lamp`, `light.office_leds`, `light.den_fan_light`) each count as 1 fixture.
- Total fixtures count is dynamically computed without hardcoded numbers or entity arrays.

### B. Script (`scripts/den_all_lights_off.yaml`)
Replaced separate fixture `light.turn_off` and `switch.turn_off` calls with:
```yaml
- action: homeassistant.turn_off
  target:
    label_id: den_controlled_lights
- action: light.turn_off
  target:
    entity_id:
      - light.smart_fan_backlight
```
This cleanly turns off all fixtures tagged with `den_controlled_lights` across both the light and switch domains.

### C. Governance Rules (`AGENTS.md`)
Added a new section **Label Principles & Best Practices** enforcing:
- Preferring label targeting over broad area broadcasts.
- Avoiding rigid entity arrays in templates and scripts by using `label_entities()`.
- Inspecting existing labels before creating duplicates.
- Mandating `git_managed` tagging for all repository-managed resources.

---

## 5. Live MCP Validation

1. **Label Registry**: Confirmed creation of `git_managed` and `den_controlled_lights` via `ha_config_get_label()`.
2. **Entity Label Assignment**: Verified via `ha_get_entity` that all 17 git-managed resources carry `git_managed`, and the 6 physical fixtures carry `den_controlled_lights`.
3. **Template Sensor Evaluation**: Evaluated both Jinja templates via `ha_eval_template`:
   - `label_entities('den_controlled_lights')` correctly returned the 6 target entities.
   - `sensor.den_lights_on` evaluated to `0`.
   - `sensor.den_lights_off` evaluated to `4`.
4. **Script Configuration**: Updated and validated `script.den_all_lights_off` via `ha_config_set_script` with `result: "ok"`.
