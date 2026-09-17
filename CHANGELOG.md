# Changelog

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
