# iamyansi Agent Architecture

## Product rule

Iamyansi is the invisible/ambient intelligence layer, not a sixth core and not a permanent chatbot screen.

## Layers

1. **Input** — speech-to-text, text, and future permissioned notification/message inputs.
2. **Understanding** — intent, entities, dates, amounts, categories and context.
3. **Agent orchestration** — decide whether to answer, ask, act, research or request confirmation.
4. **Tools** — controlled operations for the five cores and future services.
5. **Canonical data** — one source of truth shared with all five cores.
6. **Verification** — confirm that an action actually persisted before reporting success.
7. **Memory** — short-term conversational context plus user-approved long-term information.
8. **Voice output** — concise spoken confirmation/answer through the existing TTS layer.
9. **Permissions** — explicit read/write/sensitive-action boundaries.
10. **Optional web knowledge** — permission-controlled current information/research; never silently enabled.
11. **Proactive intelligence** — useful suggestions based on approved data, without autonomous destructive actions.

## Safety rules

- Never claim an action succeeded until persistence is verified.
- Sensitive/destructive actions require explicit confirmation.
- Never silently escalate permissions.
- Do not store secrets merely because they appear in conversation.
- Keep iamyansi separate from the visual identity of the five cores.
- Keep the agent provider-agnostic so the application is not locked to a third-party AI service.

## Current implementation

`IamyansiAgentCore` provides the first orchestration contract over the existing intent parser and five-core canonical bridge.

## Next implementation slices

- Add explicit tool registry and tool result contracts.
- Add short-term conversation context.
- Add verified read/query tools for each core.
- Add permission policy service.
- Connect agent results to the existing speech/TTS runtime.
- Add optional web research adapter behind permission controls.
- Add tests for action verification, confirmation and context boundaries.
