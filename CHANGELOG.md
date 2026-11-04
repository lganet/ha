# Changelog

## 0.9.0 - 2026-11-03

### Added
- Added multi-tone sound design to NSPanel Pro audio feedback (`scripts/nspanel_audio_feedback.yaml`) with distinct sounds for room lighting actions:
  - **Day ON**: Bright, crisp electronic chime (`alarms/beep_short.ogg`).
  - **Day OFF**: Tactile, crisp power down pop (`cartoon/pop.ogg`).
  - **Night ON**: Smooth, warm acoustic musical strum (`cartoon/instrument_strum.ogg`) for gentle evening transitions.
  - **Night OFF**: Quiet, smooth underwater whoosh (`water/air_woosh_underwater.ogg`) for peaceful bedtime shutoffs.
  - **Save Preset**: Mechanical tactile button latch (`office/button_push.ogg`).
- Integrated dynamic tone routing in `scripts/den_all_lights_off.yaml` to automatically play `night_off` if night mode was active and `day_off` if day mode was active.
- Added adaptive master lighting toggle script (`scripts/office_adaptive_lights_toggle.yaml`) contextually switching between Day mode (workday 09:00-18:00) and Night mode (evening/off-hours).
- Added `scripts/office_activate_day_preset.yaml` and `scripts/office_activate_night_preset.yaml` allowing direct preview and activation of Day and Night scenes.
- Embedded `[ ☀️ Day Preset ]` and `[ 🌙 Night Preset ]` pills directly on the master lights card in `dashboards/nspanel-office.yaml` with active state border glow and instant audio feedback.
- Added direct mode preview activation buttons (`Activate Day Mode` and `Activate Night Mode`) to the Presets Management section on the Lights panel to prevent daytime fixtures from contaminating night ambient presets.

### Changed
- Expanded Night Preset snapshotting to cover all office fixtures (`scripts/office_save_night_preset.yaml`, `scripts/office_activate_night_preset.yaml`), allowing any light (such as Desk LEDs or Floor Lamp) to be included in Night Mode when saved rather than strictly hardcoded off.
- Refactored master lights button into a unified `custom:stack-in-card` combining the large turn on/off button with dual badges (`X on` / `Y off`) and quick preset pills, maximizing touch targets and filling available display space on the NSPanel Pro.
- Aligned friendly names for `light.den_fan_light` ("Fan Task Light") and `light.den_night_light` ("Fan Night Light") in entity registry and template definitions so dashboard tiles and more-info dialog titles match consistently.

### Fixed
- Fixed Day & Night Preset pills alignment on master light card in `dashboards/nspanel-office.yaml` using balanced `calc(100% - 16px)` column widths with symmetric margins, preserving wide 50/50 touch targets without right-border clipping or shrink-wrap collapse.
- Fixed Ceiling Fan Light not respecting Day and Night mode transitions (`templates/den_lights.yaml`, `scripts/office_activate_night_preset.yaml`, `scripts/den_all_lights_on.yaml`, `automations/den_fan_light_state_tracker.yaml`):
  - Removed `light.den_fan_light` from `light.turn_off` in `office_activate_night_preset`, and added explicit `light.turn_on: light.den_night_light` to ensure the fan light directly transitions to Night mode.
  - Added explicit `light.turn_on: light.den_fan_light` in `den_all_lights_on` so switching to Day mode immediately restores the day task brightness (75%) and cool color temperature (6000K–6369K).
  - Preserved color temperature and brightness cross-talk in `templates/den_lights.yaml` so adjustments to one attribute do not wipe out the other.
  - Prevented state tracker helper overwrite race conditions by adding a 5-second mode settling guard in `automation.den_fan_light_state_tracker` to avoid recording intermediate transitional brightness levels across modes.
- Fixed color temperature preset crash (`Invalid value for input_number.den_fan_light_last_color_temp: 6536.0 (range 3000.0 - 6500.0)`) when selecting white (153 mireds / 6536K) or deep warm/orange (500 mireds / 2000K) presets by expanding helper bounds (2000K–7000K) and clamping values in `templates/den_lights.yaml` and `automations/den_fan_light_state_tracker.yaml`.

## 0.8.0 - 2026-11-03

### Added
- Redesigned Sonoff NSPanel 120 Pro dashboard into a modular multi-panel architecture (`dashboards/nspanel-office.yaml`):
  - **Office (Main)**: Instant room summary, dynamic master light button, presence control, compact fan and air purifier tiles, Patio Cameras (`alarm_control_panel.gushomebase`) mode selector, daily weather forecast (`weather.forecast_home`), and conditional security warning banners.
  - **Lights**: Room fixture tiles (Floor Lamp with sub-lights, Desk LEDs, Fan Light, Fan Night Light, Fan Backlight/Scene, and Humidifier Light) alongside one-tap preset overwrite buttons.
  - **Climate**: Dedicated controls for Ceiling Fan (speed slider, direction), Air Purifier (preset modes), and Humidifier.
  - **Sensors**: Comprehensive security monitoring covering locks (`lock.patio_door_lock`), perimeter doors (`binary_sensor.door_sensor_door`, `binary_sensor.patio_lock_door`), fence gate (`binary_sensor.patio_fence_sensor`), windows (`binary_sensor.window_sensor_door`), and motion/vibration sensors.
  - **Battery**: Complete battery monitoring surfacing low-battery devices (< 60%) first, followed by area groupings (Patio, Kitchen, Office, Other Rooms).
- Created global template security warnings in `templates/security_warnings.yaml` (`binary_sensor.alert_patio_door_unlocked`, `binary_sensor.alert_patio_fence_open`, `binary_sensor.alert_front_door_open`, `binary_sensor.alert_patio_door_open`, `binary_sensor.alert_window_open`, `binary_sensor.active_security_warnings`) that trigger warning banners when entry points remain unsecured past safety thresholds (10m / 30m).
- Added `script.office_save_day_preset` and `script.office_save_night_preset` (`scripts/office_save_day_preset.yaml`, `scripts/office_save_night_preset.yaml`) to enable manual snapshotting and overwriting of Day and Night scenes directly from the NSPanel UI.
- Added `script.nspanel_audio_feedback` (`scripts/nspanel_audio_feedback.yaml`) to play audio/chime feedback through the NSPanel Pro speaker on state changes.
- Registered new dashboard URL `nspanel-office` in Home Assistant while synchronizing `nspanel-den` for seamless backward compatibility.

### Changed
- Renamed dashboard from Den to Office (`dashboards/nspanel-office.yaml`, title: "Office Panel").
- Consolidated header badges from 2 rows down to 1 single horizontal row across all panels by removing the redundant Presence badge (leaving Temp, Humidity, Light, Air, and PM2.5).
- Replaced dual 2-button "All Lights On" / "All Lights Off" row with a single large, contextual button that dynamically flips state, icon, color, active count badge, and service call.
- Updated `scripts/den_all_lights_on.yaml` and `scripts/den_all_lights_off.yaml` to trigger audio chime feedback and activate day presets.
- Added tactile haptic vibration feedback (`haptic: selection`) across all touch tiles and buttons.

## 0.7.0 - 2026-10-26

### Added
- Standardized Home Assistant area names, spoken aliases, and icons across 10 primary home spaces to optimize voice assistant recognition (Google Assistant, Alexa, Assist) for non-native English speakers.
- Added spoken voice aliases for key rooms (e.g., `Patio` aliases: `["Balcony", "Deck", "Backyard", "Outside", "Terrace", "Pátio"]`, `Office` aliases: `["Den", "Study", "Workroom", "Escritorio"]`, `Main Bedroom` aliases: `["Master Bedroom", "Master", "Quarto Principal", "Suite"]`).
- Established comprehensive multi-dimensional Label Taxonomy in Home Assistant:
  - Physical connectivity protocols: `wifi`, `zigbee`, `lora`, `matter_wifi`, `ethernet`, `bluetooth`.
  - Topology: `hub_connected` (reserved for YoLink & SwitchBot intermediate gateways).
  - Energy & metering: `power_monitoring` (applied to all active Watt and kWh measuring devices for upcoming energy dashboards).
  - Functional & Governance: `all_off_exempt`, `always_on`, `den_controlled_lights`, `git_managed`.
  - Domain categories: `light`, `fan`, `climate`, `media`, `camera`, `lock`, `sensor`, `switch`, `plug`, `mobile`, `system`.
- Created `automation.always_on_switch_watchdog_auto_recovery` to immediately restore power and dispatch critical push notifications if any critical switch labeled `always_on` (`switch.office_homelab_plug`, `switch.kitchen_freezer_plug`, `switch.office_fan_light_switch`, `switch.office_pc_plug`, `switch.living_room_tv_console_plug`) is ever turned off.
- Tagged `fan.office_air_purifier` with `all_off_exempt` and `git_managed` to protect room air filtration from bulk turn-off routines.
- Tagged `light.humidifier_night_light` with `den_controlled_lights` and `git_managed`, and integrated it into `script.den_all_lights_on` so that All Lights On/Off reliably controls the humidifier night light alongside room lights.
- Added Humidifier Night Light (`light.humidifier_night_light`) and Humidifier (`humidifier.humidifier`) tiles to the NSPanel Den dashboard (`dashboards/nspanel-den.yaml`), renaming the ceiling fan night light tile to "Fan Night Light" for clarity.
- Added **Naming Conventions & Voice Accessibility (Areas, Devices, Entity IDs)**, **Always-On Protection & Explicit Confirmation Mandate**, and **Govee Multi-Segment Fixtures (Domain Separation & Race Condition Prevention)** principles to `AGENTS.md` mandating clean device friendly names (omitting area prefix), full area-prefixed entity IDs (`<domain>.<area>_<descriptor>`), phonetic simplicity, proactive alignment checks, strict confirmation prompts before turning off any `always_on` device, and deterministic sequential domain calls (`light.turn_off` followed by `switch.turn_off`) for multi-segment Govee fixtures to prevent Cloud/LAN race conditions.
- Documented complete device inventory, entity transition mapping, and execution plan in `doc/2026-10-25-device-area-naming-review.md`, `doc/2026-10-25-device-area-execution-plan.md`, `doc/devices-inventory-and-proposals.csv`, and `doc/entities-inventory-and-proposals.csv`.

### Changed
- Standardized friendly names, area assignments, and labels across all 152 registered devices in Home Assistant, eliminating redundant area prefixes in UI dashboards and voice assistant prompts.
- Renamed 53 primary entity IDs in Home Assistant to adhere to the `<domain>.<area>_<descriptor>` global convention.
- Refactored repository automations (`automations/den_fan_light_state_tracker.yaml`, `automations/den_floor_lamp_mutual_exclusion.yaml`, `automations/den_presence_lighting.yaml`) to reference the newly standardized entity IDs.
- Refactored scripts (`scripts/den_all_lights_on.yaml`, `scripts/den_all_lights_off.yaml`) to target standardized entity IDs (`light.office_floor_lamp`, `light.office_desk_leds`, `switch.office_floor_lamp_side_light`, `light.office_ceiling_fan_backlight`).
- Refactored template sensors and template lights (`templates/den_sensors.yaml`, `templates/den_lights.yaml`) to reference standardized fan, lamp, and presence sensor entities.
- Updated the live NSPanel Den dashboard (`dashboards/nspanel-den.yaml` and live storage dashboard `nspanel-den`) in Home Assistant to reference the new entity IDs without breaking tile controls.

### Fixed
- Removed inadvertent `den_controlled_lights` label from non-lighting infrastructure devices (`HomeLab Plug`, `PC Plug`, `SLZB-MR4U` coordinator, `NSPanel Pro`, and `FP300`), preventing room-wide light turn-off scripts from cutting AC power to servers or hardware controllers.
- Configured Third Reality `HomeLab Plug` with `metering_only_mode: on` and `all_off_exempt` to permanently safeguard critical server infrastructure from accidental power cutoff.
- Restored missing badge and fan tile entities on the live NSPanel Den dashboard (`nspanel-den`) and updated Home Assistant UI template helpers (`sensor.den_pm2_5_level`, `sensor.den_light_level`, `sensor.den_presence_status`, `light.den_fan_light`, `light.den_night_light`) to query standardized entity IDs.
- Fixed `script.den_all_lights_off` leaving Govee Floor Lamp and Office LEDs turned on by replacing heterogeneous `homeassistant.turn_off` calls with deterministic, sequential domain turn-off commands (`light.turn_off` for primary lamps, followed by `switch.turn_off` for auxiliary sub-switches), eliminating Govee Cloud/LAN race conditions that inadvertently toggled parent lamps back on.

## 0.6.0 - 2026-10-05

### Added
- Created `automation.den_presence_adaptive_lighting` to automatically turn on and off Den lights using the Aqara FP300 presence sensor (`binary_sensor.fp300_den_presence`) with a 2-minute absence delay buffer.
- Added adaptive scheduling logic: turning on all controlled fixtures via `script.den_all_lights_on` during working days (09:00–18:00), and turning on fixtures labeled `den_night_lights` during off-hours, weekends, and holidays.
- Integrated British Columbia / Vancouver statutory holiday detection and custom vacation tracking using a dedicated Local Calendar `calendar.den_holidays`, pre-populated with official BC statutory holidays for 2026 and 2027.
- Created template binary sensor `binary_sensor.den_is_workday` which defaults Monday–Friday as workdays unless an event is active on `calendar.den_holidays` (leaving the calendar UI uncluttered by Mon–Fri workday events).
- Created template sensor `sensor.den_presence_status` providing human-readable status (`Active (Occupied)`, `Active (Clear)`, `Paused (Resumes Tomorrow)`, or `Disabled`).
- Created helpers `input_boolean.den_presence_automation` (master toggle) and `input_boolean.den_presence_override` (daily pause flag).
- Created functional label `den_night_lights` (`mdi:weather-night`, purple) and tagged `light.den_night_light`, `switch.den_floor_lamp_side_light`, and `light.humidifier_night_light`, enabling flexible assignment of night lights without modifying automations.
- Created `script.den_presence_toggle` allowing one-tap resuming or pausing of presence automation without abruptly modifying current light states.
- Added Motion Presence Control button card and Presence badge to the Den NSPanel dashboard (`dashboards/nspanel-den.yaml`).
- Tagged all newly created entities, helpers, scripts, and automations with `git_managed` for repository provenance governance.
- Added 09:00:00 workday morning transition trigger to `automation.den_presence_adaptive_lighting`, automatically promoting active presence from Night Lights to full workday lighting, and unified absence shut-off to reliably extinguish both `den_night_lights` and daytime fixtures when leaving at any time of day.
- Documented implementation plan in `doc/2026-10-03-den-fp300-presence-lighting.md`.

- Refactored `script.den_all_lights_on` to consistently turn on all primary Den fixtures (`light.floor_lamp`, `light.office_leds`, `light.den_fan_light`, `switch.den_floor_lamp_side_light`), eliminating legacy partial-snapshot restoration that caused incomplete lighting during presence activation.
- Added `override` parameter to `script.den_all_lights_on` (defaulting to `true` when pressed from the dashboard) to pause presence automation for the day, while `automation.den_presence_adaptive_lighting` passes `override: false` to keep presence tracking active.
- Updated `script.den_all_lights_off` to reliably clear `input_boolean.den_presence_override` and restore presence automation.

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
