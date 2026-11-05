# Implementation Plan: Billing Period Energy Alignment & Presence-Based NSPanel Screen Management

**Date**: 2026-11-04  
**Branch**: `feature/office-nspanel-redesign`

---

## 1. Objectives

1. **Energy Billing Period Alignment**:
   - Align all smart plug and appliance energy meters with the BC Hydro billing period starting on `sensor.bc_hydro_mission_billing_period_start` (`2026-10-21`).
   - Subtract the baseline readings as of October 21 so devices report period-to-date kWh and accurate cost (e.g., Refrigerator ~$3.37 instead of lifetime $129+).
   - Display the billing period start date (`Since Oct 21`) and cycle progress prominently in the Energy view.
   - Establish baseline tracking that automatically rolls over when BC Hydro starts a new billing period.

2. **Presence-Based NSPanel Screen Lifecycle**:
   - Remove the abrupt `switch.turn_off` from `automations/nspanel_security_warning_alert.yaml` on `warning_cleared`.
   - Implement `automations/nspanel_screen_presence.yaml` to wake the screen when `binary_sensor.office_presence_fp300` detects presence, and turn the screen off only when presence is cleared (`for: 00:02:00`), strictly verifying that no security warning is active.

---

## 2. Resource Modifications

### Configuration & Automation Files
- `automations/nspanel_security_warning_alert.yaml`: Remove `switch.turn_off` on `warning_cleared` so fixing an alert does not interrupt the user with the screensaver.
- `automations/nspanel_screen_presence.yaml`: New automation managing screen power tied to FP300 room presence with security warning guard.
- `helpers/energy_billing_helpers.yaml`: Version-controlled helper definition for billing cycle baselines and roll-over tracking.
- `automations/energy_billing_cycle_rollover.yaml`: Automation to snapshot energy baselines when `sensor.bc_hydro_mission_billing_period_start` changes.
- `dashboards/nspanel-office.yaml`: Update View 7 (Energy) with billing period start date chips, period progress, and baseline-subtracted energy & cost calculations.

### Live Home Assistant Deployments
- `ha_config_set_automation` for `nspanel_security_warning_alert`, `nspanel_screen_presence`, and `energy_billing_cycle_rollover`.
- `ha_config_set_dashboard` for `nspanel-office` View 7.

---

## 3. Verification Steps
1. Verify automation YAML syntax and deploy to live HA.
2. Verify dashboard YAML syntax and deploy to live HA storage.
3. Verify live states of sensors, helpers, and screen switch.
4. Review git diff and update `CHANGELOG.md`.
