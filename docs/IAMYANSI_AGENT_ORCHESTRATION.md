# iamyansi Agent Orchestration

## Execution lifecycle

1. Receive user input from the existing voice/text layer.
2. Convert input into a structured `IamyansiIntent`.
3. Reject unknown requests safely and ask for clarification.
4. Route sensitive actions to explicit confirmation.
5. Check normal write permission.
6. Execute through the canonical five-core bridge.
7. Read the target core back to verify persistence.
8. Record a bounded conversational memory event.
9. Return a concise result suitable for voice output.

## Core mapping

- expense/income -> Expense
- task/diary -> Productivity
- reminder -> Calendar
- household -> Household
- goal -> Goals

## Non-negotiable rules

- iamyansi is not a sixth core.
- The five cores remain the canonical structured data domains.
- The orchestrator cannot silently grant itself permissions.
- Sensitive operations require explicit confirmation.
- A successful response is not emitted as a completed action until persistence can be verified.
- Long-term user data is not duplicated into conversational memory.
- Any future language-model provider is replaceable behind the intent boundary.
