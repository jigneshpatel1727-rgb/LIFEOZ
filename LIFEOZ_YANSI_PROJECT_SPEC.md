# LIFEOZ / YANSI — LOCKED PROJECT SPECIFICATION

Status: LOCKED BASELINE  
Purpose: This file is the coding source-of-truth for LifeOS/Yansi. Before changing code, review this file and preserve all requirements unless the user explicitly changes them.

## 1. Product Vision

LifeOS is a super-intelligent personal operating system. Yansi is its intelligent companion/agent, not a conventional chatbot and not merely a collection of small assistant features.

Core principle:
- One screen.
- One tap.
- One report.
- Less information on screen + more intelligence behind the screen.

Yansi should feel like an ambient/ghost presence: futuristic, calm, intelligent and available when needed, without occupying the screen like a chatbot.

## 2. Yansi Core Capabilities

Yansi should:
- converse naturally with the user about day-to-day life and problems;
- listen and respond by voice;
- understand natural-language input instead of requiring manual forms whenever possible;
- understand LifeOS context and connect information across modules;
- remember useful user-approved information and history;
- learn from approved interactions and accumulated LifeOS history;
- identify recurring patterns in routines, spending, tasks, goals and behaviour;
- provide useful suggestions, explanations, motivation and practical problem-solving;
- proactively surface useful information when appropriate;
- use current web/Google/approved search services when the user permits web access;
- use external/current knowledge for research, comparisons, explanations and learning;
- analyze LifeOS data and produce reports, trends and predictions;
- help diagnose application problems and support controlled repair/update workflows.

Yansi must not:
- secretly rewrite or deploy its own core behaviour;
- grant itself permissions;
- perform sensitive actions without appropriate authorization/confirmation;
- diagnose a user's mental/medical condition merely from behaviour patterns.

Behavioural analysis is for useful pattern recognition and suggestions, not psychological diagnosis.

## 3. Voice and Ambient Behaviour

Voice is a core Yansi capability and should be enabled by default at the LifeOS level. The Android operating system may still require its own microphone permission; the application cannot bypass OS security.

Yansi should:
- speak naturally when appropriate;
- listen when activated/available;
- remain quiet when conversation is not useful;
- avoid continuously talking or covering the screen;
- use the futuristic neural/orb presence as the primary visual representation;
- speak the user's name naturally after the profile is known, e.g. a welcome message identifying Yansi as the user's personal LifeOS AI agent.

## 4. Memory and Learning

Memory must be user-controlled and transparent.

Yansi may maintain:
- conversation history;
- useful LifeOS history;
- approved memories;
- recurring patterns;
- learned preferences and interests;
- explainable confidence for inferred patterns.

Learning should improve usefulness over time but must not silently change Yansi's fundamental safety rules or core application behaviour.

Users must have a way to manage/clear stored learning and memory.

## 5. Web / External Knowledge

When the user permits web access, Yansi should be able to use approved web/search services for:
- current information;
- research;
- explanations;
- comparisons;
- learning;
- other questions where current external information is useful.

Web access must be permission-controlled and transparent.

## 6. LifeOS Five-Core Experience

The main screen should present five finalized core icons without displaying unnecessary core names.

The central Yansi neural/orb presence is the intelligent interface.

When a user taps a core:
- Yansi should be able to explain what that core represents;
- the core opens a single-screen detail/report/analysis experience;
- the screen should prioritize intelligence and visual summaries over large amounts of text;
- records, analysis, reports and relevant actions should be accessible without creating a maze of screens.

The five core areas must be developed as an integrated system, not as isolated unrelated prototypes.

## 7. Life Management Functions

The integrated LifeOS must support:

1. Expense management
   - natural-language/voice entry;
   - categorization;
   - reports and trends;
   - spending analysis and saving suggestions.

2. Productivity / Tasks
   - home and job tasks;
   - completion percentage;
   - pending tasks automatically carried forward until completed;
   - Yansi assistance and prioritization.

3. Calendar / Important Dates
   - bills and due dates;
   - insurance/policy renewals;
   - birthdays and anniversaries;
   - vehicle service;
   - medical checkups;
   - investment and payment dates;
   - reminders and proactive alerts.

4. Household / Shopping
   - daily household and kitchen lists;
   - recurring requirements;
   - grocery/bill scanning through camera;
   - AI extraction and item/price categorization.

5. Personal Diary
   - voice-to-text;
   - natural conversation as diary input;
   - date-wise storage and retrieval.

6. Goals
   - personal and financial goals;
   - progress and suggestions;
   - Yansi guidance.

7. Investments
   - shares/stock-market tracking;
   - mutual funds;
   - investment dates and analysis;
   - current information through approved web services where needed.

8. Health
   - health tracking capability;
   - integration with supported phone/watch/fitness devices where technically available and authorized.

## 8. Data and Reporting

LifeOS should maintain useful date-wise history and provide:
- daily;
- weekly;
- monthly;
- quarterly;
- half-yearly;
- yearly
summaries and reports.

Reports should favor graphs, trends, concise insights and actionable recommendations.

## 9. Futuristic UI

The visual direction is locked:
- super-hyper-futuristic;
- polished;
- premium;
- neural-network / AI aesthetic;
- neon blue/green visual language;
- central intelligent orb;
- five aligned core icons;
- minimal text;
- compact smart controls;
- no unnecessary core-name labels;
- top controls should remain compact and can be hidden/drop down when appropriate;
- Yansi should not be presented as a conventional chatbot screen.

## 10. Permissions

Permissions should be understandable and user-controlled.

Core Yansi voice/ambient capability is enabled by default at the LifeOS level, while Android OS permissions remain mandatory where required.

Other capabilities such as notifications, web access, health data and background processing must respect their applicable permissions.

Sensitive actions require confirmation.

## 11. Self-Diagnostics and Controlled Repair

LifeOS should eventually detect:
- build failures;
- missing files/imports;
- configuration problems;
- runtime problems where detectable;
- integration failures.

Yansi may diagnose problems and prepare or execute controlled code changes through authorized development workflows.

Self-repair must remain controlled. Yansi must not secretly alter its fundamental rules, permissions model or safety boundaries.

## 12. Development Rules

Before every coding change:
1. Read this specification.
2. Inspect the current repository state.
3. Reuse existing working code rather than rebuilding it unnecessarily.
4. Make integrated, meaningful progress rather than creating tiny disconnected architecture layers.
5. Build/check after significant changes.
6. If RED, fix the failure before stacking unrelated changes.
7. Never claim GREEN without checking the actual build/status.
8. Do not ask the user to repeat requirements already contained here.
9. Keep this file updated when the user explicitly changes a locked requirement.

## 13. Definition of Success

The goal is not a collection of demo screens. The goal is a working LifeOS product in which Yansi is the intelligence layer connecting the user's information, conversations, memory, learning, analysis, web knowledge and proactive assistance through a futuristic ambient experience.

Any future code that conflicts with this specification must be treated as technical debt to be corrected, unless the user explicitly changes the requirement.
