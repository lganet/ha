# Implementation Plan: Notification Badges on All Lights Controls

## Context & Objectives
The user requested notification badges showing total active/inactive light counts on the "All Lights On" and "All Lights Off" buttons for the Sonoff NSPanel 120 Pro Den dashboard. The user specifically provided a reference screenshot (`media_1789627860351.png`) showing a circular green badge with a bold count number overlapping the top-right corner of the button's icon.

Native Home Assistant `button` cards only support plain state text beneath the label, and heading badges render as chips. To achieve the exact icon overlay badge requested, `custom-cards/button-card` was installed via HACS and registered as a dashboard module resource.

## Proposed Changes
1. **`dashboards/nspanel-den.yaml`**:
   - Update the "All Lights On" card to use `type: custom:button-card`:
     - Icon: `mdi:lightbulb-group`
     - Action: Call service `light.turn_on` for area `den`
     - `custom_fields.notification`: JavaScript template reading `states['sensor.den_lights_on'].state`
     - `styles`:
       - `img_cell` and `icon`: centered touch target
       - `custom_fields.notification`: circular badge overlapping the top-right of the icon (`background-color: #4CAF50`, `color: white`, `border-radius: 50%`, `position: absolute`, `width: 24px`, `height: 24px`, font styling).
   - Update the "All Lights Off" card to use `type: custom:button-card`:
     - Icon: `mdi:lightbulb-group-off`
     - Action: Call service `light.turn_off` for area `den`
     - `custom_fields.notification`: JavaScript template reading `states['sensor.den_lights_off'].state`
     - `styles`: circular badge with matching styling (`background-color: #546E7A`, `color: white`, `border-radius: 50%`, `position: absolute`, `width: 24px`, `height: 24px`, font styling).
2. **Sync Live Dashboard**:
   - Update `nspanel-den` via `ha_config_set_dashboard` MCP tool.
3. **Documentation & Versioning**:
   - Increment `VERSION` (`0.2.1` patch update).
   - Update `CHANGELOG.md` with details of the change.

## Verification
- Verify `dashboards/nspanel-den.yaml` YAML syntax.
- Verify live dashboard updates successfully in Home Assistant via MCP.
- Verify responsive layout preserves NSPanel 120 Pro (750x1334 portrait) touch targets.
