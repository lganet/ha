# Implementation Plan & Benchmark: 4-Speed Closed-Loop Homelab Cooling Automation

**Date:** 2026-10-31  
**Target Automation:** `automations/fan_thermal_cooling_watchdog.yaml` (`automation.closet_homelab_fan_thermal_watchdog`)  
**Status:** Implemented & Verified on Hardware  

---

## 1. Verified Hardware Power Benchmarks

Tested live using Third Reality Zigbee Smart Plug (`switch.fan_opnsense_plug`) and HOBEIAN Zigbee IR Blaster:

| Setting | Measured Power (Watts) | Profile | Action in Automation |
| :---: | :---: | :--- | :--- |
| **Standby / Off** | **`0.8 W`** ($< 3.0\text{ W}$) | Motor stopped | Cooldown state (`pve_status` confirmed off + temp < 23.5°C) |
| **Speed 1** | **`13.8 W – 14.5 W`** ($> 10\text{ W}$) | Silent / Gentle | Base cooling ($T \ge 25.0^\circ\text{C}$ or fail-safe trigger) |
| **Speed 2** | **`19.2 W – 19.5 W`** | Moderate | Increased load / ambient ($T \ge 27.0^\circ\text{C}$) |
| **Speed 3** | **`24.8 W`** | High Airflow | Warm closet ($T \ge 29.0^\circ\text{C}$) |
| **Speed 4** | **`28.2 W`** | **Max Turbo** | Emergency cooling ($T \ge 31.0^\circ\text{C}$ or CPU $\ge 75^\circ\text{C}$) |

---

## 2. Speed Stepping & Self-Healing Watchdog Architecture

```mermaid
flowchart TD
    Trigger["Periodic Watchdog (2m) OR<br/>YoLink Temp Update OR<br/>Proxmox Status/CPU Update OR<br/>Plug Turned On / HA Startup"] --> CheckTrigger{"Trigger is Plug Power-On<br/>or HA Startup?"}

    CheckTrigger -->|YES: Blackout / Boot| BlackoutRecovery["1. Wait 15s for Zigbee/Plug Telemetry to Settle<br/>2. Guarantee Power Pulse via switch.toggle<br/>3. Apply Target Speed based on Temp"]

    CheckTrigger -->|NO: Periodic / Temp| CheckOff{"Is Proxmox 100% OFF?<br/>(pve_status == 'offline'/'off'<br/>AND YoLink < 23.5°C)"}

    CheckOff -->|YES| SafeOff["Safe Shutdown: Pulse IR 'Turn Off'<br/>Power drops to 0.8W"]

    CheckOff -->|NO: Running or Uncertain| CheckPower{"Current Fan State<br/>(sensor.fan_opnsense_plug_power)"}

    CheckPower -->|Standby: Watts < 3.0W OR Plug Off| SelfHeal["1. Ensure Plug ON<br/>2. Fire IR Toggle (Starts Speed 1: 14W)<br/>3. Wait 2s for Fan to Register<br/>4. Immediately Apply Target Speed (1, 2, 3, or 4)"]

    CheckPower -->|Running: Watts ≥ 10.0W| SpeedTiers{"Check Temperature Tiers (Pre-Check: Watts > 10W)"}

    SpeedTiers -->|Temp ≥ 31°C & Watts < 26.5W| ToSpeed4["Pulse Speed Up -> Speed 4 (28W Turbo)"]
    SpeedTiers -->|Temp ≥ 29°C & Watts < 22.0W| ToSpeed3["Pulse Speed Up -> Speed 3 (25W)"]
    SpeedTiers -->|Temp ≥ 27°C & Watts < 17.0W| ToSpeed2["Pulse Speed Up -> Speed 2 (19W)"]
    SpeedTiers -->|Temp < 26°C & Watts > 17.0W| StepDown["Pulse Speed Down -> Step Down towards Speed 1"]
```

---

## 3. Physical Hardware Quirks & Solutions

### A. Stateless IR Remote Button Reset (Toggle vs Double-Click)
- **Problem:** `switch.kitchen_ir_remote_switch_1` represents a single toggle button on the physical IR remote learned for both ON and OFF. Calling `switch.turn_on` followed by `switch.turn_off` transmits **two consecutive IR pulses**, turning the fan on and immediately off.
- **Solution:** Use `action: switch.toggle` across all scenarios. Calling `switch.toggle` sends exactly ONE IR pulse regardless of current entity state, preventing double-clicks and ensuring the signal is never dropped by Home Assistant.

### B. Stale Power Metric Resolution on Boot / Recovery
- **Problem:** On HA restart or smart plug reconnection, `sensor.fan_opnsense_plug_power` restores its pre-outage value ($14.2\text{ W}$) until the physical plug transmits a fresh measurement. This blocked the `< 3.0\text{ W}` condition.
- **Solution:** Dedicated Scenario 0 for `plug_turned_on` and `ha_started`: waits 15 seconds for plug connection and guarantees the IR Power pulse is transmitted regardless of cached pre-outage wattage.

### C. Live Power-Cycle Blackout Test Verification
- **Verified on Hardware (Trace `ac4775bde6211d75649c21aacae817b9`):**
  - Plug powered off: power dropped to `0.0 W`.
  - Plug turned on: triggered Scenario 0 immediately.
  - Settling delay: paused 15 seconds for Zigbee network stabilization.
  - Power pulse: fired `switch.toggle` on `switch.kitchen_ir_remote_switch_1`.
  - Fan response: automatically started up into Speed 1; measured power climbed to **`13.8 W`** and remained stable.
  - Mode: configured with `mode: restart` to prevent trigger drops when power-on events coincide with periodic timers.

---

## 4. Fail-Safe Mode (Uncertainty Principle)
* If `binary_sensor.pve_status` is `unavailable` or `unknown`: **Fan Forced ON**.
* If `sensor.temperature_sensor_temperature` is `unavailable` or `unknown`: **Fan Forced ON**.
* If `sensor.fan_opnsense_plug_power` is `unavailable` or `unknown`: **Fan Forced ON**.
* If YoLink battery drops below $10\%$: **Fan Forced ON**.
* Third Reality hardware setting `select.fan_opnsense_plug_power_on_behavior` is set to `on` (relay closes instantly on line power return).
* Periodic watchdog interval runs every 2 minutes (`minutes: "/2"`) ensuring automatic self-healing even if an IR command is ever missed.
