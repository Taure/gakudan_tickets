# Architecture

`gakudan_tickets` is a single-behaviour library. It owns no novel logic, no
processes, no supervision tree. Its job is to define a normalised
`ticket()` shape and a `gakudan_tickets` behaviour callback set that
platform-specific adapters implement.

```
your triage app
    |
    | calls gakudan_tickets:fetch(Mod, Ref, Id)
    v
gakudan_tickets:fetch/3
    |
    | dispatches to Mod:fetch(Ref, Id)
    v
gakudan_tickets_github      gakudan_tickets_jira      gakudan_tickets_linear
    (HTTP REST)                   (REST + JQL)             (GraphQL)
```

## Why split it this way

- **Reusability.** Consumers that only need GitHub don't pay for Jira's
  request/response complexity, and vice versa.
- **Auth isolation.** Each adapter owns its own credential model
  (PAT / OAuth / API token / GraphQL key).
- **Independent versioning.** The adapters can ship at different speeds
  without forcing a coordinated release across all three.
- **Stable API for agents.** Agents written against the normalised
  `ticket()` shape don't care which adapter produced it. Add a new
  platform later by writing one adapter module.

## What this library is not

- Not an agent runtime. That's [gakudan](https://github.com/Taure/gakudan).
- Not a webhook receiver. Adapters that need webhook parsing expose their
  own helpers; this library is purely the ticket-source contract.
- Not an opinion about query DSLs. The `query()` type is `term()`;
  adapters choose what makes sense for their platform (GitHub search
  syntax binary, JQL string, Linear GraphQL filter map).
