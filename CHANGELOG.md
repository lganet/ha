# Changelog

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
