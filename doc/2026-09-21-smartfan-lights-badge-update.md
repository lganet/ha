# Implementation Plan: Add Smart Fan Lights and Group Badge Count

The user requested:
1. Adding the missing Smart Fan lights to the Den NSPanel dashboard:
   - Main Fan Light (`light.smart_fan_3`): Warm/cool white dimmer with color temperature and brightness controls.
   - Fan Backlight (`light.smart_fan_backlight`): RGB ambient backlight with brightness control and full RGB color picker via more-info.
2. Updating the "All Lights" notification badge helpers (`sensor.den_lights_on` and `sensor.den_lights_off`) so that all three Smart Fan lights (`light.smart_fan_3`, `light.smart_fan_backlight`, `light.smart_fan_nightlight`) count collectively as **1** light towards the total light count.

---

## 1. Light Count Badge Logic (Smart Fan Composite Count)

All room lights in the Den (Ceiling Light `light.h60b0`, Wall Lights `light.h6061`, Floor Light `light.h6076`, plus any future room lights added to the area) are counted individually. The three Smart Fan lights are grouped together:

- **Den Lights On (`sensor.den_lights_on`)**:
  ```jinja2
  {% set fan_lights = ['light.smart_fan_3', 'light.smart_fan_backlight', 'light.smart_fan_nightlight'] %}
  {% set room_lights_on = expand(area_entities('den')) | selectattr('domain', 'eq', 'light') | rejectattr('entity_id', 'in', fan_lights) | selectattr('state', 'eq', 'on') | list | count %}
  {% set fan_on = 1 if is_state('light.smart_fan_3', 'on') or is_state('light.smart_fan_backlight', 'on') or is_state('light.smart_fan_nightlight', 'on') else 0 %}
  {{ room_lights_on + fan_on }}
  ```
  - Result: If any fan light is `on`, fan adds `+1`.

- **Den Lights Off (`sensor.den_lights_off`)**:
  ```jinja2
  {% set fan_lights = ['light.smart_fan_3', 'light.smart_fan_backlight', 'light.smart_fan_nightlight'] %}
  {% set room_lights_off = expand(area_entities('den')) | selectattr('domain', 'eq', 'light') | rejectattr('entity_id', 'in', fan_lights) | selectattr('state', 'eq', 'off') | list | count %}
  {% set fan_off = 1 if is_state('light.smart_fan_3', 'off') and is_state('light.smart_fan_backlight', 'off') and is_state('light.smart_fan_nightlight', 'off') else 0 %}
  {{ room_lights_off + fan_off }}
  ```
  - Result: If all fan lights are `off`, fan adds `+1`.

---

## 2. Dashboard Card Layout (`dashboards/nspanel-den.yaml`)

Under the **Lights** section (`cards` grid with `columns: 2`):
- `light.h60b0` (Ceiling Light) — `light-brightness`
- `light.h6061` (Wall Lights) — `light-brightness`
- `light.h6076` (Floor Light) — `light-brightness`
- `light.smart_fan_backlight` (Fan Backlight) — `light-brightness`, tap-action `more-info` for color wheel
- `light.smart_fan_3` (Fan Light) — `light-brightness`, `light-color-temp`, tap-action `more-info`

Under the **Fan & Air** section:
- `fan.smart_fan` (Smart Fan) — speed & direction
- `fan.air_purifier_2` (Air Purifier) — preset modes dropdown
- `light.smart_fan_nightlight` (Night Light) — toggle
- `select.smart_fan_scene` (Fan Scene) — select-options

---

## 3. Deployment & Verification

1. Update live template helpers in Home Assistant via MCP `ha_config_set_helper`.
2. Update repository file `dashboards/nspanel-den.yaml`.
3. Deploy updated dashboard to live Home Assistant via MCP `ha_config_set_dashboard`.
4. Validate rendering and sensor states.
5. Update `VERSION` (bump to `0.2.4`) and `CHANGELOG.md`.
6. Commit and push to PR #2.
