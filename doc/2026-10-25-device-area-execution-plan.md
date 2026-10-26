# Execution Plan: Home Assistant Device, Area, Label & Entity Standardization

**Date**: 2026-10-25  
**Branch**: `feature/device-area-naming-standardization`  
**Related Documents**:
- [`doc/2026-10-25-device-area-naming-review.md`](file:///Users/gustavo/src/ha/doc/2026-10-25-device-area-naming-review.md)
- [`doc/devices-inventory-and-proposals.csv`](file:///Users/gustavo/src/ha/doc/devices-inventory-and-proposals.csv)
- [`doc/entities-inventory-and-proposals.csv`](file:///Users/gustavo/src/ha/doc/entities-inventory-and-proposals.csv)

---

## 1. Objectives

1. Create standardized labels in Home Assistant:
   - Physical protocol: `zigbee`, `wifi`, `lora`, `matter_wifi`, `ethernet`, `bluetooth`
   - Topology: `hub_connected` (reserved for YoLink & SwitchBot)
   - Metering: `power_monitoring` (for all metering plugs, switches, appliances)
   - Functional: `all_off_exempt`, `den_controlled_lights`, `git_managed`
   - Domain: `light`, `plug`, `switch`, `fan`, `climate`, `camera`, `media`, `lock`, `sensor`, `mobile`, `system`
2. Standardize Area friendly names and configure spoken voice aliases for non-native English accents.
3. Update all 152 device friendly names (omitting area prefix) and assign correct areas and labels.
4. Rename key entity IDs in Home Assistant to follow `<domain>.<area>_<descriptor>`.
5. Update repository YAML files (`automations/`, `scripts/`, `dashboards/`, `templates/`, `helpers/`) to reference the new entity IDs.
6. Validate configuration and verify no broken entity references remain.

---

## 2. Step-by-Step Execution Stages

### Stage 1: Label Provisioning
* Execute `ha_config_set_label` for all missing labels with designated icons and colors.

### Stage 2: Area & Spoken Alias Alignment
* Execute `ha_set_area_or_floor` for the 10 living areas:
  * Office (ID: `den`) with aliases: `["Den", "Study", "Workroom", "Escritorio"]`
  * Living Room (ID: `living_room`) with aliases: `["Living", "Family Room", "TV Room", "Sala"]`
  * Dining Room (ID: `dining`) with aliases: `["Dining", "Dinner Table", "Sala de Jantar"]`
  * Kitchen (ID: `kitchen`) with aliases: `["Cozinha"]`
  * Hallway (ID: `hallway`) with aliases: `["Hall", "Corridor", "Corredor"]`
  * Main Bedroom (ID: `main_bedroom`) with aliases: `["Master Bedroom", "Master", "Quarto Principal", "Suite"]`
  * Guest Bedroom (ID: `bedroom`) with aliases: `["Guest Room", "Bedroom 2", "Quarto de Hospedes"]`
  * Main Bathroom (ID: `main_bathroom`) with aliases: `["Master Bathroom", "Master Bath", "Banheiro Principal"]`
  * Guest Bathroom (ID: `bathroom`) with aliases: `["Guest Bath", "Hall Bathroom", "Powder Room"]`
  * Patio (ID: `pstio`) with aliases: `["Balcony", "Deck", "Backyard", "Outside", "Terrace", "Pátio"]`

### Stage 3: Batch Device Renaming & Label Assignment
* Loop through all devices in `doc/devices-inventory-and-proposals.csv` and call `ha_set_device`:
  * Apply `name` (clean friendly name, e.g. `SHIELD TV`, `Desk LEDs`, `Ceiling Fan`).
  * Apply `area_id`.
  * Apply `labels`.

### Stage 4: Entity ID Renaming
* Call `ha_set_entity(entity_id=..., new_entity_id=...)` for primary entities.

### Stage 5: Repository YAML Refactoring
* Search and replace old entity IDs in:
  * `automations/`
  * `scripts/`
  * `dashboards/nspanel-den.yaml`
  * `templates/`
  * `helpers/`

### Stage 6: Validation & Verification
* Query live entity states and verify automations reload cleanly.
* Review git diff.
* Update `CHANGELOG.md` and bump `VERSION`.
