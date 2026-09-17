# Plan: Sonoff NSPanel 120 Pro Dashboard for Den

**Date**: 2026-09-16  
**Status**: Approved  
**Target Hardware**: Sonoff NSPanel 120 Pro (4.7-inch 750x1334 portrait touch display)  
**Location**: Den room

---

## Overview

Create a dedicated, touch-optimized Home Assistant dashboard designed specifically for a Sonoff NSPanel 120 Pro mounted in the **Den**. The dashboard serves as the primary room controller with master lighting controls, individual dimmable RGB light controls, and smart fan controls.

---

## Technical Context & Decisions

### Smart Fan Entity Decision
- **Inspection Finding**: The Tuya device named "Smart fan" in the Den (`device_id: 0feae5aa3f242150323b0be4bc930fe9`) was imported under Tuya category `xdd` (ceiling light). Home Assistant currently exposes `light.smart_fan` (RGB + brightness dimmer) and `light.smart_fan_night_light` (on/off), but no `fan.smart_fan` entity yet. The only active `fan` entity in the Den is `fan.air_purifier`.
- **Approved Decision**: Target `fan.smart_fan` directly in the dashboard cards so fan motor controls (speed slider, direction, preset modes) are pre-configured and ready immediately when mapped. Also include `fan.air_purifier` for room air circulation controls.

### Form Factor Optimization
- **Screen Size**: 4.7-inch 750x1334 portrait touch screen (3:4 / 9:16 aspect ratio).
- **Layout Architecture**: Modern Home Assistant `sections` view constrained to `max_columns: 1`.
- **Touch Targets**: 2-column card grids with large touch targets, direct brightness sliders, and single-tap `more-info` dialogs for deep RGB color and temperature picking.

---

## Architecture & Configuration

### Dashboard: `nspanel-den`
- **View: Den (`path: den`)**:
  - **Header Badges**:
    - Air Quality indicator (`sensor.air_purifier_air_quality` / `sensor.air_purifier_pm2_5`).
  - **Section 1: Den Master Controls**:
    - Heading card `"Den Controls"` with inline action button badges for instant `Turn Off All Lights` and `Turn On All Lights` targeting `area_id: "den"`.
    - Master Room Lighting Tile / Button Pair for whole-room toggle.
  - **Section 2: Room Lights (Dimmers & RGB)**:
    - 2-column grid of touch-friendly Tile cards:
      - `light.h60b0` ("Celling Light") with `light-brightness` slider feature and tap action opening color palette / RGB picker.
      - `light.h6061` ("Wall Lights") with `light-brightness` slider feature and tap action opening color palette / RGB picker.
      - `light.h6076` ("Floor Light") with `light-brightness` slider feature and tap action opening color palette / RGB picker.
      - `light.smart_fan` ("Smart fan Light") with `light-brightness` slider feature and tap action opening color palette.
      - `light.smart_fan_night_light` ("Night Light") toggle tile.
  - **Section 3: Climate & Smart Fan**:
    - Smart Fan Tile (`fan.smart_fan`):
      - `fan-speed` feature (interactive touch slider percentage).
      - `fan-direction` feature (forward/reverse controls).
      - `fan-preset-modes` feature.
    - Air Purifier Tile (`fan.air_purifier`):
      - Preset mode selector (`auto`, `sleep`) and power toggle.

---

## File Deliverables

- `dashboards/nspanel-den.yaml`: Version-controlled YAML definition of the dashboard.
- `doc/2026-09-16-nspanel-den.md`: Documented implementation plan.
- `AGENTS.md`: Updated guidance to persist future implementation plans in `doc/YYYY-MM-DD-<topic>.md`.
- `VERSION`: Updated to `0.2.0` (MINOR increment).
- `CHANGELOG.md`: Release notes for `0.2.0`.
- Home Assistant storage-mode registration via `ha_config_set_dashboard` (`url_path: nspanel-den`).
