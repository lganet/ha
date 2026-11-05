# Implementation Plan: Homelab & Energy Panels for NSPanel Pro

**Date**: 2026-11-04  
**Status**: In Progress  
**Target Device**: Sonoff NSPanel 120 Pro (4.7-inch 750x1334 portrait touch display)  
**Location**: Office  
**Target Files**:
- `dashboards/nspanel-office.yaml`
- `scripts/den_all_lights_on.yaml`
- `scripts/den_all_lights_off.yaml`
- `scripts/office_activate_night_preset.yaml`

---

## 1. Goal Description

1. **Resolve NSPanel Beeping on Motion**: Ensure audio feedback is strictly tied to physical screen touch actions by applying the `if: sound` guard across all live storage-mode scripts (`script.den_all_lights_on`, `script.den_all_lights_off`, `script.office_activate_night_preset`).
2. **Homelab Panel (`path: homelab`)**: Add a dedicated system monitoring view to the NSPanel Pro dashboard covering:
   - Proxmox Virtual Environment (PVE Node Status, CPU, RAM, Disk, Uptime)
   - Homelab VMs/Containers: OPNsense firewall, Docker, Tailscale
   - Kitchen Closet Homelab Fan Thermal Watchdog: YoLink closet temperature, Proxmox CPU/NVMe temperatures, fan power draw and active cooling speed.
3. **Energy Panel (`path: energy`)**: Add a dedicated real-time power and energy monitoring view to the NSPanel Pro dashboard covering:
   - Real-time whole-home load summary from monitored smart plugs and relays
   - Computing & Homelab power meters (Homelab plug, PC plug, Closet fan plug, TV Gaming plug)
   - Major appliances (Kitchen freezer plug, Refrigerator, Air purifier plug, Bedside plug)
   - Measured smart relays (Bathroom fan, Patio light, Office fan light)
   - Integration guidance and placeholder for BC Hydro (`porelli/bchydro-ha`).

---

## 2. Architecture & Design Principles

### NSPanel Pro 120 Optimization
- **Viewport**: Scoped for a portrait 750×1334 screen (~375px usable CSS width).
- **Layout**: Single-column sections (`max_columns: 1`) with internal 2-column grids (`columns: 2`, `square: false`).
- **Touch Targets**: Minimum 56-60px height with clean icon-text hierarchy to prevent clipping.
- **Safety / Always-On**: All smart plugs tagged `always_on` remain purely monitored (`tap_action: more-info`), never exposed to accidental power toggling.

---

## 3. Tasks

- [x] Fix live Home Assistant lighting scripts (`den_all_lights_on`, `den_all_lights_off`, `office_activate_night_preset`) so audio feedback only triggers on physical touch (`sound: true`).
- [ ] Create View 7 (`path: homelab`) in `dashboards/nspanel-office.yaml`.
- [ ] Create View 8 (`path: energy`) in `dashboards/nspanel-office.yaml`.
- [ ] Deploy updated dashboard views to Home Assistant storage mode via `ha_config_set_dashboard`.
- [ ] Validate YAML and dashboard structure.
- [ ] Document BC Hydro configuration steps for the user.
- [ ] Commit changes to `feature/office-nspanel-redesign` and update `CHANGELOG.md`.
