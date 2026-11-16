# Khanh's agent instructions

These are common instructions for Khanh's Codex agents across all scenarios.

## General guidelines

- Never use the em dash character. Use a plain hyphen instead.
- When writing commit messages, never add Codex or an agent name as a co-author.
- Never manually modify `CHANGELOG.md` files or files marked as auto-generated.
- When writing or substantially editing long Markdown files, put each full sentence on its own line.
- Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
- When making technical decisions, do not give excessive weight to development cost.
- Prefer quality, simplicity, robustness, scalability, and long-term maintainability.
- When fixing bugs, first reproduce the problem in an end-to-end environment that closely matches the user's real workflow.
- Confirm that the fix addresses the root problem and not only its visible symptom.
- During end-to-end testing, inspect the UI carefully and maintain a high standard for visual detail.
- If something clearly looks wrong, fix it when it is safely within the task's scope, even when it is not the direct focus of the request.
- Apply the same standard to engineering quality, including lint errors, test failures, and flaky tests.
- If you notice an issue that is outside the current scope or unsafe to change, report it clearly instead of ignoring it.
- If any user request is vague or lacks necessary context, ask brief, targeted clarifying questions before providing a full solution.
- If user request is related to herdr-app, you must read ~/.config/herdr-app/AGENTS.md and ~/.agents/skills/herdr/SKILL.md

## Khanh's opinions

When work would benefit from Khanh's viewpoints, read `~/OPINIONS.md` before making relevant decisions.

If that file is unavailable, continue with the available project context and state any material assumptions.

## Voice profile

When writing or posting on behalf of Khanh, read `~/VOICE.md` first to understand how Khanh communicates.

If that file is unavailable, use a professional, direct, concise, and natural voice.
