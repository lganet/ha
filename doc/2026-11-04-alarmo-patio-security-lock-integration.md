# Implementation Plan: Alarmo Security, Patio Cameras & Door Lock Integration

**Date**: 2026-11-04  
**Feature Branch**: `feature/office-nspanel-redesign`

---

## 1. Objectives & Overview
Integrate the newly installed Alarmo integration (`alarm_control_panel.alarmo`) with:
1. **Patio Cameras (`alarm_control_panel.gushomebase`)**:
   - Synchronize security states bidirectionally (`armed_home`, `armed_away`, `disarmed`).
   - Changing status via Alarmo will update Patio Cameras accordingly.
2. **Patio Door Lock (`lock.patio_door_lock`)**:
   - Only unlocking requires user code verification.
   - When Alarmo is disarmed with a valid user PIN, `lock.patio_door_lock` automatically unlocks.
   - Locking the door remains one-touch and does not require a code.
   - On the NSPanel Pro dashboard, tapping the locked door prompts for the Alarmo security code/keypad rather than allowing unauthenticated unlock.
3. **NSPanel Pro Dashboard (`dashboards/nspanel-office.yaml`)**:
   - Update View 0 (Main Office Panel) Security & Access row with `alarm_control_panel.alarmo` and protected Patio Lock controls.
   - Add a full `alarm-panel` card in View 5 (`alerts`) and an active-keypad card in View 0 when armed.
4. **User Guidance**:
   - Provide clear, step-by-step instructions for creating and managing individual user PIN codes in Alarmo's web UI.

---

## 2. Resource & State Architecture

### A. Entities Involved
- `alarm_control_panel.alarmo`: Alarmo integration security entity with multi-user PIN management and built-in keypad support.
- `alarm_control_panel.gushomebase`: Eufy Patio Cameras alarm base station (`disarmed`, `armed_home`, `armed_away`).
- `lock.patio_door_lock`: Physical smart deadbolt for the patio entrance (`locked`, `unlocked`).

### B. Automation: `automation.alarmo_patio_security_sync`
Tracked in `automations/alarmo_patio_security_sync.yaml`:
- **Trigger A (Alarmo State Change)**:
  - `to_state == 'disarmed'`:
    - Disarm `alarm_control_panel.gushomebase`.
    - Unlock `lock.patio_door_lock` (if locked).
  - `to_state == 'armed_home'`:
    - Arm `alarm_control_panel.gushomebase` to `armed_home`.
    - Do NOT lock the door (preserves user preference for manual door locking).
  - `to_state == 'armed_away'`:
    - Arm `alarm_control_panel.gushomebase` to `armed_away`.
    - Do NOT force lock unless already locked.
- **Trigger B (GusHomeBase State Change)**:
  - If changed externally (e.g. from Eufy app), sync `alarm_control_panel.alarmo` to match (`armed_home`, `armed_away`, `disarmed`), preventing state bounce with loop guards.

### C. Dashboard Controls (NSPanel Pro)
- **View 0 (Office Main Panel)**:
  - Patio Security tile targeting `alarm_control_panel.alarmo`. Tapping Disarm prompts for the user code.
  - Patio Lock card:
    - When `unlocked`: Green indicator, tapping immediately calls `lock.lock` (no code needed).
    - When `locked`: Red indicator `Locked (Code Req.)`, tapping opens `alarm_control_panel.alarmo` keypad dialog.
  - Conditional keypad card: When Alarmo is `armed_home` or `armed_away`, displays the touch keypad directly on the screen for swift disarming.
- **View 5 (`alerts`)**:
  - Adds dedicated "Patio Security & Alarm" section with full `alarm-panel` card.

---

## 3. Step-by-Step Execution Plan
1. Create automation `automations/alarmo_patio_security_sync.yaml`.
2. Deploy automation live to Home Assistant via `ha_config_set_automation` and label with `git_managed`.
3. Update `dashboards/nspanel-office.yaml` with the new security cards and deploy live via `ha_config_set_dashboard`.
4. Validate automation triggering and state transitions.
5. Update `CHANGELOG.md` and commit to `feature/office-nspanel-redesign`.
6. Present clear step-by-step instructions for creating per-user codes in Alarmo.
