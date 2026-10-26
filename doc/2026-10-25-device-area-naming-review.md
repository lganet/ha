# Home Assistant Device, Area & Entity Naming Standardization

**Date**: 2026-10-25  
**Branch**: `feature/device-area-naming-standardization`  
**Device Proposal CSV**: [`doc/devices-inventory-and-proposals.csv`](file:///Users/gustavo/src/ha/doc/devices-inventory-and-proposals.csv)  
**All 1,587 Entities CSV**: [`doc/entities-inventory-and-proposals.csv`](file:///Users/gustavo/src/ha/doc/entities-inventory-and-proposals.csv)  
**Total Devices**: 152 | **Physical Smart Devices**: 105 | **Platform / Integrations**: 47

---

## 1. Principles & Accent / Voice-Recognition Guidelines

### A. Device Friendly Name: Omit the Area Prefix
* **Pattern**: `[Descriptor] [Device Type]` (e.g., `SHIELD TV`, `Desk LEDs`, `Ceiling Fan`, `Freezer Plug`, `Door Lock`).
* **Why**: The device is already assigned to an Area in Home Assistant and Google Home. Including the area causes visual stuttering in dashboards (e.g., `Living Room > Living Room SHIELD TV > Living Room SHIELD TV Media Player`) and confuses voice assistants (e.g., Google Home seeing `"Living Room Living Room SHIELD TV"`).
* Inside Google Home or HA Assist, rooms are contextual: saying *"Turn off the fan"* targets the fan in the current room, while saying *"Turn off the Office fan"* automatically pairs the Area with the Device.

### B. Entity IDs: Always Include the Area Prefix
* **Pattern**: `<domain>.<area>_<descriptor>` (lowercase, underscores).
* **Why**: In YAML automations, templates, and scripts, entity IDs live in a single global flat namespace. The area prefix guarantees clarity and eliminates ambiguity (e.g., `media_player.living_room_shield`, `light.office_desk_leds`, `switch.kitchen_freezer_plug`).

### C. Voice Accessibility & Accent Guidelines (Non-Native English Speakers)
Voice assistants frequently mishear non-native English accents, soft vowel transitions, and nasal or ambiguous monosyllabic words:
1. **Phonetic Simplicity**: Choose clear, distinct, universally recognizable English words:
   * Prefer **`Office`** over **`Den`** (avoids confusion with *Dan*, *them*, *then*, *ten*, or *bed*).
   * Prefer **`Main Bedroom`** over **`Primary Bedroom`** (avoids difficult consonant clusters `pr-` and unstressed syllables).
   * Prefer **`Guest Bedroom`** over ambiguous `Bedroom`.
2. **Area & Device Spoken Aliases**: Always configure spoken aliases on areas and devices to support accent variations, multilingual phrasing, and natural synonyms:
   * **`Patio`**: Aliases `["Balcony", "Deck", "Backyard", "Outside", "Terrace", "Pátio"]`.
   * **`Office`**: Aliases `["Den", "Study", "Workroom", "Escritorio"]`.
   * **`Main Bedroom`**: Aliases `["Master Bedroom", "Master", "Quarto Principal", "Suite"]`.

---

## 2. Standardized Areas & Recommended Aliases

| Standard Area | Current HA Area ID | Recommended Aliases (for Voice/Google Home) | Phonetic Rationale |
|---|---|---|---|
| **Office** | `den` | `Den`, `Study`, `Workroom`, `Escritorio` | "Office" is recognized with near 100% accuracy across all accents. |
| **Living Room** | `living_room` | `Living`, `Family Room`, `TV Room`, `Sala` | Common, clear vowels. |
| **Dining Room** | `dining` | `Dining`, `Dinner Table`, `Sala de Jantar` | Natural phrasing. |
| **Kitchen** | `kitchen` | `Cozinha` | Short, crisp consonants. |
| **Hallway** | `hallway` | `Hall`, `Corridor`, `Corredor` | Clean, distinct. |
| **Main Bedroom** | `main_bedroom` | `Master Bedroom`, `Master`, `Quarto Principal`, `Suite` | Simpler phonetics than "Primary Bedroom". |
| **Guest Bedroom** | `bedroom` | `Guest Room`, `Bedroom 2`, `Quarto de Hospedes` | Clarifies the second bedroom. |
| **Main Bathroom** | `main_bathroom` | `Master Bathroom`, `Master Bath`, `Banheiro Principal` | Matches Main Bedroom. |
| **Guest Bathroom** | `bathroom` | `Guest Bath`, `Hall Bathroom`, `Powder Room` | Clarifies the secondary bathroom. |
| **Patio** | `pstio` (typo in ID) | `Balcony`, `Deck`, `Backyard`, `Outside`, `Terrace` | Adding aliases solves accent misrecognition. |

---

## 3. Label Taxonomy

Each device or entity belongs to **one Area**, but can hold **multiple Labels**:

1. **Repository Provenance**:
   * `git_managed`: Applied to resources defined in this Git repo.
2. **Functional Automations**:
   * `all_off_exempt`: Critical devices that must never be turned off by "All Off" / "Goodnight" scripts (e.g., Freezers, HomeLab, NAS, 3D printer).
   * `den_controlled_lights`: Room lights toggled by presence or master scene switches.
   * `bedtime_off`: Ambient lights or accents turned off when house sleeps.
3. **Domain / Device Class (for rapid filtering)**:
   * `light`, `plug`, `switch`, `fan`, `climate`, `camera`, `media`, `sensor`.

---

## 4. Smart Devices & Primary Entity Proposals by Room

Below is the proposal for all physical smart devices. Notice that **Device Names** are clean and concise (no room prefix), while **Entity IDs** include the full area namespace for YAML/automation precision.

### Office (17 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Hub Display** | `Den display` | `media_player.office_hub_display` | `media_player.den_display` | cast | `media` |
| **Hub Display** | `Den display` | `media_player.office_hub_display` | `media_player.den_display_2` | music_assistant | `media` |
| **Presence Sensor FP300** | `FP300` | `binary_sensor.office_presence_fp300` | `switch.fp300_den_ai_interference_source_selfidentification` | zigbee2mqtt | `switch; den_controlled_lights` |
| **Wall Panel** | `NSPanel Pro` | `button.office_wall_panel_restart` | `switch.zigbee2cube_1002a32fc7_transmit_power` | mqtt | `switch; den_controlled_lights` |
| **PC Plug** | `Den PC plug` | `switch.office_pc_plug` | `switch.den_pc_plug` | zigbee2mqtt | `plug; den_controlled_lights` |
| **Desk LEDs** | `Office Leds` | `light.office_desk_leds` | `light.office_leds` | govee | `light; switch; den_controlled_lights` |
| **Floor Lamp** | `Floor Lamp` | `light.office_floor_lamp` | `light.floor_lamp` | govee | `light; switch; den_controlled_lights` |
| **Floor Lamp Corner** | `Den Floor Lamp` | `light.office_floor_lamp_corner` | `light.den_floor_lamp` | govee | `light; switch; den_controlled_lights` |
| **Humidifier** | `Humidifier` | `humidifier.office_humidifier` | `light.humidifier_night_light` | govee | `light; climate; den_controlled_lights` |
| **Zigbee Coordinator** | `SLZB-MR4U` | `binary_sensor.office_zigbee_coordinator_ethernet` | `switch.slzb_mr4u_disable_leds` | unknown | `switch; den_controlled_lights` |
| **Ceiling Fan Light Switch** | `Den Fan Light` | `switch.office_fan_light` | `switch.den_fan_light` | zigbee2mqtt | `switch; fan; den_controlled_lights` |
| **Hub Display** | `Den display` | `media_player.office_hub_display` | `media_player.nesthubfa85_2` | music_assistant | `media` |
| **Hub Display** | `Den display` | `media_player.office_hub_display` | `media_player.nesthubfa85_4` | music_assistant | `media` |
| **HomeLab Plug** | `HomeLab Plug` | `switch.office_homelab_plug` | `switch.homelab_plug` | zigbee2mqtt | `plug; all_off_exempt; den_controlled_lights` |
| **Air Purifier** | `Air purifier` | `fan.office_air_purifier` | `fan.air_purifier_2` | tuya_local | `fan; climate` |
| **Ceiling Fan** | `Fan` | `fan.office_ceiling_fan` | `light.smart_fan_3` | tuya_local | `light; switch; fan; den_controlled_lights` |
| **NSPanel Screen** | `nspanel den` | `device_tracker.den_panel` | `device_tracker.den_panel` | mobile_app | `mobile` |

### Living Room (22 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **SHIELD TV** | `SHIELD` | `media_player.living_room_shield` | `media_player.shield` | cast | `media` |
| **Stereo Speakers** | `Stereo` | `media_player.living_room_stereo` | `media_player.stereo` | cast | `media` |
| **Table Lamp** | `Living Room Lamp` | `light.living_room_lamp` | `light.living_room_lamp` | tplink | `light; switch` |
| **TV** | `Samsung OLED` | `media_player.living_room_tv` | `media_player.samsung_oled_2` | samsungtv | `media` |
| **TV** | `Samsung OLED` | `media_player.living_room_tv` | `media_player.samsung_oled` | unknown | `media` |
| **SHIELD TV** | `SHIELD` | `media_player.living_room_shield_tv` | `media_player.shield_2` | androidtv_remote | `media` |
| **SHIELD TV** | `SHIELD` | `media_player.living_room_shield` | `media_player.shield_3` | cast | `media` |
| **Air Quality** | `Air Quality` | `binary_sensor.living_room_air_quality` | `binary_sensor.air_quality_connectivity` | alexa_devices | `sensor` |
| **Luis's Echo** | `Luis's Echo` | `media_player.living_room_luis_s_echo` | `media_player.luis_s_echo` | alexa_devices | `switch; media` |
| **SHIELD TV** | `SHIELD` | `media_player.living_room_shield_tv` | `media_player.shield_4` | music_assistant | `media` |
| **TV** | `Samsung OLED` | `media_player.living_room_tv` | `media_player.samsung_oled_4` | music_assistant | `media` |
| **Stereo Speakers** | `Stereo` | `media_player.living_room_stereo` | `media_player.stereo_2` | music_assistant | `media` |
| **TV** | `Samsung OLED` | `media_player.living_room_tv` | `media_player.living_room_samsung_oled_2` | smartthings | `media` |
| **Secondary TV** | `Samsung CU7700 43` | `media_player.living_room_secondary_tv` | `media_player.living_room_samsung_cu7700_43` | smartthings | `media` |
| **Presence Sensor FP2** | `Presence-Sensor-FP2-9698` | `binary_sensor.living_room_presence_fp2` | `binary_sensor.presence_sensor_fp2_9698_presence_sensor_1` | homekit_controller:accessory-id | `sensor` |
| **Air Purifier Plug** | `Air Purifier plug` | `switch.living_room_air_purifier_plug` | `switch.air_purifier_plug` | zigbee2mqtt | `plug; climate` |
| **LEDs Plug** | `Leds plug` | `switch.living_room_leds_plug` | `switch.leds_plug` | zigbee2mqtt | `plug` |
| **TV Console Plug** | `TV Gaming plug` | `switch.living_room_tv_console_plug` | `switch.tv_gaming_plug` | zigbee2mqtt | `plug` |
| **TV Backlight** | `TV Backlight` | `light.living_room_tv_backlight` | `light.tv_backlight` | govee | `light; switch` |
| **Floor Lamp Right** | `Floor Lamp TV right` | `light.living_room_floor_lamp_right` | `light.floor_lamp_tv_right` | govee | `light; switch` |
| **Floor Lamp Left** | `Floor Lamp TV left` | `light.living_room_floor_lamp_left` | `light.floor_lamp_tv_left` | govee | `light; switch` |
| **360 Camera** | `360 Camera` | `camera.living_room_camera` | `switch.living_room_baby_cry_detection` | tplink | `switch; camera` |

### Dining Room (3 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Speaker** | `Dining room speaker` | `media_player.dining_room_speaker` | `media_player.dining_room_speaker` | cast | `media` |
| **Ceiling Light** | `Dining` | `light.dining_room_light` | `light.dining` | tplink | `light; switch` |
| **Speaker** | `Dining room speaker` | `media_player.dining_room_speaker` | `media_player.dining_room_speaker_2` | music_assistant | `media` |

### Kitchen (16 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Hub Display** | `Kitchen display` | `media_player.kitchen_hub_display` | `media_player.kitchen_display` | cast | `media` |
| **X55** | `X55` | `binary_sensor.kitchen_x55` | `binary_sensor.x55_wan_status` | upnp_serial_number | `sensor` |
| **Speaker** | `Kitchen speaker` | `media_player.kitchen_speaker` | `media_player.kitchen_speaker` | cast | `media` |
| **GusHomeBase** | `GusHomeBase` | `binary_sensor.kitchen_gushomebase` | `binary_sensor.gushomebase_alarm` | eufy_security | `sensor` |
| **Hub Display** | `Kitchen display` | `media_player.kitchen_hub_display` | `media_player.kitchen_display_2` | music_assistant | `media` |
| **Door Sensor** | `Door Sensor` | `binary_sensor.kitchen_door_sensor` | `binary_sensor.door_sensor_door` | yolink | `sensor` |
| **Temperature Sensor** | `Temperature Sensor` | `sensor.kitchen_temperature_sensor` | `sensor.temperature_sensor_battery` | yolink | `sensor` |
| **leds** | `kitchen leds` | `light.kitchen_leds` | `light.kitchen_leds` | tplink | `light; switch` |
| **Refrigerator** | `Refrigerator` | `switch.kitchen_refrigerator` | `switch.kitchen_refrigerator_cubed_ice` | smartthings | `switch` |
| **Oven** | `Oven` | `light.kitchen_oven` | `light.kitchen_range_light` | smartthings | `light` |
| **Botao Ikea 1** | `Botao Ikea 1` | `sensor.kitchen_botao_ikea_1` | `sensor.botao_ikea_1_battery` | zigbee2mqtt | `sensor` |
| **Roborock Dyad Pro Combo** | `Roborock Dyad Pro Combo` | `sensor.kitchen_roborock_dyad_pro_combo` | `sensor.roborock_dyad_pro_combo_status` | roborock | `sensor` |
| **Lights** | `Kitchen Lights` | `light.kitchen_lights` | `light.kitchen_lights` | tplink | `light; switch` |
| **Hallway Light** | `Kitchen Hallway Lights` | `light.kitchen_hallway_light` | `light.kitchen_hallway_lights` | tplink | `light; switch` |
| **IR Remote** | `IR Remoto` | `switch.kitchen_ir_remote` | `fan.kitchen_ir_remoto_switch2` | zigbee2mqtt | `switch; fan` |
| **Freezer Plug** | `Freezer Plug` | `switch.kitchen_freezer_plug` | `switch.freezer_plug` | zigbee2mqtt | `plug; all_off_exempt` |

### Hallway (1 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Night Light** | `Hallway Night Light` | `light.hallway_night_light` | `light.hallway_night_light` | zigbee2mqtt | `light` |

### Main Bedroom (7 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Ceiling Light 2** | `Main Bedroom Two` | `light.main_bedroom_light_2` | `light.main_bedroom_two` | tplink | `light; switch` |
| **Closet Light** | `Main Bedroom Closet Light` | `light.main_bedroom_closet_light` | `light.main_bedroom_closet_light` | tplink | `light; switch` |
| **Ceiling Light 1** | `Main Bedroom One` | `light.main_bedroom_light_1` | `light.main_bedroom_one` | tplink | `light; switch` |
| **Motion Sensor** | `Main Bedroom Sensor` | `binary_sensor.main_bedroom_motion` | `binary_sensor.presence_4` | deconz | `sensor` |
| **Luis's Echo Spot** | `Luis's Echo Spot` | `media_player.main_bedroom_luis_s_echo_spot` | `media_player.luis_s_echo_spot` | alexa_devices | `switch; media` |
| **Wall Panel** | `NSPanel Pro` | `button.main_bedroom_wall_panel_restart` | `switch.zigbee2cube_1002c15147_transmit_power` | mqtt | `switch` |
| **Ceiling Fan** | `Fan` | `fan.main_bedroom_ceiling_fan` | `light.smart_fan_4` | tuya_local | `light; switch; fan` |

### Guest Bedroom (5 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Ceiling Light** | `Guest Room Light` | `light.guest_bedroom_light` | `light.bedroom_light` | tplink | `light; switch` |
| **Motion Sensor** | `Guest Sensor` | `binary_sensor.guest_bedroom_motion` | `binary_sensor.presence_2` | deconz | `sensor` |
| **Speaker** | `Guest Room speaker` | `media_player.guest_bedroom_speaker` | `media_player.googlehome5153` | cast | `media` |
| **Luis's Fire TV** | `Luis's Fire TV` | `switch.guest_bedroom_luis_s_fire_tv` | `switch.luis_s_fire_tv_do_not_disturb` | alexa_devices | `switch` |
| **Bedside Plug** | `Bedroom bed plug` | `switch.guest_bedroom_bed_plug` | `switch.bedroom_bed_plug` | zigbee2mqtt | `plug` |

### Main Bathroom (6 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Vanity Light** | `Main Bathroom Lights` | `light.main_bathroom_vanity_light` | `light.main_bathroom_lights` | tplink | `light; switch` |
| **Shower Light** | `Main Bathroom Light Shower` | `light.main_bathroom_shower_light` | `light.main_bathroom_light_shower` | tplink | `light; switch` |
| **Speaker** | `Master Bathroom speaker` | `media_player.main_bathroom_speaker` | `media_player.googlehome6735` | cast | `media` |
| **Exhaust Fan** | `Main Bathroom Fan` | `switch.main_bathroom_fan` | `switch.main_bathroom_fan` | zigbee2mqtt | `switch; fan` |
| **Display** | `Master Bathroom display` | `media_player.main_bathroom_speaker` | `media_player.nesthubfa85_5` | cast | `media` |
| **Display** | `Master Bathroom display` | `media_player.main_bathroom_speaker` | `media_player.nesthubfa85_6` | music_assistant | `media` |

### Guest Bathroom (2 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Bathtub Light** | `Bathroom Bathtub Light` | `light.guest_bathroom_bathtub_light` | `light.bathroom_bathtub_light` | tplink | `light; switch` |
| **Vanity Light** | `Bathroom Lights` | `light.guest_bathroom_vanity_light` | `light.bathroom_lights` | tplink | `light; switch` |

### Patio (11 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Right Light** | `Patio Right Light` | `switch.patio_right_light` | `switch.patio_right_light` | tplink | `switch` |
| **Left Light** | `Patio Left Light` | `light.patio_left_light` | `light.patio_left_light` | tplink | `light; switch` |
| **Door Lock** | `Lock` | `lock.patio_door_lock` | `lock.lock_lock` | matter | `sensor` |
| **Door Lock Cloud** | `Patio Lock` | `lock.patio_door_lock_cloud` | `` | switchbot_cloud | `` |
| **Right Camera** | `Patio Right` | `camera.patio_right_camera` | `camera.patio_right` | eufy_security | `switch; camera` |
| **Left Camera** | `Patio Left` | `camera.patio_left_camera` | `camera.patio_left` | eufy_security | `switch; camera` |
| **Fence Sensor** | `Fence Sensor` | `binary_sensor.patio_fence_sensor` | `binary_sensor.fence_sensor_door` | yolink | `sensor` |
| **Motion Sensor Right** | `Motion Sensor Right` | `binary_sensor.patio_motion_sensor_right` | `binary_sensor.motion_sensor_right_motion` | yolink | `sensor` |
| **Door Lock Cloud** | `Patio Lock` | `lock.patio_door_lock_cloud` | `lock.patio_lock` | switchbot_cloud | `sensor` |
| **Left Light** | `Light patio left` | `switch.patio_left_light` | `switch.light_patio_left` | zigbee2mqtt | `switch` |
| **Right Plug** | `Plug Patio Right` | `switch.patio_right_plug` | `lock.plug_patio_right_child_lock` | tuya_local | `plug` |

### Unassigned (19 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Speaker Group Nova** | `Nova` | `media_player.speaker_group_nova` | `media_player.nova` | cast | `media` |
| **SwitchBot Hub Mini** | `SwitchBot Hub Mini` | `sensor.unassigned_switchbot_hub_mini` | `sensor.switchbot_hub_mini_wi_fi_rssi` | matter | `sensor` |
| **** | `[Empty Name]` | `` | `` | unknown | `` |
| **Phoscon-GW** | `Phoscon-GW` | `` | `` | deconz | `` |
| **Daylight** | `Daylight` | `sensor.unassigned_daylight` | `sensor.daylight` | deconz | `sensor` |
| **** | `[Empty Name]` | `` | `` | unknown | `` |
| **** | `[Empty Name]` | `` | `` | unknown | `` |
| **Speaker Group Everywhere** | `Everywhere` | `media_player.speaker_group_everywhere` | `media_player.everywhere` | alexa_devices | `media` |
| **lganet@gmail.com** | `lganet@gmail.com` | `button.unassigned_lganet_gmail_com` | `button.lganet_gmail_com_good_morning_lights_on` | alexa_devices | `` |
| **Luis’s MacBook Air** | `Luis’s MacBook Air` | `media_player.unassigned_luis_s_macbook_air` | `media_player.luiss_macbook_air` | music_assistant | `media` |
| **Speaker Group Nova** | `Nova` | `media_player.speaker_group_nova` | `media_player.nova_2` | music_assistant | `media` |
| **Vibration Sensor** | `Vibration Sensor` | `binary_sensor.unassigned_vibration_sensor` | `binary_sensor.vibration_sensor_vibration` | yolink | `sensor` |
| **Samsung QN90AA 55 TV BR** | `Samsung QN90AA 55 TV BR` | `media_player.unassigned_samsung_qn90aa_55_tv_br` | `media_player.samsung_qn90aa_55_tv_br` | music_assistant | `media` |
| **Window Sensor** | `Window Sensor` | `binary_sensor.unassigned_window_sensor` | `binary_sensor.window_sensor_door` | yolink | `sensor` |
| **Zigbee2MQTT Bridge** | `Zigbee2MQTT Bridge` | `switch.unassigned_zigbee2mqtt_bridge` | `switch.zigbee2mqtt_bridge_permit_join` | zigbee2mqtt | `switch` |
| **Govee Integration** | `Govee Integration` | `sensor.unassigned_govee_integration` | `sensor.govee_integration_api_rate_limit_remaining` | govee | `sensor` |
| **NestHubFA85** | `NestHubFA85` | `media_player.unassigned_nesthubfa85` | `media_player.nesthubfa85` | cast | `media` |
| **NestHubFA85** | `NestHubFA85` | `media_player.unassigned_nesthubfa85` | `media_player.nesthubfa85_3` | cast | `media` |
| **Smart Plug 1** | `Smartplug Tuya 1` | `switch.unassigned_smart_plug_1` | `switch.smartplug_tuya_1` | tuya_local | `plug` |

### System / Server (38 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Sun** | `Sun` | `sensor.sun_next_dawn` | `sensor.sun_next_dawn` | sun | `system` |
| **Home Assistant Core** | `Home Assistant Core` | `sensor.home_assistant_core_cpu_percent` | `sensor.home_assistant_core_cpu_percent` | hassio | `system` |
| **Home Assistant Supervisor** | `Home Assistant Supervisor` | `sensor.home_assistant_supervisor_cpu_percent` | `sensor.home_assistant_supervisor_cpu_percent` | hassio | `system` |
| **Home Assistant Host** | `Home Assistant Host` | `sensor.home_assistant_host_os_agent_version` | `sensor.home_assistant_host_os_agent_version` | hassio | `system` |
| **Home Assistant Operating System** | `Home Assistant Operating System` | `sensor.home_assistant_operating_system_version` | `sensor.home_assistant_operating_system_version` | hassio | `system` |
| **Matter Server** | `Matter Server` | `binary_sensor.matter_server_running` | `binary_sensor.matter_server_running` | hassio | `system` |
| **Forecast** | `Forecast` | `weather.forecast_home` | `weather.forecast_home` | met | `system` |
| **Advanced SSH & Web Terminal** | `Advanced SSH & Web Terminal` | `binary_sensor.advanced_ssh_web_terminal_running` | `binary_sensor.advanced_ssh_web_terminal_running` | hassio | `system` |
| **GusNAS** | `GusNAS` | `binary_sensor.gusnas_security_status` | `binary_sensor.gusnas_security_status` | synology_dsm | `system` |
| **GusNAS (Drive 1)** | `GusNAS (Drive 1)` | `binary_sensor.gusnas_drive_1_exceeded_max_bad_sectors` | `binary_sensor.gusnas_drive_1_exceeded_max_bad_sectors` | synology_dsm | `system` |
| **GusNAS (Drive 2)** | `GusNAS (Drive 2)` | `binary_sensor.gusnas_drive_2_exceeded_max_bad_sectors` | `binary_sensor.gusnas_drive_2_exceeded_max_bad_sectors` | synology_dsm | `system` |
| **GusNAS (Volume 1)** | `GusNAS (Volume 1)` | `sensor.gusnas_volume_1_status` | `sensor.gusnas_volume_1_status` | synology_dsm | `system` |
| **Studio Code Server** | `Studio Code Server` | `binary_sensor.studio_code_server_running` | `binary_sensor.studio_code_server_running` | hassio | `system` |
| **Get HACS** | `Get HACS` | `binary_sensor.get_hacs_running` | `binary_sensor.get_hacs_running` | hassio | `system` |
| **HACS** | `HACS` | `update.hacs_update` | `update.hacs_update` | hacs | `system` |
| **Node-RED** | `Node-RED` | `binary_sensor.node_red_running` | `binary_sensor.node_red_running` | hassio | `system` |
| **deCONZ** | `deCONZ` | `binary_sensor.deconz_running` | `binary_sensor.deconz_running` | hassio | `system` |
| **LivingRoom** | `LivingRoom` | `camera.livingroom` | `camera.livingroom` | synology_dsm | `system` |
| **GusNAS Surveillance Station** | `GusNAS Surveillance Station` | `switch.gusnas_surveillance_station_home_mode` | `switch.gusnas_surveillance_station_home_mode` | synology_dsm | `system` |
| **Google Translate en com** | `Google Translate en com` | `tts.google_translate_en_com` | `tts.google_translate_en_com` | google_translate | `system` |
| **Backup** | `Backup` | `event.backup_automatic_backup` | `event.backup_automatic_backup` | backup | `system` |
| **Google AI Task** | `Google AI Task` | `ai_task.google_ai_task` | `ai_task.google_ai_task` | google_generative_ai_conversation | `system` |
| **Google AI Conversation** | `Google AI Conversation` | `conversation.google_ai_conversation` | `conversation.google_ai_conversation` | google_generative_ai_conversation | `system` |
| **Google AI STT** | `Google AI STT` | `stt.google_ai_stt` | `stt.google_ai_stt` | google_generative_ai_conversation | `system` |
| **Google AI TTS** | `Google AI TTS` | `tts.google_ai_tts` | `tts.google_ai_tts` | google_generative_ai_conversation | `system` |
| **eufy-security-ws** | `eufy-security-ws` | `binary_sensor.eufy_security_ws_running` | `binary_sensor.eufy_security_ws_running` | hassio | `system` |
| **OpenCode** | `OpenCode` | `binary_sensor.opencode_running` | `binary_sensor.opencode_running` | hassio | `system` |
| **Music Assistant** | `Music Assistant` | `binary_sensor.music_assistant_running` | `binary_sensor.music_assistant_running` | hassio | `system` |
| **HA-MCP Custom Component** | `HA-MCP Custom Component` | `update.ha_mcp_custom_component_update` | `update.ha_mcp_custom_component_update` | hacs | `system` |
| **HA-MCP Server** | `HA-MCP Server` | `update.ha_mcp_server_update` | `update.ha_mcp_server_update` | ha_mcp_tools | `system` |
| **WebRTC Camera** | `WebRTC Camera` | `update.webrtc_camera_update` | `update.webrtc_camera_update` | hacs | `system` |
| **button-card** | `button-card` | `update.button_card_update` | `update.button_card_update` | hacs | `system` |
| **iOS Dark Mode Theme** | `iOS Dark Mode Theme` | `update.ios_dark_mode_theme_update` | `update.ios_dark_mode_theme_update` | hacs | `system` |
| **Zigbee2MQTT** | `Zigbee2MQTT` | `binary_sensor.zigbee2mqtt_running` | `binary_sensor.zigbee2mqtt_running` | hassio | `system` |
| **Mosquitto broker** | `Mosquitto broker` | `binary_sensor.mosquitto_broker_running` | `binary_sensor.mosquitto_broker_running` | hassio | `system` |
| **Tuya Local** | `Tuya Local` | `update.tuya_local_update` | `update.tuya_local_update` | hacs | `system` |
| **Stack In Card** | `Stack In Card` | `update.stack_in_card_update` | `update.stack_in_card_update` | hacs | `system` |
| **Govee Cloud Integration** | `Govee Cloud Integration` | `update.govee_cloud_integration_update` | `update.govee_cloud_integration_update` | hacs | `system` |

### On The Go (5 devices)

| Proposed Device Name | Current Device Name | Proposed Primary Entity ID | Current Primary Entity ID | Integration | Labels |
|---|---|---|---|---|---|
| **Samsung Galaxy Phone** | `SM-S928W` | `device_tracker.sm_s928w` | `device_tracker.sm_s928w` | mobile_app | `mobile` |
| **Livia Phone** | `Livia` | `device_tracker.iphone` | `device_tracker.iphone` | mobile_app | `mobile` |
| **motorcycle tag** | `motorcycle tag` | `` | `` | smartthings | `` |
| **SmartTag+ Car Key** | `SmartTag+ Car Key` | `` | `` | smartthings | `` |
| **Gustavo Phone** | `Fold 8` | `device_tracker.fold_8` | `device_tracker.fold_8` | mobile_app | `mobile` |

---

## 5. Next Steps & Execution Workflow

1. **Review Together**:
   * Review the clean device names and entity IDs above or in [`doc/devices-inventory-and-proposals.csv`](file:///Users/gustavo/src/ha/doc/devices-inventory-and-proposals.csv).
   * Note any adjustments or overrides you want.
2. **Execute via Home Assistant MCP**:
   * Update Area definitions and spoken aliases (`ha_set_area_or_floor`).
   * Update device friendly names and assigned areas (`ha_set_device`).
   * Rename entity IDs (`ha_set_entity(entity_id=..., new_entity_id=...)`).
3. **Repository Refactor & Validation**:
   * Batch-update referenced entity IDs in the 10 automations, 3 scripts, and NSPanel dashboard in this repository.
   * Validate configuration and test automations.
   * Review the Git diff and finalize the branch.
