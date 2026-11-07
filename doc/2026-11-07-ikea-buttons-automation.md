# Implementation Plan - IKEA Buttons Automation (RODRET & STYRBAR)

Automate two Zigbee IKEA remote controls (**Button 1: IKEA RODRET** and **Button 2: IKEA STYRBAR**) to manage room lighting, smart plugs, the patio entrance door lock, and camera livestreams on the Google Nest Hub Max using state toggling.

## Goal Description
Configure Home Assistant automations for two distinct remotes:
1. **Button 1 (`Botao Ikea 1` - IKEA RODRET 2-button dimmer)**:
   - Single press **ON** $\rightarrow$ Toggle **Lamp HS220** (`light.patio_left_light`, TP-Link HS220 dimmer located in Living Room).
   - Hold **ON** and wait for finger release $\rightarrow$ Toggle **Ceiling Light (Dining Room)** (`light.dining_room_light`).
   - Single press **OFF** $\rightarrow$ Toggle **LEDs Plug** (`switch.living_room_leds_plug`).
   - Hold **OFF** and wait for finger release $\rightarrow$ Toggle **Patio Left Light** (`switch.patio_left_light_switch`).
2. **Button 2 (`Ikea button 2` - IKEA STYRBAR 4-button remote)**:
   - Single press **ON** $\rightarrow$ Toggle **Right Patio Light** (`switch.patio_right_light`).
   - Single press **OFF** $\rightarrow$ Toggle **Patio Door Lock** (`lock.patio_door_lock`) (unlock if locked, lock if unlocked).
   - Single press **LEFT arrow** $\rightarrow$ Stream **Patio Left Camera** (`camera.patio_left`) to Google Nest Hub Max (`media_player.kitchen_hub_display`) via WebRTC Dash Cast for 5 minutes, then stop.
   - Single press **RIGHT arrow** $\rightarrow$ Stream **Patio Right Camera** (`camera.patio_right`) to Google Nest Hub Max (`media_player.kitchen_hub_display`) via WebRTC Dash Cast for 5 minutes, then stop.

---

## User Review & Decisions

1. **Toggle Behavior Across Both Remotes**: User requested that all button presses operate as state toggles:
   - Button 1 ON click: toggles Lamp HS220.
   - Button 1 ON hold & release: toggles Dining Room Ceiling Light.
   - Button 1 OFF click: toggles LEDs Plug.
   - Button 1 OFF hold & release: toggles Patio Left Light.
   - Button 2 ON click: toggles Right Patio Light.
   - Button 2 OFF click: toggles Patio Door Lock (unlock if locked, lock if unlocked).
2. **Finger Lift Timing**: Implemented via `wait_for_trigger` on `brightness_stop` following `brightness_move_up` / `brightness_move_down` with a 15-second safety timeout.
3. **Dual MQTT & Device Triggers**: Both remotes now listen on both direct Zigbee2MQTT MQTT topics (`zigbee2mqtt/<device_name>/action`) and HA device automation triggers for instantaneous, fault-tolerant execution.
4. **Camera Streaming on Google Nest Hub Max**:
   - Streamed via `script.stream_patio_camera_to_hub` using `eufy_security.start_p2p_livestream` and `webrtc.dash_cast` to `media_player.kitchen_hub_display`.
   - Includes `continue_on_error: true` on P2P stop/start calls to eliminate crashes when stopping inactive livestreams.
   - Auto-stops after 5 minutes or when switching between cameras (`mode: restart`).

---

## Repository Files

### 1. Scripts
- `scripts/stream_patio_camera_to_hub.yaml`: WebRTC Dash Cast streaming with 5-minute timer and safe P2P lifecycle management.

### 2. Automations
- `automations/ikea_button_1_controls.yaml`: RODRET toggle controls for Lamp, Dining Light, LEDs Plug, and Patio Left Light.
- `automations/ikea_button_2_controls.yaml`: STYRBAR toggle controls for Right Patio Light, Patio Door Lock, and Hub Max camera streams.
