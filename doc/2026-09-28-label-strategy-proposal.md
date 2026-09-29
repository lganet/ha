# Proposal: Home Assistant Label Strategy & Repository Provenance

**Date**: 2026-09-28  
**Status**: Implemented (Step 2 Roadmap - see `doc/2026-09-28-labels-and-governance.md`)  

---

## 1. Objectives

1. **Decouple automations, scripts, and template sensors from brittle hardcoded entity lists** using modern Home Assistant Labels (HA 2024.4+).
2. **Prevent multi-segment / integration entity flooding** (e.g., Govee Cloud API 8-segment thrashing) by targeting functional labels rather than broad `area_id` broadcasts.
3. **Establish repository provenance tracking** to clearly mark which entities, helpers, scripts, and automations in Home Assistant are managed by this Git repository vs. ad-hoc UI creations.

---

## 2. Proposed Taxonomy

### A. Repository Tracking Label (Provenance)
* **Label ID**: `git_managed` (or `ai_managed`)
* **Display Name**: `Git Managed`
* **Icon**: `mdi:git`
* **Color**: `cyan`
* **Purpose**: Applied to any helper, script, automation, or custom entity tracked in version control (`/Users/gustavo/src/ha`). Warns in HA Settings UI that edits should occur in Git rather than directly in the UI.

### B. Functional / Behavioral Labels
* **`den_controlled_lights`**: Applied to physical fixtures in the Den (`light.floor_lamp`, `light.office_leds`, `light.den_fan_light`, `switch.den_floor_lamp_*`).
  * Used by `script.den_all_lights_off` for snapshotting (`snapshot_entities: "{{ label_entities('den_controlled_lights') }}"`) and turning off (`homeassistant.turn_off` target `label_id: den_controlled_lights`).
  * Used by `sensor.den_lights_on` and `sensor.den_lights_off` to dynamically compute light count badges without editing Jinja code.
* **`all_off_exempt`**: Placed on mission-critical plugs or devices (aquarium, refrigerator, 3D printer, network gear) to guarantee global shutdown automations never cut power.
* **`bedtime_off`**: Devices and accent lights to turn off when night mode triggers.

---

## 3. Implementation Steps (When Ready)

1. **Update `AGENTS.md`**:
   * Add section on label best practices (prefer labels over broad area broadcasts, check existing labels before creating duplicates).
   * Mandate `git_managed` label assignment for newly generated or updated helpers/automations.
2. **Create Labels via HA MCP**:
   * `ha_config_set_label(name="Git Managed", label_id="git_managed", icon="mdi:git", color="cyan")`
   * `ha_config_set_label(name="Den Controlled Lights", label_id="den_controlled_lights", icon="mdi:lightbulb-group", color="amber")`
3. **Retroactive Tagging via `ha_set_entity`**:
   * Tag Den scripts, template helpers, and physical light fixtures.
4. **Refactor Den Scripts & Templates**:
   * Update `scripts/den_all_lights_off.yaml` to target `label_id: den_controlled_lights`.
   * Update `templates/den_sensors.yaml` to use `label_entities('den_controlled_lights')`.
