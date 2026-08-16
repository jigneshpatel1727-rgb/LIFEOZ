# ALL IN MY DAY — Phase 2 Intelligence Plan

Status: IN DEVELOPMENT

## Objective

Turn the existing five-core experience into an intelligent, connected system while keeping Yansi ambient/ghost. Phase 2 must improve what the user can accomplish, not add another chatbot screen.

## Phase 2 priorities

1. **Natural input**
   - Voice/text can create expenses, tasks, reminders, household items, goals and diary entries.
   - Preserve confirmation for sensitive/high-risk actions.

2. **Automatic task carry-forward**
   - Pending tasks from earlier dates move forward automatically until completed.
   - Preserve original date and carry-forward history.
   - Never create duplicate carry-forward records for the same task/day.

3. **Cross-core intelligence**
   - Build a compact snapshot across expenses, income, tasks, reminders, household, goals and diary.
   - Use explainable signals rather than hidden behavioural diagnosis.

4. **Daily intelligence**
   - Identify useful patterns and priority signals.
   - Prepare concise insights for reports and future ambient delivery.

5. **Voice/ambient foundation**
   - Keep Yansi visually subtle.
   - Do not label Yansi as a permanent visible core.
   - Do not turn the home screen into a conventional chat UI.

6. **Reporting**
   - Connect Phase 2 signals to the existing one-screen core reports.
   - Prefer graphs, trends and concise actionable information.

7. **Privacy and control**
   - Local Phase 2 maintenance must not silently grant permissions.
   - Memory and learning remain user-controlled.
   - Sensitive actions require confirmation.

## Current Phase 2 implementation started

- `lib/services/yansi_phase2_intelligence.dart` provides local daily maintenance and task carry-forward.
- `lib/main.dart` runs the safe daily maintenance at startup before the app opens.
- App title has been changed from the legacy LIFEOZ title to `ALL IN MY DAY`.

## Next implementation slices

- Connect Phase 2 snapshot to the core report screen without adding visible Yansi branding.
- Add deterministic task completion/carry-forward controls.
- Improve voice intent parsing and confirmation boundaries.
- Add daily insight generation from existing stored data.
- Add tests for task carry-forward, duplicate prevention and date boundaries.
- Verify Android build before merging into `main`.

## Definition of done for Phase 2 MVP

A user can speak naturally, have useful LifeOS data captured, see intelligent one-screen reports, and have unfinished tasks continue into the next day automatically—while Yansi remains an ambient intelligence layer rather than a visible chatbot/core.
