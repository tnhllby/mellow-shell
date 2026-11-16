# Claude Code Instructions — MELLOW

You are contributing to MELLOW, a Hyprland-native desktop shell built with Quickshell and QML.

Before changing code, read:
- DESIGN.md
- ARCHITECTURE.md
- ROADMAP.md
- docs/DECISIONS.md
- the current task in docs/

## Priorities
1. Reliable core desktop workflows.
2. Consistent Material-inspired design.
3. Correct Hyprland integration.
4. Performance and graceful failure.
5. Optional visual effects.
6. Additional features only when justified.

Do not optimize for feature count.

## Design rules
- DESIGN.md is the canonical visual specification.
- MELLOW should feel related to Pixel UI but remain original.
- Use shared semantic theme tokens.
- Do not hardcode colors when semantic tokens exist.
- Avoid unrelated icon packs.
- Avoid generic flat rectangles and excessive glassmorphism.
- Use organic shapes intentionally.
- All core controls support keyboard and pointer.
- Blur and intensive animation are optional.

## Technical rules
- Verify Quickshell APIs against the installed version and local/current documentation.
- Never invent QML types, properties, signals or methods.
- Inspect repository and environment before implementation.
- Prefer supported Quickshell integrations over custom polling.
- Centralize Hyprland state and events.
- Do not create polling loops in individual widgets.
- Separate UI, services and configuration.
- Avoid monolithic QML files.
- Handle missing services gracefully.
- Do not block the UI thread.
- Avoid unnecessary dependencies.

## Scope control
Before proposing a feature, state the user problem, whether an existing module already solves it, maintenance cost and milestone fit. Do not add speculative modules or decorative widgets.

## Safety
- Development happens on the developer's daily-driver host (running another shell).
  Work only inside this repository; never modify the host's `~/.config`, never install
  packages there, and do not inject input into the live session.
- Full testing happens on a separate clean Arch + Hyprland PC via `install.sh`.
- Do not modify host configuration.
- Do not overwrite Waybar, Caelestia, Hyprland or display-manager configuration.
- Do not enable autostart unless explicitly requested.
- Do not run destructive commands.
- Do not alter bootloader, partitions or filesystem configuration.
- Ask before system-wide dependency installation if permission is unclear.
- Maintain a manual rollback path.

## Workflow
1. Inspect relevant files and environment.
2. Summarize findings and risks.
3. Propose the smallest implementation satisfying the task.
4. Implement only the current milestone.
5. Run available checks and launch tests.
6. Report exactly what was tested and what remains unverified.
7. Update documentation when behavior or architecture changes.

Never claim something works unless it was tested.
