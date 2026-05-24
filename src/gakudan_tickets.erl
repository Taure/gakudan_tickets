-module(gakudan_tickets).
-moduledoc """
Ticket-source behaviour for [gakudan](https://github.com/Taure/gakudan).

A *ticket source* is anything that owns tickets, issues, or work items: a
GitHub repo, a Jira project, a Linear team, your home-grown internal
tracker. Adapter modules implement this behaviour to translate a platform's
native API into a normalised `ticket()` shape that gakudan triage agents
can consume without knowing which platform the ticket came from.

Concrete adapters live in their own libraries so consumers only pull in
what they need:

- `gakudan_tickets_github`
- `gakudan_tickets_jira` (planned)
- `gakudan_tickets_linear` (planned)

## Behaviour callbacks

Implementations must export:

- `fetch/2` - load a single ticket by id.
- `search/2` - find tickets matching a platform-specific query.
- `post_comment/3` - append a comment to a ticket.
- `apply_labels/3` - replace or add labels (adapter chooses semantics).
- `transition/3` - move the ticket to a new status. Status atoms are
  platform-specific; `closed` and `open` are universally meaningful.

## Helpers

The same module exposes `gakudan_tickets:fetch/3` (and the others) so
consumers can write `gakudan_tickets:fetch(Adapter, SourceRef, Id)` instead
of `Adapter:fetch(SourceRef, Id)`. Useful for code that's parametrised on
the adapter module.
""".

-export([fetch/3, search/3, post_comment/4, apply_labels/4, transition/4]).

-export_type([ticket/0, ticket_id/0, source_ref/0, query/0]).

-type ticket_id() :: binary().
-type source_ref() :: term().
-type query() :: term().

-type ticket() :: #{
    id := ticket_id(),
    title := binary(),
    body := binary(),
    author := binary(),
    labels := [binary()],
    created_at := integer(),
    source := atom(),
    raw := map()
}.

-callback fetch(source_ref(), ticket_id()) -> {ok, ticket()} | {error, term()}.
-callback search(source_ref(), query()) -> {ok, [ticket()]} | {error, term()}.
-callback post_comment(source_ref(), ticket_id(), binary()) -> ok | {error, term()}.
-callback apply_labels(source_ref(), ticket_id(), [binary()]) -> ok | {error, term()}.
-callback transition(source_ref(), ticket_id(), atom()) -> ok | {error, term()}.

-doc "Dispatch `fetch/2` to the given adapter module.".
-spec fetch(module(), source_ref(), ticket_id()) -> {ok, ticket()} | {error, term()}.
fetch(Mod, Ref, Id) ->
    Mod:fetch(Ref, Id).

-doc "Dispatch `search/2` to the given adapter module.".
-spec search(module(), source_ref(), query()) -> {ok, [ticket()]} | {error, term()}.
search(Mod, Ref, Query) ->
    Mod:search(Ref, Query).

-doc "Dispatch `post_comment/3` to the given adapter module.".
-spec post_comment(module(), source_ref(), ticket_id(), binary()) -> ok | {error, term()}.
post_comment(Mod, Ref, Id, Body) ->
    Mod:post_comment(Ref, Id, Body).

-doc "Dispatch `apply_labels/3` to the given adapter module.".
-spec apply_labels(module(), source_ref(), ticket_id(), [binary()]) -> ok | {error, term()}.
apply_labels(Mod, Ref, Id, Labels) ->
    Mod:apply_labels(Ref, Id, Labels).

-doc "Dispatch `transition/3` to the given adapter module.".
-spec transition(module(), source_ref(), ticket_id(), atom()) -> ok | {error, term()}.
transition(Mod, Ref, Id, State) ->
    Mod:transition(Ref, Id, State).
