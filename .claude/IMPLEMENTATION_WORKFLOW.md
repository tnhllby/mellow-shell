# Implementation Workflow

## Before coding
- Read the current milestone task.
- Inspect repository and environment.
- Check installed Quickshell and Hyprland versions.
- Verify relevant APIs.
- Identify dependencies already installed.
- State assumptions and risks.

## During coding
- Work in small increments.
- Keep the app launchable after each increment.
- Avoid unrelated refactoring.
- Use semantic design tokens.
- Centralize service state.
- Handle missing services.
- Keep logs actionable.

## After coding
- Run available QML/lint/static checks.
- Launch MELLOW in the VM if possible.
- Test the specific interaction.
- Inspect logs for runtime errors.
- Summarize modified files.
- Record limitations and untested behavior.

## Git discipline
Use small commits after verified increments. Examples:
- `chore: bootstrap Quickshell project`
- `feat: add semantic theme tokens`
- `feat: implement full-width top panel`
- `feat: integrate Hyprland workspaces`
- `feat: add persistent workspace frame`
- `fix: handle monitor geometry updates`

Do not rewrite user commits without permission.
