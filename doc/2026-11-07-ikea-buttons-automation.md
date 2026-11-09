# Implementation Plan - IKEA Buttons Automation (RODRET & STYRBAR)

Automate two Zigbee IKEA remote controls (**Button 1: IKEA RODRET** and **Button 2: IKEA STYRBAR**) to manage room lighting, smart plugs, the patio entrance door lock, and camera livestreams on the Google Nest Hub Max using state toggling.

## Goal Description
Configure Home Assistant automations for two distinct remotes:
1. **Button 1 (`Botao Ikea 1` - IKEA RODRET 2-button dimmer)**:
   - Single press **ON** $\rightarrow$ Toggle **Lamp HS220** (`light.patio_left_light`, TP-Link HS220 dimmer located in Living Room).
   - Hold **ON** and wait for finger release $\rightarrow$ Toggle **Ceiling Light (Dining Room)** (`light.dining_room_light`).
   - Single press **OFF** $\rightarrow$ Toggle **LEDs Plug** (`switch.living_room_leds_plug`).
   - Hold **OFF** and wait for finger release $\rightarrow$ Toggle **Patio Right Light** (`switch.patio_right_light`).
2. **Button 2 (`Ikea button 2` - IKEA STYRBAR 4-button remote)**:
   - Single press **ON** $\rightarrow$ Toggle **Patio Left Light** (`switch.patio_left_light_switch`).
   - Single press **OFF** $\rightarrow$ Toggle **Patio Door Lock** (`lock.patio_door_lock`) (unlock if locked, lock if unlocked).
   - Single press **LEFT arrow** $\rightarrow$ Stream **Patio Right Camera** (`camera.patio_right`).
   - Single press **RIGHT arrow** $\rightarrow$ Stream **Patio Left Camera** (`camera.patio_left`).

---

## User Review & Decisions

1. **Toggle Behavior Across Both Remotes**: User requested that all button presses operate as state toggles:
   - Button 1 ON click: toggles Lamp HS220.
   - Button 1 ON hold & release: toggles Dining Room Ceiling Light.
   - Button 1 OFF click: toggles LEDs Plug.
   - Button 1 OFF hold & release: toggles Patio Right Light.
   - Button 2 ON click: toggles Patio Left Light.
   - Button 2 OFF click: toggles Patio Door Lock (unlock if locked, lock if unlocked).
2. **Finger Lift Timing**: Implemented via `wait_for_trigger` on `brightness_stop` following `brightness_move_up` / `brightness_move_down` with a 15-second safety timeout.
3. **Dual MQTT & Device Triggers**: Both remotes listen on both direct Zigbee2MQTT MQTT topics (`zigbee2mqtt/<device_name>/action`) and HA device automation triggers for instantaneous, fault-tolerant execution.
4. **Patio Inverted Entities Alignment**: Corrected inverted Left and Right Patio light and camera mappings per user clarification.
5. **Camera Streaming on Google Nest Hub Max & Dashboard Controls**:
   - Google Assistant text commands for remote camera streaming are restricted by Eufy's cloud policy (*"Patio Left does not support remote streaming"*).
   - Designed a purpose-built **Camera Controls** dashboard (`dashboards/camera-controls.yaml`) optimized for the 10-inch Nest Hub Max (1280x800) and desktop/mobile browsers.
   - Built around low-power snapshot viewing (`image.patio_left_event_image`, `image.patio_right_event_image`) to preserve battery life, with on-demand 2-minute live stream controls and tap-to-refresh snapshot actions.
   - Automated via `script.stream_patio_camera_to_hub` to wake the requested camera and cast the dashboard view to the Nest Hub Max for 2 minutes before automatically returning to ambient clock/photos mode.

---

## Repository Files

### 1. Dashboards
- `dashboards/camera-controls.yaml`: 10-inch optimized dashboard with conditional snapshot/live video cards and patio controls.

### 2. Scripts
- `scripts/stream_patio_camera_to_hub.yaml`: Wakes camera, captures snapshot, and casts Camera Controls dashboard to Nest Hub Max for 2 minutes.
- `scripts/stream_patio_left.yaml` & `scripts/stream_patio_right.yaml`: 2-minute auto-timed P2P streaming scripts.
- `scripts/stop_patio_left.yaml` & `scripts/stop_patio_right.yaml`: Immediate manual stream termination scripts.

### 3. Automations
- `automations/ikea_button_1_controls.yaml`: RODRET toggle controls for Lamp, Dining Light, LEDs Plug, and Patio Right Light.
- `automations/ikea_button_2_controls.yaml`: STYRBAR toggle controls for Patio Left Light, Patio Door Lock, and camera dashboard cast.
- `automations/patio_cameras_start_livestream_on_motion.yaml`: Fixed trigger IDs for motion activation.
- `automations/patio_cameras_stop_livestream_on_no_motion.yaml`: Fixed trigger IDs for motion deactivation.
