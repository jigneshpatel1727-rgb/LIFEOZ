# Yansi Secure Backend Contract

## Purpose

Yansi's Flutter client must never contain an AI-provider secret. The mobile app sends an authenticated, minimal request to a trusted backend; the backend owns provider credentials and policy enforcement.

## Endpoint

`POST /v1/yansi/respond`

## Request

```json
{
  "message": "user question",
  "conversationId": "optional-id",
  "locale": "en-IN",
  "currency": "INR",
  "context": {
    "lifeSnapshot": {},
    "memory": [],
    "webAllowed": false
  }
}
```

## Response

```json
{
  "answer": "Yansi response",
  "action": null,
  "requiresConfirmation": false,
  "sources": [],
  "memoryWrites": []
}
```

## Security rules

1. Require an authenticated user token.
2. Validate the request size and fields on the server.
3. Never accept an AI provider API key from the mobile client.
4. Enforce the user's LifeOS permissions server-side, including web access and memory/voice storage.
5. Do not send private LifeOS records to external providers unless required by the enabled capability and permitted by the user.
6. Sensitive actions must return `requiresConfirmation: true`; the backend must not execute them from a normal conversational request.
7. Log only operational metadata by default; never log raw private conversations or voice transcripts unless the user has explicitly enabled that storage.
8. Apply rate limits and abuse protection per authenticated user.
9. Provider/model selection remains server-side so it can change without shipping a new APK.

## Provider adapter

The backend should expose a provider-neutral adapter such as:

`generate(request, policy) -> YansiResponse`

A provider can then be added through server-side environment configuration without putting credentials in GitHub or the APK.

## Deployment requirement

This document is a contract only. A live provider must be configured in a trusted backend environment before Yansi can perform real remote AI reasoning. No secret is stored in this repository.
