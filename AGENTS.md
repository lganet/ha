# Home Assistant Project Instructions

This repository contains my Home Assistant configuration and is managed using Git.

## General Principles

- Treat Home Assistant configuration as production configuration.
- Make the smallest change necessary to satisfy the request.
- Do not modify unrelated configuration.
- Prefer existing Home Assistant entities, helpers, automations, scripts, scenes, and dashboards over creating duplicates.
- Before making a change, inspect the existing configuration and understand how it currently works.
- Never guess entity IDs, device IDs, area names, automation IDs, dashboard structure, or existing behavior when the information can be obtained through Home Assistant MCP.
- Use the official Home Assistant MCP server for Home Assistant operations whenever possible.

## Git Workflow

All changes must be made on a dedicated Git branch or worktree.

Never make Home Assistant configuration changes directly on `main` unless explicitly instructed.

Before starting work:

1. Ensure the working tree is clean, unless there are existing user changes relevant to the task.
2. Create or use a dedicated branch/worktree for the requested change.
3. Give the branch a descriptive name.

Examples:

- `feature/office-presence-automation`
- `feature/fp2-dashboard`
- `fix/bathroom-fan-automation`
- `refactor/lighting-automations`

Do not create unnecessary commits. Prefer logical, meaningful commits.

## Before Modifying Home Assistant

Before changing any configuration:

1. Inspect the current Home Assistant configuration relevant to the task.
2. Identify the entities, automations, scripts, scenes, helpers, dashboards, or other resources involved.
3. Understand their current behavior.
4. Check for dependencies and references to the resources being modified.
5. Make the change only after understanding the existing configuration.

Do not modify unrelated resources merely to "clean up" the configuration unless explicitly requested.

## Validation

After making changes:

1. Review the Git diff.
2. Check for YAML syntax errors.
3. Validate Home Assistant configuration using the appropriate Home Assistant validation mechanism when available.
4. Check that referenced entity IDs and services exist.
5. Check that dashboard configuration is structurally valid when modifying dashboards.
6. Check that automations, scripts, scenes, and helpers are internally consistent.
7. If validation fails, fix the issue before considering the task complete.

Never claim that a change has been validated if it has not actually been validated.

## Home Assistant MCP

Use the official Home Assistant MCP server for Home Assistant operations whenever possible.

Use MCP to inspect the live Home Assistant state when the requested change depends on current devices, entities, services, areas, automations, scripts, scenes, helpers, or dashboards.

When both the Git repository and Home Assistant contain relevant information:

- Use Git as the source of truth for version-controlled configuration.
- Use Home Assistant MCP to inspect current live state and verify resources.
- Be aware that live Home Assistant state may differ from the repository.

Do not assume that the repository and running Home Assistant are synchronized.

## Change Planning

For non-trivial changes:

1. Inspect the current implementation.
2. Explain the intended approach briefly.
3. Formulate an implementation plan.
4. Save the generated plan in the `doc/` folder with a concise name including the date (e.g., `doc/YYYY-MM-DD-<topic>.md`).
5. Identify which files/resources will be modified.
6. Make the changes.
7. Validate them.
8. Review the Git diff.
9. Update `CHANGELOG.md`.
10. Prepare the branch for a pull request.

Avoid asking for approval for every small implementation detail. Ask for clarification when requirements are ambiguous or when a change could have significant unintended effects.

### Implementation Plans (`doc/`)

Whenever an implementation plan is created or updated for a task:

- Save the plan in the repository's `doc/` folder.
- Choose a concise, descriptive filename that clearly identifies the plan's purpose.
- Prefix the filename with the date in `YYYY-MM-DD` format (e.g., `doc/YYYY-MM-DD-<topic>.md`).
- Commit the plan in the feature branch alongside the implementation.


## CHANGELOG.md

Maintain `CHANGELOG.md` as a concise history of changes merged into the project.

Every change intended for a pull request must include an appropriate `CHANGELOG.md` entry.

Add the changelog entry in the same branch and pull request as the corresponding configuration change.

Do not modify historical changelog entries unless explicitly requested.

Use the following structure:

# Changelog

## Unreleased

### Added
- ...

### Changed
- ...

### Fixed
- ...

### Removed
- ...

Before creating a PR:

- Move the appropriate items from `Unreleased` into a new version/release section if the project uses explicit versions.
- If the project does not use release versions, keep the changes under `Unreleased` until the PR is merged.
- Keep entries concise and focused on user-visible or operationally meaningful changes.
- Do not include implementation details that are irrelevant to someone maintaining the Home Assistant configuration.

Each changelog entry should explain WHAT changed and, when useful, WHY.

Example:

- Added office presence automation using Aqara FP300 to control office lighting.
- Changed living-room dashboard to display FP2 zone presence.
- Fixed bathroom fan automation triggering Alexa notifications when the door sensor changes state.

## Pull Requests

When the requested work is complete:

1. Ensure all intended changes are committed.
2. Ensure `CHANGELOG.md` is updated.
3. Review the complete Git diff.
4. Verify there are no unrelated changes.
5. Run appropriate validation.
6. Provide a concise summary of:
   - What changed
   - Why it changed
   - Validation performed
   - Any limitations or follow-up work

The branch should be ready for a pull request.

Do not merge the pull request unless explicitly instructed.

## Commits

Use clear, descriptive commit messages.

Prefer messages such as:

- `feat: add office presence automation`
- `fix: prevent duplicate Alexa notification`
- `feat: add FP2 presence dashboard`
- `refactor: simplify living room lighting automations`

Do not include secrets, credentials, access tokens, or sensitive authentication information in commits.

## Secrets and Sensitive Data

Never commit:

- API tokens
- OAuth credentials
- passwords
- private keys
- access tokens
- Home Assistant secrets
- other credentials or secrets

Be especially careful with:

- `secrets.yaml`
- `.env` files
- credential/configuration files containing tokens

If a requested change would expose a secret, stop and ask for a safe alternative.

## Existing User Changes

Never discard, overwrite, reset, or modify unrelated uncommitted user changes.

If the working tree contains changes that were present before the task began:

1. Preserve them.
2. Determine whether they are relevant to the task.
3. Do not include unrelated changes in the branch or PR.

If it is unclear whether an existing change belongs to the current task, ask before modifying or committing it.

## Completion Criteria

A task is complete when:

- The requested Home Assistant change has been implemented.
- Only relevant files/resources were modified.
- Configuration has been validated where possible.
- The Git diff has been reviewed.
- `CHANGELOG.md` has been updated.
- The branch contains the intended commits.
- The branch is ready for a pull request.

Do not consider a task complete merely because the configuration was modified successfully.

## Versioning

This project uses Semantic Versioning:

    MAJOR.MINOR.PATCH

The current project version is stored in the `VERSION` file.

Versioning rules:

- PATCH: Bug fixes, corrections, tuning, and small configuration changes.
- MINOR: New functionality, automations, dashboards, devices, helpers, scripts, scenes, or other backward-compatible additions.
- MAJOR: Breaking changes, major restructuring, removal of functionality, or changes that require significant migration.

Do not increment the version for every individual commit.

The version must be incremented when preparing a pull request for completed work.

When preparing a pull request:

1. Read the current version from `VERSION`.
2. Determine the appropriate Semantic Versioning increment based on the complete set of changes in the branch.
3. Update `VERSION`.
4. Update `CHANGELOG.md` with the new version.
5. Review the complete Git diff.
6. Commit the version and changelog changes together with the final PR preparation commit.

The version must be incremented exactly once per pull request unless explicitly instructed otherwise.

Do not change the version on `main` directly.

The version in `VERSION` and the corresponding version heading in `CHANGELOG.md` must always match.

Example:

Current:

    VERSION
    1.4.2

After preparing a PR containing new office presence functionality:

    VERSION
    1.5.0

CHANGELOG.md:

    # Changelog

    ## 1.5.0 - 2026-09-16

    ### Added
    - Added office presence automation using the Aqara FP300.

    ## 1.4.2 - 2026-09-10
    ...