# Home Assistant Device & Area Naming Standardization Proposal

**Date**: 2026-10-25  
**Branch**: `feature/device-area-naming-standardization`  
**CSV Data**: [`doc/devices-inventory-and-proposals.csv`](file:///Users/gustavo/src/ha/doc/devices-inventory-and-proposals.csv)  
**Total Devices**: 152 (105 Physical Smart Devices, 47 System / Platform Integrations)

---

## 1. Principles & Accent / Voice-Recognition Guidelines

When voice assistants (Google Assistant, Alexa, Home Assistant Assist) process spoken commands from non-native English speakers:
1. **Phonetic Simplicity**: Short, distinct, universally recognizable words are favored over nuanced or regional English terms:
   * **`Office` vs. `Den`**: "Den" is easily confused with *Dan*, *them*, *then*, *ten*, or *bed*. "Office" has crisp consonants and is recognized with very high accuracy.
   * **`Main Bedroom` vs. `Primary Bedroom`**: "Primary" contains complex consonant clusters (`pr-`) and unstressed syllables often mangled by voice models. "Main" is clear and direct.
   * **`Guest Bedroom` vs. `Bedroom`**: Clear, unambiguous distinction between the two rooms.
   * **`Patio`**: Standard and intuitive. To solve voice assistant accent issues, we leverage **Area Aliases**!
2. **Area & Device Aliases (The Accent Solution)**:
   Home Assistant allows assigning multiple spoken **aliases** to both Areas and Devices. When synced to Google Home or Assist, Google matches *any* of the aliases.
   * *Example*: Area `Patio` can have aliases: `Balcony`, `Deck`, `Backyard`, `Outside`, `Terrace`, `Pátio`. If Google struggles with "Patio", saying "Balcony lights" or "Deck lights" will trigger the same room effortlessly.
3. **Consistent Device Pattern**:
   $$\mathbf{[Area]\ [Descriptor]\ [Device\ Type]}$$
   * *Example*: `Living Room Lamp`, `Office Floor Lamp`, `Patio Right Light`, `Main Bedroom Fan`.
   * Clear in device lists, voice prompts, and notification messages.

---

## 2. Standardized Areas & Recommended Aliases

| Standard Area | Current HA Area ID | Recommended Aliases (for Voice/Google Home) | Phonetic Rationale |
|---|---|---|---|
| **Office** (or **Den**) | `den` | `Den`, `Study`, `Workroom`, `Escritorio` | "Office" is recognized with near 100% accuracy across all accents. |
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

## 4. Smart Devices Review by Area

Below is the proposal for all physical smart devices, categorized by room.

### Office (16 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Den display` | **Office Hub Display** | `Unassigned` | cast | `media` |  |
| `Den display` | **Office Hub Display** | `Unassigned` | music_assistant | `media` | Music Assistant media player |
| `FP300` | **Office FP300** | `den` | zigbee2mqtt | `switch; den_controlled_lights` |  |
| `NSPanel Pro` | **Office Wall Panel** | `den` | mqtt | `switch; den_controlled_lights` |  |
| `Den PC plug` | **Office PC Plug** | `den` | zigbee2mqtt | `plug; den_controlled_lights` |  |
| `Office Leds` | **Office Desk LEDs** | `den` | govee | `light; switch; den_controlled_lights` |  |
| `Floor Lamp` | **Office Floor Lamp** | `den` | govee | `light; switch; den_controlled_lights` |  |
| `Den Floor Lamp` | **Office Floor Lamp** | `den` | govee | `light; switch; den_controlled_lights` |  |
| `Humidifier` | **Office Humidifier** | `den` | govee | `light; climate; den_controlled_lights` |  |
| `SLZB-MR4U` | **Office Zigbee Coordinator** | `den` | unknown | `switch; den_controlled_lights` |  |
| `Den Fan Light` | **Office Ceiling Fan Light** | `Unassigned` | zigbee2mqtt | `switch; fan; den_controlled_lights` |  |
| `Den display` | **Office Hub Display** | `Unassigned` | music_assistant | `media` | Music Assistant media player |
| `Den display` | **Office Hub Display** | `Unassigned` | music_assistant | `media` | Music Assistant media player |
| `HomeLab Plug` | **Office HomeLab Plug** | `den` | zigbee2mqtt | `plug; all_off_exempt; den_controlled_lights` |  |
| `Air purifier` | **Office Air Purifier** | `den` | tuya_local | `fan; climate` |  |
| `Fan` | **Office Ceiling Fan** | `den` | tuya_local | `light; switch; fan; den_controlled_lights` |  |

### Living Room (16 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Living Room Lamp` | **Living Room Lamp** | `living_room` | tplink | `light; switch` |  |
| `Samsung OLED` | **Living Room TV** | `living_room` | samsungtv | `media` |  |
| `Samsung OLED` | **Living Room TV** | `living_room` | unknown | `media` | Duplicate / SmartThings mirror device |
| `SHIELD` | **Living Room SHIELD TV** | `living_room` | androidtv_remote | `media` | Android TV Remote control device |
| `Air Quality` | **Living Room Air Quality** | `living_room` | alexa_devices | `sensor` |  |
| `Luis's Echo` | **Living Room Luis's Echo** | `living_room` | alexa_devices | `switch; media` |  |
| `Samsung OLED` | **Living Room TV** | `living_room` | smartthings | `media` |  |
| `Samsung CU7700 43` | **Living Room Samsung CU7700 43** | `living_room` | smartthings | `media` |  |
| `Presence-Sensor-FP2-9698` | **Living Room Presence Sensor** | `living_room` | homekit_controller:accessory-id | `sensor` |  |
| `Air Purifier plug` | **Living Room Air Purifier Plug** | `living_room` | zigbee2mqtt | `plug; climate` |  |
| `Leds plug` | **Living Room LEDs Plug** | `living_room` | zigbee2mqtt | `plug` |  |
| `TV Gaming plug` | **Living Room TV Console Plug** | `living_room` | zigbee2mqtt | `plug` |  |
| `TV Backlight` | **Living Room TV Backlight** | `living_room` | govee | `light; switch` |  |
| `Floor Lamp TV right` | **Living Room Floor Lamp Right** | `living_room` | govee | `light; switch` |  |
| `Floor Lamp TV left` | **Living Room Floor Lamp Left** | `living_room` | govee | `light; switch` |  |
| `360 Camera` | **Living Room Camera** | `living_room` | tplink | `switch; camera` |  |

### Dining Room (3 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Dining room speaker` | **Dining Room Speaker** | `Unassigned` | cast | `media` |  |
| `Dining` | **Dining Room Light** | `dining` | tplink | `light; switch` |  |
| `Dining room speaker` | **Dining Room Speaker** | `Unassigned` | music_assistant | `media` |  |

### Kitchen (16 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Kitchen display` | **Kitchen Hub Display** | `Unassigned` | cast | `media` |  |
| `X55` | **Kitchen X55** | `kitchen` | upnp_serial_number | `sensor` |  |
| `Kitchen speaker` | **Kitchen Speaker** | `Unassigned` | cast | `media` |  |
| `GusHomeBase` | **Kitchen GusHomeBase** | `kitchen` | eufy_security | `sensor` |  |
| `Kitchen display` | **Kitchen Hub Display** | `Unassigned` | music_assistant | `media` |  |
| `Door Sensor` | **Kitchen Door Sensor** | `kitchen` | yolink | `sensor` |  |
| `Temperature Sensor` | **Kitchen Temperature Sensor** | `kitchen` | yolink | `sensor` |  |
| `kitchen leds` | **kitchen leds** | `kitchen` | tplink | `light; switch` |  |
| `Refrigerator` | **Kitchen Refrigerator** | `kitchen` | smartthings | `switch` |  |
| `Oven` | **Kitchen Oven** | `kitchen` | smartthings | `light` |  |
| `Botao Ikea 1` | **Kitchen Botao Ikea 1** | `kitchen` | zigbee2mqtt | `sensor` |  |
| `Roborock Dyad Pro Combo` | **Kitchen Roborock Dyad Pro Combo** | `kitchen` | roborock | `sensor` |  |
| `Kitchen Lights` | **Kitchen Lights** | `kitchen` | tplink | `light; switch` |  |
| `Kitchen Hallway Lights` | **Kitchen Hallway Light** | `Unassigned` | tplink | `light; switch` |  |
| `IR Remoto` | **Kitchen IR Remote** | `kitchen` | zigbee2mqtt | `switch; fan` |  |
| `Freezer Plug` | **Kitchen Freezer Plug** | `Unassigned` | zigbee2mqtt | `plug; all_off_exempt` |  |

### Hallway (1 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Hallway Night Light` | **Hallway Night Light** | `Unassigned` | zigbee2mqtt | `light` |  |

### Main Bedroom (7 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Main Bedroom Two` | **Main Bedroom Light 2** | `main_bedroom` | tplink | `light; switch` |  |
| `Main Bedroom Closet Light` | **Main Bedroom Closet Light** | `main_bedroom` | tplink | `light; switch` |  |
| `Main Bedroom One` | **Main Bedroom Light 1** | `main_bedroom` | tplink | `light; switch` |  |
| `Main Bedroom Sensor` | **Main Bedroom Motion Sensor** | `Unassigned` | deconz | `sensor` |  |
| `Luis's Echo Spot` | **Main Bedroom Luis's Echo Spot** | `main_bedroom` | alexa_devices | `switch; media` |  |
| `NSPanel Pro` | **Main Bedroom Wall Panel** | `main_bedroom` | mqtt | `switch` |  |
| `Fan` | **Main Bedroom Ceiling Fan** | `main_bedroom` | tuya_local | `light; switch; fan` |  |

### Guest Bedroom (5 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Guest Room Light` | **Guest Bedroom Light** | `bedroom` | tplink | `light; switch` |  |
| `Guest Sensor` | **Guest Bedroom Motion Sensor** | `bedroom` | deconz | `sensor` |  |
| `Guest Room speaker` | **Guest Bedroom Speaker** | `Unassigned` | cast | `media` |  |
| `Luis's Fire TV` | **Guest Bedroom Luis's Fire TV** | `bedroom` | alexa_devices | `switch` |  |
| `Bedroom bed plug` | **Guest Bedroom Bedside Plug** | `Unassigned` | zigbee2mqtt | `plug` |  |

### Main Bathroom (6 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Main Bathroom Lights` | **Main Bathroom Vanity Light** | `main_bathroom` | tplink | `light; switch` |  |
| `Main Bathroom Light Shower` | **Main Bathroom Shower Light** | `main_bathroom` | tplink | `light; switch` |  |
| `Master Bathroom speaker` | **Main Bathroom Speaker** | `Unassigned` | cast | `media` |  |
| `Main Bathroom Fan` | **Main Bathroom Exhaust Fan** | `Unassigned` | zigbee2mqtt | `switch; fan` |  |
| `Master Bathroom display` | **Main Bathroom Speaker** | `Unassigned` | cast | `media` |  |
| `Master Bathroom display` | **Main Bathroom Speaker** | `Unassigned` | music_assistant | `media` |  |

### Guest Bathroom (2 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Bathroom Bathtub Light` | **Guest Bathroom Bathtub Light** | `bathroom` | tplink | `light; switch` |  |
| `Bathroom Lights` | **Guest Bathroom Vanity Light** | `bathroom` | tplink | `light; switch` |  |

### Patio (11 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Patio Right Light` | **Patio Right Light** | `pstio` | tplink | `switch` |  |
| `Patio Left Light` | **Patio Left Light** | `pstio` | tplink | `light; switch` |  |
| `Lock` | **Patio Door Lock** | `pstio` | matter | `sensor` |  |
| `Patio Lock` | **Patio Door Lock (Cloud)** | `Unassigned` | switchbot_cloud | `` |  |
| `Patio Right` | **Patio Right Camera** | `pstio` | eufy_security | `switch; camera` |  |
| `Patio Left` | **Patio Left Camera** | `pstio` | eufy_security | `switch; camera` |  |
| `Fence Sensor` | **Patio Fence Sensor** | `pstio` | yolink | `sensor` |  |
| `Motion Sensor Right` | **Patio Motion Sensor Right** | `pstio` | yolink | `sensor` |  |
| `Patio Lock` | **Patio Door Lock (Cloud)** | `Unassigned` | switchbot_cloud | `sensor` |  |
| `Light patio left` | **Patio Left Light** | `Unassigned` | zigbee2mqtt | `switch` |  |
| `Plug Patio Right` | **Patio Right Plug** | `pstio` | tuya_local | `plug` |  |

### Unassigned (25 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `SHIELD` | **Unassigned SHIELD TV** | `Unassigned` | cast | `media` | Cast media player target |
| `Stereo` | **Unassigned Stereo Speakers** | `Unassigned` | cast | `media` |  |
| `Nova` | **Unassigned Nova Speaker Group** | `Unassigned` | cast | `media` |  |
| `SwitchBot Hub Mini` | **SwitchBot Hub Mini** | `Unassigned` | matter | `sensor` |  |
| `[Empty Name]` | **** | `Unassigned` | unknown | `` |  |
| `Phoscon-GW` | **Phoscon-GW** | `Unassigned` | deconz | `` |  |
| `Daylight` | **Daylight** | `Unassigned` | deconz | `sensor` |  |
| `SHIELD` | **Unassigned SHIELD TV** | `Unassigned` | cast | `media` | Cast media player target |
| `[Empty Name]` | **** | `Unassigned` | unknown | `` |  |
| `[Empty Name]` | **** | `Unassigned` | unknown | `` |  |
| `Everywhere` | **Everywhere** | `Unassigned` | alexa_devices | `media` |  |
| `lganet@gmail.com` | **lganet@gmail.com** | `Unassigned` | alexa_devices | `` |  |
| `SHIELD` | **Unassigned SHIELD TV** | `Unassigned` | music_assistant | `media` |  |
| `Samsung OLED` | **Unassigned TV** | `Unassigned` | music_assistant | `media` |  |
| `Luis’s MacBook Air` | **Luis’s MacBook Air** | `Unassigned` | music_assistant | `media` |  |
| `Stereo` | **Unassigned Stereo Speakers** | `Unassigned` | music_assistant | `media` |  |
| `Nova` | **Unassigned Nova Speaker Group** | `Unassigned` | music_assistant | `media` |  |
| `Vibration Sensor` | **Vibration Sensor** | `Unassigned` | yolink | `sensor` |  |
| `Samsung QN90AA 55 TV BR` | **Samsung QN90AA 55 TV BR** | `Unassigned` | music_assistant | `media` |  |
| `Window Sensor` | **Window Sensor** | `Unassigned` | yolink | `sensor` |  |
| `Zigbee2MQTT Bridge` | **Zigbee2MQTT Bridge** | `Unassigned` | zigbee2mqtt | `switch` |  |
| `Govee Integration` | **Govee Integration** | `Unassigned` | govee | `sensor` |  |
| `NestHubFA85` | **NestHubFA85** | `Unassigned` | cast | `media` |  |
| `NestHubFA85` | **NestHubFA85** | `Unassigned` | cast | `media` |  |
| `Smartplug Tuya 1` | **Unassigned Smart Plug 1** | `Unassigned` | tuya_local | `plug` |  |

### System / Server (42 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `Sun` | **Sun** | `Unassigned` | sun | `system` | Internal integration / system device |
| `Home Assistant Core` | **Home Assistant Core** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Home Assistant Supervisor` | **Home Assistant Supervisor** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Home Assistant Host` | **Home Assistant Host** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Home Assistant Operating System` | **Home Assistant Operating System** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Matter Server` | **Matter Server** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Forecast` | **Forecast** | `Unassigned` | met | `system` | Internal integration / system device |
| `Advanced SSH & Web Terminal` | **Advanced SSH & Web Terminal** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `GusNAS` | **GusNAS** | `kitchen` | synology_dsm | `system` | Internal integration / system device |
| `GusNAS (Drive 1)` | **GusNAS (Drive 1)** | `kitchen` | synology_dsm | `system` | Internal integration / system device |
| `GusNAS (Drive 2)` | **GusNAS (Drive 2)** | `kitchen` | synology_dsm | `system` | Internal integration / system device |
| `GusNAS (Volume 1)` | **GusNAS (Volume 1)** | `kitchen` | synology_dsm | `system` | Internal integration / system device |
| `Studio Code Server` | **Studio Code Server** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `SM-S928W` | **SM-S928W** | `Unassigned` | mobile_app | `system` | Internal integration / system device |
| `Livia` | **Livia** | `Unassigned` | mobile_app | `system` | Internal integration / system device |
| `Get HACS` | **Get HACS** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `HACS` | **HACS** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `Node-RED` | **Node-RED** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `deCONZ` | **deCONZ** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `LivingRoom` | **LivingRoom** | `Unassigned` | synology_dsm | `system` | Internal integration / system device |
| `GusNAS Surveillance Station` | **GusNAS Surveillance Station** | `Unassigned` | synology_dsm | `system` | Internal integration / system device |
| `Google Translate en com` | **Google Translate en com** | `Unassigned` | google_translate | `system` | Internal integration / system device |
| `Backup` | **Backup** | `Unassigned` | backup | `system` | Internal integration / system device |
| `Google AI Task` | **Google AI Task** | `Unassigned` | google_generative_ai_conversation | `system` | Internal integration / system device |
| `Google AI Conversation` | **Google AI Conversation** | `Unassigned` | google_generative_ai_conversation | `system` | Internal integration / system device |
| `Google AI STT` | **Google AI STT** | `Unassigned` | google_generative_ai_conversation | `system` | Internal integration / system device |
| `Google AI TTS` | **Google AI TTS** | `Unassigned` | google_generative_ai_conversation | `system` | Internal integration / system device |
| `eufy-security-ws` | **eufy-security-ws** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `OpenCode` | **OpenCode** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Music Assistant` | **Music Assistant** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `HA-MCP Custom Component` | **HA-MCP Custom Component** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `HA-MCP Server` | **HA-MCP Server** | `Unassigned` | ha_mcp_tools | `system` | Internal integration / system device |
| `WebRTC Camera` | **WebRTC Camera** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `button-card` | **button-card** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `iOS Dark Mode Theme` | **iOS Dark Mode Theme** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `Zigbee2MQTT` | **Zigbee2MQTT** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Mosquitto broker` | **Mosquitto broker** | `Unassigned` | hassio | `system` | Internal integration / system device |
| `Tuya Local` | **Tuya Local** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `Stack In Card` | **Stack In Card** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `Govee Cloud Integration` | **Govee Cloud Integration** | `Unassigned` | hacs | `system` | Internal integration / system device |
| `nspanel den` | **nspanel den** | `Unassigned` | mobile_app | `system` | Internal integration / system device |
| `Fold 8` | **Fold 8** | `Unassigned` | mobile_app | `system` | Internal integration / system device |

### On The Go (2 devices)

| Current Name | Proposed Name | Current Area | Integration | Suggested Labels | Notes |
|---|---|---|---|---|---|
| `motorcycle tag` | **On The Go motorcycle tag** | `on_the_go` | smartthings | `` |  |
| `SmartTag+ Car Key` | **On The Go SmartTag+ Car Key** | `on_the_go` | smartthings | `` |  |

---

## 5. Next Steps & Safe Execution Plan

1. **Review and Adjust**:
   * Review the suggested device names and area assignments above or in [`doc/devices-inventory-and-proposals.csv`](file:///Users/gustavo/src/ha/doc/devices-inventory-and-proposals.csv).
   * Confirm if you prefer **`Office`** or **`Den`** as the primary name (remembering we can set the other as an alias).
   * Mark any changes or additions to the suggested names.
2. **Execution Phase**:
   * We will create a scripted migration via Home Assistant MCP (`ha_set_device` / `ha_set_area_or_floor`).
   * We will check whether any entity IDs need alignment, and update all corresponding automations, helpers, and dashboard YAML files in this repository.
   * Validate the configuration before merging.
