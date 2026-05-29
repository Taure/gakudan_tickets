# gakudan_tickets

[![CI](https://github.com/Taure/gakudan_tickets/actions/workflows/ci.yml/badge.svg)](https://github.com/Taure/gakudan_tickets/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Taure/gakudan_tickets)](LICENSE)
[![Erlang](https://img.shields.io/badge/erlang-29%2B-blue)](.tool-versions)

Ticket-source behaviour for [gakudan](https://github.com/Taure/gakudan).

Defines a normalised `ticket()` shape and a `gakudan_tickets` behaviour so
that gakudan triage agents can read from and write back to GitHub Issues,
Jira, Linear, or anything else without knowing which platform the ticket
came from.

## The contract

```erlang
-callback fetch(source_ref(), ticket_id()) -> {ok, ticket()} | {error, term()}.
-callback search(source_ref(), query()) -> {ok, [ticket()]} | {error, term()}.
-callback post_comment(source_ref(), ticket_id(), binary()) -> ok | {error, term()}.
-callback apply_labels(source_ref(), ticket_id(), [binary()]) -> ok | {error, term()}.
-callback transition(source_ref(), ticket_id(), atom()) -> ok | {error, term()}.
```

And the normalised ticket:

```erlang
-type ticket() :: #{
    id := binary(),
    title := binary(),
    body := binary(),
    author := binary(),
    labels := [binary()],
    created_at := integer(),
    source := atom(),     %% github | jira | linear | ...
    raw := map()          %% platform-specific original payload
}.
```

## Adapters

| Adapter | Status |
| --- | --- |
| [`gakudan_tickets_github`](https://github.com/Taure/gakudan_tickets_github) | v0.1 |
| `gakudan_tickets_linear` | planned |
| `gakudan_tickets_jira` | planned |

Each adapter is a separate library. Depend on whichever ones you need:

```erlang
{deps, [
    {gakudan_tickets, "0.1"},
    {gakudan_tickets_github, "0.1"}
]}.
```

## Writing your own adapter

Implement the five callbacks above against your platform. The expected
shape is documented in
[`docs/architecture.md`](docs/architecture.md). The `raw` field on each
returned ticket should hold the platform's native payload as a map, so
agents that need to drop down to platform-specific data have an escape
hatch.

## License

MIT.
