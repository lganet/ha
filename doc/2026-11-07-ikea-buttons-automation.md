# Implementation Plan - IKEA Buttons Automation (RODRET & STYRBAR)

Automate two Zigbee IKEA remote controls (**Button 1: IKEA RODRET** and **Button 2: IKEA STYRBAR**) to manage room lighting, smart plugs, the patio entrance door lock, and camera livestreams on the Google Nest Hub Max.

## Goal Description
Configure Home Assistant automations for two distinct remotes:
1. **Button 1 (`Botao Ikea 1` - IKEA RODRET 2-button dimmer)**:
   - Single press **ON** $\rightarrow$ Turn ON **Lamp HS220** (`light.patio_left_light`, TP-Link HS220 dimmer located in Living Room).
   - Single press **OFF** $\rightarrow$ Turn OFF **Lamp HS220**.
   - Hold **ON** and wait for lift off $\rightarrow$ Turn ON **LEDs Plug** (`switch.living_room_leds_plug`).
   - Hold **OFF** and wait for lift off $\rightarrow$ Turn OFF **LEDs Plug**.
2. **Button 2 (`Ikea button 2` - IKEA STYRBAR 4-button remote)**:
   - Single press **ON** $\rightarrow$ Turn ON **Patio Left Light** (`switch.patio_left_light_switch`).
   - Single press **OFF** $\rightarrow$ Turn OFF **Patio Left Light**.
   - Hold **ON** $\rightarrow$ Unlock **Patio Door Lock** (`lock.patio_door_lock`).
   - Hold **OFF** $\rightarrow$ Lock **Patio Door Lock**.
   - Single press **LEFT arrow** $\rightarrow$ Stream **Patio Left Camera** (`camera.patio_left`) to Google Nest Hub Max (`media_player.kitchen_display`) for 5 minutes, then stop.
   - Single press **RIGHT arrow** $\rightarrow$ Stream **Patio Right Camera** (`camera.patio_right`) to Google Nest Hub Max (`media_player.kitchen_display`) for 5 minutes, then stop.

---

## User Review & Decisions

1. **Finger Lift Timing**: User confirmed strictly waiting until finger lifts off for the LEDs plug hold control. Implemented via `wait_for_trigger` on `brightness_stop` following `brightness_move_up` / `brightness_move_down`.
2. **Camera Streaming Duration**: User confirmed stopping the livestream automatically after 5 minutes. Implemented via dedicated script `script.stream_patio_camera_to_hub` in `mode: restart`.
3. **Door Lock Direct Control**: User confirmed PIN-less unlock is intentional because the patio door is directly visible from the kitchen.
4. **TP-Link HS220 Historical Entity Misnaming**: The TP-Link HS220 switch located in the Living Room named `Lamp` currently retains entity ID `light.patio_left_light`. The automation targets `light.patio_left_light` for Button 1, and the Shelly relay `switch.patio_left_light_switch` for Button 2.

---

## Proposed Changes

### 1. Scripts
#### [NEW] [stream_patio_camera_to_hub.yaml](file:///home/gustavo/src/ha/scripts/stream_patio_camera_to_hub.yaml)
- Stream requested camera to `media_player.kitchen_display` with 5-minute auto-stop delay and opposite camera stream shutdown.

### 2. Automations
#### [NEW] [ikea_button_1_controls.yaml](file:///home/gustavo/src/ha/automations/ikea_button_1_controls.yaml)
- Single press ON/OFF for Living Room Lamp HS220 (`light.patio_left_light`).
- Hold and lift ON/OFF for LEDs Plug (`switch.living_room_leds_plug`) via `wait_for_trigger` on `brightness_stop`.

#### [NEW] [ikea_button_2_controls.yaml](file:///home/gustavo/src/ha/automations/ikea_button_2_controls.yaml)
- Single press ON/OFF for Patio Left light (`switch.patio_left_light_switch`).
- Hold ON/OFF for Patio Door lock (`lock.patio_door_lock`).
- Left/Right click triggers `script.stream_patio_camera_to_hub` for 5-minute camera streaming on Google Hub Max.

---

## Verification Plan

### Automated Tests
1. YAML Syntax Check: `python3 -c "import yaml; yaml.safe_load(open('...'))"`
2. Home Assistant configuration reload and deployment validation via MCP.

### Manual Verification
1. Press Button 1 ON/OFF to toggle Living Room Lamp HS220.
2. Hold and release Button 1 ON/OFF to toggle LEDs plug.
3. Press Button 2 ON/OFF to toggle Patio Left light.
4. Hold Button 2 ON/OFF to unlock/lock Patio door.
5. Press Button 2 Left/Right arrows to cast camera stream to Kitchen Hub Display.
