# Changelog

## 0.5.0 - 2026-09-28

### Added
- Implemented Home Assistant Label Architecture (Step 2 of roadmap) creating core labels `git_managed` (`mdi:git`, cyan) for repository provenance governance and `den_controlled_lights` (`mdi:lightbulb-group`, amber) for functional lighting grouping.
- Tagged 17 version-controlled helpers, scripts, automations, and template entities in Home Assistant with `git_managed` to clearly delineate repository-managed resources from ad-hoc UI creations.
- Tagged 6 active physical fixtures in the Den (`light.floor_lamp`, `light.office_leds`, `light.den_fan_light`, `switch.den_floor_lamp_side_light`, `switch.den_floor_lamp_bottom_light`, `switch.den_floor_lamp_ripple_light`) with `den_controlled_lights`.
- Added **Label Principles & Best Practices** section to `AGENTS.md` governing label targeting over broad area broadcasts, dynamic entity resolution via `label_entities()`, inspection prior to label creation, and mandatory `git_managed` tagging.
- Added implementation plan `doc/2026-09-28-labels-and-governance.md` and updated proposal `doc/2026-09-28-label-strategy-proposal.md`.

### Changed
- Refactored `sensor.den_lights_on` and `sensor.den_lights_off` template sensors and live helpers to dynamically resolve fixture states using `label_entities('den_controlled_lights')`, eliminating brittle hardcoded entity lists.
- Refactored `script.den_all_lights_off` to target `label_id: den_controlled_lights` via `homeassistant.turn_off`, cleanly turning off all room fixtures across light and switch domains without area broadcast flooding.

## 0.4.0 - 2026-09-26

### Added
- Created `script.den_all_lights_off` to dynamically snapshot active lighting states into persistent helper `input_text.den_lights_last_state` before turning them off.
- Created helper `input_boolean.den_lights_snapshot_active` to track whether an active lighting snapshot exists and guard against overwriting snapshots when lights are already off.
- Created `automation.den_floor_lamp_mutual_exclusion` to automatically turn off Side Light when Bottom Light is toggled on (and vice-versa), matching physical H60B0 lamp hardware behavior and preventing both switches from displaying "on" simultaneously.
- Added Den Floor Lamp card (`custom:stack-in-card`) to Den dashboard with direct controls for sub-lights (`Side Light` full width, `Base` and `Ripple` in a 2-column grid to avoid UI text truncation).
- Added implementation plan `doc/2026-09-26-govee-cloud-den-lights.md` and proposal `doc/2026-09-28-label-strategy-proposal.md`.

### Changed
- Migrated Den dashboard Govee lights from legacy local integration to HACS Govee Cloud integration (`light.floor_lamp`, `light.office_leds`), resolving "Entity not found" tiles.
- Updated `sensor.den_lights_on` and `sensor.den_lights_off` template helpers to group multi-segment Govee lights and sub-lights into their 4 physical fixtures (Den Floor Lamp, Floor Lamp, Office LEDs, Fan composite), fixing the 35-light count badge explosion.
- Updated "All Lights Off" master button to invoke `script.den_all_lights_off` with snapshot guard (`above: 0`) and `mode: single`.
- Updated `script.den_all_lights_on` to restore Govee lights (`light.office_leds`, `light.floor_lamp`) using bare `light.turn_on` calls, preserving external app effects, DIY scenes, and music sync modes from the device's internal memory.
- Shortened tile labels on Den Floor Lamp card to "Base" and "Ripple" to eliminate NSPanel text truncation (`Botto...`).
- Removed unused and unresponsive `switch.den_floor_lamp_dreamview` from dashboard, scripts, and template counters, eliminating redundant Govee cloud API calls.

### Fixed
- Fixed Govee app effects on Office LEDs and Floor Lamp being erased during All Lights On by replacing attribute-heavy scene restoration with bare `light.turn_on` invocations.
- Fixed Den Floor Lamp Side Light and Bottom Light displaying simultaneously "on" when physical fixture only supports one at a time.
- Fixed Den Floor Lamp on-off-on glitch during "All Lights Off" by targeting specific fixture lights and switches instead of broadcasting area-wide `light.turn_off`, preventing Govee Cloud API command flooding across multi-segment entities.
- Removed status-only `light.den_floor_lamp` tile to avoid conflicting commands, controlling the lamp exclusively through its physical sub-light switches.
- Fixed snapshot overwrite issue where pressing "All Lights Off" while dark would save an empty room state, preventing "All Lights On" from doing nothing.

## 0.3.0 - 2026-09-21

### Added
- Created Template Lights `light.den_fan_light` and `light.den_night_light` providing full, independent brightness and color temperature controls for both task lighting (cool white) and ambient night lighting (warm white).
- Created state tracking helpers (`input_number.den_fan_light_last_brightness`, `input_number.den_fan_light_last_color_temp`, `input_number.den_night_light_last_brightness`, `input_number.den_night_light_last_color_temp`, and `input_boolean.den_night_light_active`) to preserve user lighting preferences.
- Created `automation.den_fan_light_state_tracker` to record active light color temperature and dimmer levels.
- Created `script.den_all_lights_on` to turn on room lights and Fan Light (cool profile) while keeping Night Light off and preserving external Govee app settings.
- Created template sensor helper `sensor.den_pm2_5_level` translating raw PM2.5 values into human-readable air quality categories (Clean, Fair, Elevated, Poor, Severe).
- Added implementation plan `doc/2026-09-21-den-panel-improvements.md`.
- Added Lighting & State Preservation Principles and Configuration Tracking & Directory Organization rules to `AGENTS.md`.
- Added version-controlled YAML definitions organized into dedicated domain folders (`automations/`, `scripts/`, `templates/`, `helpers/`).

### Changed
- Moved Night Light (`light.den_night_light`) to the Lights section of Den dashboard with full brightness and color temperature slider controls.
- Updated Fan Light card on Den dashboard to use `light.den_fan_light`.
- Installed `stack-in-card` via HACS to unite Fan Backlight (`light.smart_fan_backlight`) and Fan Scene (`select.smart_fan_scene`) into a single seamless card without inner gaps or dividing borders.
- Streamlined Fan & Air section strictly for climate/circulation controls (`fan.smart_fan` and `fan.air_purifier_2`).
- Updated "All Lights On" master button to invoke `script.den_all_lights_on`.
- Updated Den dashboard badge from raw PM2.5 numeric sensor to human-readable `sensor.den_pm2_5_level`.

## 0.2.4 - 2026-09-21

### Added
- Added Smart Fan Light (`light.smart_fan_3`) with brightness dimmer and color temperature control to the Lights section of Den dashboard.
- Added Smart Fan Backlight (`light.smart_fan_backlight`) with brightness dimmer and RGB color picker to the Lights section of Den dashboard.
- Added implementation plan `doc/2026-09-21-smartfan-lights-badge-update.md`.

### Changed
- Updated `sensor.den_lights_on` and `sensor.den_lights_off` template sensors to treat all Smart Fan lights (main light, backlight, and nightlight) as a single composite light in the total light count.
- Refined illuminance template helper `sensor.den_light_level` for office work comfort with tailored categories: Dark (<10 lx), Poor Light (10-50 lx), Soft Light (50-150 lx), Screen Work (150-350 lx), Ideal for Work (350-1000 lx), and Daylight (>1000 lx).

## 0.2.3 - 2026-09-21

### Added
- Added AQARA FP300 environmental indicators (Temperature, Humidity, and Light Level) to Den dashboard top badges.
- Created template helper `sensor.den_light_level` providing human-readable illuminance conditions ("Dark", "Poor Light", "Good Light", "Bright", "Daylight") based on raw lux.
- Added dedicated Fan Nightlight button (`light.smart_fan_nightlight`) and Fan Scene selector (`select.smart_fan_scene`).
- Added implementation plan `doc/2026-09-21-localtuya-fp300-update.md`.

### Changed
- Migrated broken entities to LocalTuya (`fan.air_purifier_2`, `sensor.air_purifier_air_quality_2`, `sensor.air_purifier_pm2_5_2`, `fan.smart_fan`).
- Removed redundant fan light tiles from room lighting grid to streamline layout for the 3 primary room lights.

## 0.2.2 - 2026-09-17

### Added
- Applied `ios-dark-mode` theme to the Den NSPanel dashboard (`nspanel-den/den`) to ensure a native dark appearance on the Sonoff NSPanel 120 Pro.
- Installed `iOS Dark Mode Theme` via HACS and registered theme reloads.
- Added implementation plan `doc/2026-09-17-dark-theme.md`.

## 0.2.1 - 2026-09-16

### Changed
- Converted All Lights On and All Lights Off controls to `custom:button-card` with an icon-overlapping circular notification badge displaying active and inactive counts matching user reference design.
- Installed `button-card` via HACS and registered the dashboard module resource.
- Added implementation plan `doc/2026-09-16-button-card-badges.md`.

## 0.2.0 - 2026-09-16

### Added
- Added Sonoff NSPanel 120 Pro dashboard for the Den (`dashboards/nspanel-den.yaml`) with master room controls, individual dimmable RGB light controls, and fan/climate cards.
- Added live light count indicators (balloon badges and button state) for All Lights On and All Lights Off backed by Den light count template helpers.
- Added implementation plan documentation procedure to `AGENTS.md` and saved the project plan in `doc/2026-09-16-nspanel-den.md`.

## 0.1.0 - 2026-09-16

### Added
- Initialized the Home Assistant configuration repository and project maintenance guidance.
