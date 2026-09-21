# Implementation Plan: Dark Theme for Den Panel Dashboard

## Context & Objectives
The user requested a dark theme for the Sonoff NSPanel 120 Pro Den dashboard. The embedded Android WebView on the NSPanel Pro does not inherit system-wide dark mode by default (running Android 8.1), causing default dashboards to render in light mode unless a dark theme is explicitly assigned.

## Proposed Changes
1. **Install Theme**:
   - Installed `iOS Dark Mode Theme` (`basnijholt/lovelace-ios-dark-mode-theme`) via HACS.
   - Reloaded themes via `frontend.reload_themes` service, registering `ios-dark-mode`.
2. **`dashboards/nspanel-den.yaml`**:
   - Assign `theme: ios-dark-mode` to the Den view to force the dark color palette (dark cards, dark background, high contrast text) across all devices and kiosks accessing the panel.
3. **Sync Live Dashboard**:
   - Update `nspanel-den` via `ha_config_set_dashboard` MCP tool.
4. **Documentation & Versioning**:
   - Bump version to `0.2.2` in `VERSION`.
   - Record change in `CHANGELOG.md`.

## Verification
- Verify `dashboards/nspanel-den.yaml` YAML syntax.
- Verify live dashboard updates successfully in Home Assistant via MCP.
- Verify view loads `ios-dark-mode` theme cleanly.
