# Implementation Plan: Vacation House Occupancy Simulation

- **Date:** 2026-11-16
- **Task:** Vacation House Occupancy Simulation system for GusNet Home Assistant
- **Target Repository:** `/home/gustavo/src/ha-vacation-occupancy-simulation`

## 1. Objective & Scope

Implement an automated Vacation House Occupancy Simulation system in the GusNet Home Assistant configuration (`ha` repo) to simulate realistic resident activity during an extended 3-month absence.

The system will:
1. Provide a master helper `input_boolean.vacation_simulation_mode` protected and synchronized with Alarmo area `alarm_control_panel.vacation_simulation` requiring PIN code authorization via a popup modal keypad.
2. Integrate secure Vacation Mode control cards on both NSPanel Pro dashboards (`dashboards/nspanel-office.yaml` and `dashboards/nspanel-main-bedroom.yaml`).
3. Implement a comprehensive automation (`automations/vacation_occupancy_simulation.yaml`) covering:
   - Morning Routine (08:00–09:00): Echo Spot wakeup chime at 08:00 (1 min, vol 0.3); FP2 illuminance-based kitchen lighting if light level < 50 for 30 minutes.
   - Working Hours (10:00–17:30): Random/staggered intervals (15–45 min on, 30–60 min off) across dining room light, kitchen hallway light, and lamp; periodic Spotify background audio via Alexa on Echo; strict mutual exclusion stopping audio if SHIELD TV is active.
   - Evening TV & Leisure (18:00–22:00): SHIELD TV activation via remote/media_player, launching YouTube app (`com.google.android.youtube.tv`), synchronized ambient lighting (TV backlight + lamp), running 45–90 min sessions twice before 22:00.
   - Patio Evening Lighting (20:00–23:00): Left and right patio fixture switches active during dark hours, off at 23:00.
   - Late Night Activity (22:00–06:00): Intermittent short 2–8 minute low-brightness lighting bursts across hallway, kitchen hallway, bedroom light 2, and kitchen LEDs.
4. Adhere strictly to AGENTS.md principles:
   - Git-managed labels (`git_managed`).
   - State preservation and domain separation for smart fixtures and Govee segments.
   - Semantic versioning (0.17.0 -> 0.18.0) and CHANGELOG.md documentation with rollback instructions.

## 2. Resources & Files Affected

| Resource / File | Action | Purpose |
|-----------------|--------|---------|
| `helpers/vacation_simulation_helpers.yaml` | Create | Define `input_boolean.vacation_simulation_mode` |
| `automations/alarmo_vacation_simulation_sync.yaml` | Create | Bidirectional PIN synchronization between Alarmo and helper |
| `automations/vacation_occupancy_simulation.yaml` | Create | Complete simulation routine schedules and mutual exclusion |
| `dashboards/nspanel-office.yaml` | Update | Add Vacation Mode button-card matching Patio Lock UX pattern |
| `dashboards/nspanel-main-bedroom.yaml` | Update | Add Vacation Mode button-card matching Patio Lock UX pattern |
| `VERSION` | Update | Bump 0.17.0 -> 0.18.0 |
| `CHANGELOG.md` | Update | Add release notes, technical details, verification, and rollback |
| `doc/2026-11-16-vacation-occupancy-simulation.md` | Create | Architectural implementation plan |

## 3. Lighting & State Preservation Strategy

Per AGENTS.md lighting principles:
- **Preserve User Preferences:** Daytime and evening lighting routines issue bare `light.turn_on` calls without overriding color temperatures or brightness, allowing fixtures to restore their last user profile or app state.
- **Explicit Low-Brightness Bursts:** For late night routines (22:00–06:00), low brightness (`brightness_pct: 15`) is explicitly specified to mimic nighttime movement without blinding or flashing.
- **Domain Separation:** In-wall switch controls (`switch.patio_left_light_switch`, `switch.patio_right_light`) and lighting entities (`light.patio_left_light`, `light.living_room_tv_backlight`, `light.kitchen_leds`) are isolated and never combined in broad area turn-offs.
- **Always-On Protection:** No plugs or infrastructure tagged with `always_on` are referenced or switched.
- **Entity ID Aliasing & Resolution:**
  - `light.tv_backlight` maps directly to verified entity `light.living_room_tv_backlight` (with fallback to `light.tv_backlight`).
  - `light.lamp` maps to verified entity `light.patio_left_light` (Lamp HS220, with fallback to `light.lamp`).
  - `light.leds` maps to verified entity `light.kitchen_leds` (with fallback to `light.leds`).

## 4. Detailed Component Implementation

### 4.1 Helpers (`helpers/vacation_simulation_helpers.yaml`)
```yaml
# Version-controlled reference for vacation simulation helpers
input_boolean:
  vacation_simulation_mode:
    name: Vacation Simulation Mode
    icon: mdi:home-clock
```

### 4.2 Alarmo PIN Synchronization (`automations/alarmo_vacation_simulation_sync.yaml`)
Mirrors `automations/alarmo_patio_lock_sync.yaml`:
- Mode: `queued`, max 5.
- Labels: `git_managed`.
- Triggers:
  - `alarm_control_panel.vacation_simulation` state change (`id: alarmo_state`).
  - `input_boolean.vacation_simulation_mode` state change (`id: helper_state`).
  - `alarm_control_panel.vacation_simulation` coming online from unavailable/unknown (`id: alarmo_initialized`).
- Conditions: `trigger.from_state is not none and trigger.to_state is not none and trigger.from_state.state != trigger.to_state.state`.
- Actions:
  - Alarmo disarmed -> `input_boolean.turn_off`.
  - Alarmo armed (`armed_away`, `armed_home`, `armed_vacation`) -> `input_boolean.turn_on`.
  - Helper turned on -> `alarm_control_panel.alarm_arm_away`.
  - Helper turned off -> `alarm_control_panel.alarm_disarm`.
  - Initialized -> align Alarmo state to helper.

### 4.3 NSPanel Pro Dashboard Cards
Added to View 0 Security & Access sections in both `nspanel-office.yaml` and `nspanel-main-bedroom.yaml`:
```yaml
          # --- Vacation Simulation Mode ---
          - type: custom:button-card
            entity: input_boolean.vacation_simulation_mode
            name: Vacation Mode
            show_name: true
            show_state: true
            state_display: >-
              [[[
                var al = states['alarm_control_panel.vacation_simulation'];
                var hasPin = al && al.state && al.state !== 'unavailable' && al.state !== 'unknown';
                if (entity.state === 'on') {
                  return hasPin ? 'Vacation Mode (PIN Req)' : 'Active';
                }
                return hasPin ? 'Disabled (PIN Req)' : 'Disabled (Tap Arm)';
              ]]]
            icon: >-
              [[[
                return entity.state === 'on' ? 'mdi:shield-airplane' : 'mdi:home-account';
              ]]]
            tap_action:
              action: >-
                [[[
                  var al = states['alarm_control_panel.vacation_simulation'];
                  if (!al || al.state === 'unavailable' || al.state === 'unknown') {
                    return 'toggle';
                  }
                  return 'more-info';
                ]]]
              entity: alarm_control_panel.vacation_simulation
              haptic: selection
            styles:
              card:
                - min-height: 58px
                - padding: 8px 10px
                - border-radius: var(--ha-card-border-radius, 12px)
                - background-color: rgba(255, 255, 255, 0.05)
                - border: >-
                    [[[
                      return entity.state === 'on' ? '1px solid rgba(255, 152, 0, 0.4)' : '1px solid rgba(255, 255, 255, 0.1)';
                    ]]]
              grid:
                - grid-template-areas: '"i n" "i s"'
                - grid-template-columns: 32px 1fr
                - grid-template-rows: 1fr 1fr
                - align-items: center
              icon:
                - width: 22px
                - height: 22px
                - color: >-
                    [[[
                      return entity.state === 'on' ? '#FFA726' : 'var(--secondary-text-color, #CCCCCC)';
                    ]]]
              name:
                - font-size: 13px
                - font-weight: 600
                - justify-self: start
                - color: var(--primary-text-color)
              state:
                - font-size: 11px
                - font-weight: 500
                - justify-self: start
                - color: >-
                    [[[
                      return entity.state === 'on' ? '#FFA726' : 'var(--secondary-text-color, #CCCCCC)';
                    ]]]
```

### 4.4 Vacation Simulation Routine (`automations/vacation_occupancy_simulation.yaml`)
- Automation ID: `1794200000002`
- Alias: `Vacation House Occupancy Simulation`
- Mode: `parallel`, max: 20
- Condition: `condition: state, entity_id: input_boolean.vacation_simulation_mode, state: 'on'`
- Triggers:
  - `time: "08:00:00"` (Morning wakeup audio)
  - `time: "08:00:00"`, `time: "08:30:00"`, `numeric_state: < 50` between 08:00-09:00 (Morning kitchen lighting)
  - `time: "10:15:00"`, `"11:45:00"`, `"13:30:00"`, `"15:00:00"`, `"16:30:00"`, `"17:30:00"` (Working hours lighting intervals & cleanup)
  - `time: "11:00:00"`, `"14:15:00"` (Working hours background audio via Alexa on Echo)
  - `state` of `media_player.shield_2` or `remote.shield` to `playing` / `on` (Strict audio suppression)
  - `time: "18:15:00"` (Evening TV Session 1)
  - `time: "20:00:00"` (Evening TV Session 2)
  - `time: "22:00:00"` (Evening TV Cleanup)
  - `time: "20:00:00"`, `sunset`, `time: "23:00:00"` (Patio evening lighting on/off)
  - `time: "23:45:00"`, `"01:30:00"`, `"03:15:00"`, `"05:10:00"`, `"06:00:00"` (Late night intermittent bursts & cleanup)
  - `state: input_boolean.vacation_simulation_mode` to `off` (Global disarm cleanup)

## 5. Verification & Validation Plan
1. Validate YAML syntax using Python YAML parser (`yaml.safe_load`).
2. Run automated validation checks on modified dashboard configs and automations.
3. Verify live entities via Home Assistant MCP tools (`ha_search`, `ha_config_get_automation`).
4. Validate version bump in `VERSION` and format in `CHANGELOG.md`.

## 6. Comprehensive Schedule Table: Vacation House Occupancy Simulation

The schedule below details the finalized, live-validated routine running under `automation.vacation_house_occupancy_simulation`, guarded by `input_boolean.vacation_simulation_mode`:

### 6.1 Daily Foundation (Every Day)

| Time / Trigger | Routine / Phase | Target Entities | Simulated Behavior & Safeguards |
| :--- | :--- | :--- | :--- |
| **08:00:00** | **Morning Wakeup Audio** | `media_player.luis_s_echo_spot` | Dynamic daily rotation across 3 wake-up styles at volume `0.3`:<br>1. 🎵 **Morning Music**: Streams morning acoustic music on Spotify for **15 minutes**.<br>2. ⏰ **Alarm Tone**: Plays morning alarm sound for **2 minutes**.<br>3. 🗣️ **Morning Greeting**: Executes `"good morning"`, reading daily greeting, weather, and date. |
| **08:00 – 08:25** | **Morning Bedroom Light** | `light.main_bedroom_fan_light` | Main bedroom ceiling fan light turns on for **25 minutes** to simulate waking up, then turns off. |
| **08:00 – 09:00** | **Morning Ambience** | `light.kitchen_lights`<br>`light.kitchen_leds`<br>`sensor.fp2_light_sensor` | Checks ambient light: if dark (`< 50 lx`), turns on Kitchen lights and LEDs for **30 minutes**, then turns off. |
| **20:00 – 23:00** | **Patio Evening Lighting** | `switch.patio_left_light_switch`<br>`switch.patio_right_light` | Turns on patio exterior lights at 20:00 (or sunset if later) and powers off at 23:00. |
| **22:00, 22:15, 22:30** | **Overnight TV Safety Sweeps** | `media_player.living_room_samsung_oled`<br>`remote.shield`<br>TV Backlight & Lamp | Triple safety sweep ensuring SHIELD, Samsung TV, and accent lights are strictly off. |
| **22:00 – 08:00** | **Overnight TV Safety Watchdog** | `media_player.living_room_samsung_oled` | Triggered if Samsung TV stays on for >5 minutes during the night; immediately powers off TV and SHIELD. |
| **23:45 – 23:49** | **Late Night Burst 1** | `light.hallway_lights`<br>`light.kitchen_hallway_light` | Hallway transit: turns on at **70% brightness** for **4 minutes**, then turns off. |
| **01:30 – 01:33** | **Late Night Burst 2** | `light.main_bedroom_light_2` | Bedroom movement: turns on at **10% brightness** for **3 minutes**, then turns off. |
| **03:15 – 03:20** | **Late Night Burst 3** | Kitchen LEDs (`light.kitchen_leds` / `light.leds`)<br>`light.kitchen_hallway_light` | Nighttime water/snack: turns on at **15% brightness** for **5 minutes**, then turns off. |
| **05:10 – 05:13** | **Late Night Burst 4** | `light.hallway_lights`<br>`light.kitchen_hallway_light` | Early transit: turns on at **70% brightness** for **3 minutes**, then turns off. |
| **06:00:00** | **Late Night Cleanup** | Hallway, Kitchen Hallway, Night Light, Bedroom 2, LEDs | Sweep ensuring all late-night burst fixtures are unconditionally turned off. |
| **Any Time** | **Disarm / Shutdown Cleanup** | All simulation lights, switches, TVs, and Alexa players | Triggered whenever Vacation Mode is turned off: immediately halts all playback and shuts off all lights. |

### 6.2 Weekdays (`mon, tue, wed, thu, fri`)

| Time / Trigger | Routine / Phase | Target Entities | Simulated Behavior & Safeguards |
| :--- | :--- | :--- | :--- |
| **10:15 – 10:40** | **Working Hours (Session 1)** | `light.kitchen_hallway_light`<br>`light.lamp` / `light.patio_left_light` | Daytime transit: turns on Hallway & Lamp for **25 minutes**, then turns off. |
| **11:00 – 11:45** | **Background Music (Morning)** | `media_player.luis_s_echo` | Plays **Spotify Favorites** at volume `0.3` for **45 minutes** (automatically suppressed if TV turns on). |
| **11:45 – 12:20** | **Working Hours (Session 2)** | `light.dining_room_light` | Lunchtime activity: Dining room ceiling light turns on for **35 minutes**, then turns off. |
| **13:30 – 13:50** | **Working Hours (Session 3)** | `light.kitchen_hallway_light` | Midday transit: Kitchen hallway light turns on for **20 minutes**, then turns off. |
| **14:15 – 15:00** | **Background Music (Afternoon)** | `media_player.luis_s_echo` | Plays **Spotify Favorites** at volume `0.3` for **45 minutes** (suppressed if TV turns on). |
| **15:00 – 15:40** | **Working Hours (Session 4)** | `light.dining_room_light`<br>`light.lamp` / `light.patio_left_light` | Afternoon work session: Dining light & Lamp turn on for **40 minutes**, then turn off. |
| **16:30 – 16:55** | **Working Hours (Session 5)** | `light.kitchen_hallway_light` | Pre-evening transit: Kitchen hallway light turns on for **25 minutes**, then turns off. |
| **17:30:00** | **Work Hours Cleanup** | Dining light, Hallway light, Lamp | Sweep ensuring all daytime work lights are unconditionally turned off. |
| **18:15 – 19:15** | **Evening TV (Session 1)** | `remote.shield`<br>`media_player.living_room_samsung_oled`<br>`light.living_room_tv_backlight`<br>`light.lamp` | Wakes TV setup via SHIELD CEC (`remote.shield` HOME), tunes into Samsung TV Plus broadcast channel, turns on TV Backlight & Lamp. Changes channels at **+20m** (`media_next_track`) and **+45m** (`KEY_CHDOWN`), then powers off all TV hardware and lights at 19:15. |
| **20:00 – 21:15** | **Evening TV (Session 2)** | `remote.shield`<br>`media_player.living_room_samsung_oled`<br>`light.living_room_tv_backlight`<br>`light.lamp` | Evening movie/news session: Wakes via SHIELD CEC to Samsung TV Plus, TV Backlight & Lamp on. Changes channels at **+25m** (`media_next_track`) and **+55m** (`KEY_CHUP`), then powers off all TV hardware and lights at 21:15. |

### 6.3 Weekends (`sat, sun`)

| Time / Trigger | Routine / Phase | Target Entities | Simulated Behavior & Safeguards |
| :--- | :--- | :--- | :--- |
| **10:30 – 11:30** | **Weekend TV (Session 1)** | `remote.shield`<br>`media_player.living_room_samsung_oled` | Morning broadcast: Wakes via SHIELD CEC to Samsung TV Plus, changes channel at **+25m** (`media_next_track`), turns off at 11:30. |
| *11:30 – 13:30* | *Buffer (TV OFF)* | - | 2-hour quiet rest period. |
| **13:30 – 14:45** | **Weekend TV (Session 2)** | `remote.shield`<br>`media_player.living_room_samsung_oled` | Afternoon entertainment: Wakes via SHIELD CEC, changes channel at **+30m** (`media_next_track`) and **+55m** (`KEY_CHDOWN`), turns off at 14:45. |
| *14:45 – 17:15* | *Buffer (TV OFF)* | - | 2.5-hour quiet rest period. |
| **15:30 – 16:15** | **Weekend Background Music** | `media_player.luis_s_echo` | Plays Spotify acoustic hits on Echo at volume `0.3` for **45 minutes** (strictly conditional on TV being off; suppressed if TV is powered on). |
| **17:15 – 18:15** | **Weekend TV (Session 3)** | `remote.shield`<br>`media_player.living_room_samsung_oled` | Pre-dinner broadcast: Wakes via SHIELD CEC, changes channel at **+30m** (`media_next_track`), turns off at 18:15. |
| *18:15 – 20:00* | *Buffer (TV OFF / Dinner)* | - | 1h 45m quiet rest period. |
| **20:00 – 21:30** | **Weekend TV (Session 4)** | `remote.shield`<br>`media_player.living_room_samsung_oled`<br>`light.living_room_tv_backlight`<br>`light.lamp` | Prime-time leisure: TV Backlight & Lamp turn on, wakes via SHIELD CEC to Samsung TV Plus, changes channel at **+30m** and **+60m**, turns off cleanly at 21:30. |
