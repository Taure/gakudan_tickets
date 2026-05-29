# AGENTS.md

Working agreement for agents and contributors on **gakudan_tickets** - a
ticket-source behaviour for gakudan-based triage (GitHub / Jira / Linear).

## Ecosystem

A gakudan sister library in a BEAM-native multi-agent stack (all under
https://github.com/Taure):

- **[gakudan](https://github.com/Taure/gakudan)** - agent orchestration runtime
  (this library extends it).
- **[saiten](https://github.com/Taure/saiten)** - runtime-agnostic eval/scoring
  + CI gate.
- **[madoguchi](https://github.com/Taure/madoguchi)** - MCP *server* framework.
- **[sekisho](https://github.com/Taure/sekisho)** - LLM gateway / control plane.

Other gakudan sisters: gakudan_metrics, gakudan_otel, gakudan_liveboard.

**This repo** defines the `ticket-source` behaviour that feeds tickets into
gakudan triage runs. Provider adapters live in their own repos -
**[gakudan_tickets_github](https://github.com/Taure/gakudan_tickets_github)** is
the GitHub Issues adapter.

## Conventions

- OTP 29+. The `~"..."` sigil, never `<<"...">>`. No `lists:foldl/foldr`.
- JSON via the OTP `json` module. `?LOG_*` macros with `#{...}` map reports.
- Docs: OTP `-moduledoc` / `-doc`. `{vsn, "git"}` - version derives from git tags.
- Default to zero comments; comment only non-obvious *why*.

## Commands

```bash
rebar3 compile
rebar3 eunit
rebar3 fmt          # CI runs fmt --check
rebar3 xref
rebar3 dialyzer
rebar3 ex_doc
```

## Git and PRs

Conventional commits. Always open a PR - never push to `main`. Every merge to
`main` tags a release.
