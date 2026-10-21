# Project instructions — Grab It & Run! / One More Haul

## Read these rules first

Before any project task, read all six files below. They apply to this whole project, not only to the `rules/` folder:

1. `rules/communication.md` — short, beginner-friendly communication in Hebrew for now.
2. `rules/readable-docs.md` — readable documents and clear names.
3. `rules/sdd.md` — approved specifications before plans; explicit permission before coding.
4. `rules/tdd.md` — failing test, smallest passing change, then cleanup.
5. `rules/git.md` — branches, commits, and no pushes.
6. `rules/code-review.md` — code review for code changes before completing a coding task.

Keep the source rules in `rules/`. This root file makes reading them mandatory; the folder alone is not an automatic instruction source. Keep all configuration local to this project. `AGENTS.md` is the only root instruction file; do not create a duplicate `AGENT.md`.

The latest explicit instruction from Adam takes precedence over older project preferences. Communicate with Adam in Hebrew, at least for the current phase. Use short answers. Keep technical terms, identifiers, and product names in English; explain unfamiliar terms in simple Hebrew without replacing the English term with a translation.

## Phase and permission

Adam approved `docs/specs/v1/gameplay.md` on 2026-10-21, including its rules and starting values. He explicitly requested recording approval only and no further progress for now. Project setup rules remain in effect. No game implementation has started or been authorized. Do not prepare implementation plans or continue design work until Adam requests further work.

The process is: specification → Adam approves → implementation plan → Adam explicitly requests coding that feature. Approval of a specification or plan alone is not coding permission. Once a task is authorized, complete its routine reversible steps without repeated confirmation.

Current scope: record the gameplay approval and stop. Further planning, design, and implementation require a new request from Adam. Do not open or operate Studio, start Rojo syncing, install tools, configure connections, change a game, spend money, or publish during this design task.

## Project context

- Platform: Roblox. Mobile and Meta Quest were comparisons, not current targets.
- Adam is a beginner Roblox programmer using a Mac and an existing basic subscription for development help. Keep the project inexpensive and manageable.
- Aim: strong replay appeal, clear progression, enjoyable play with friends, and a plausible income model. Profit and exposure are not guaranteed.
- Repository name: `Grab-It-&-Run!`. Naming candidates discussed: **Grab It & Run!** and **One More Haul**. The final public title and name availability are unconfirmed.
- Leading concept: leave a safe base, collect objects in a warehouse, and return to bank the haul before a closure or hazard. Valuable objects lie farther away. A larger carried stack slows the player, creating the choice to return or collect one more object.
- Proposed failure rule: risk the current unbanked haul, not earlier banked progress. Exact loss, timing, controls, and hazards still need design decisions.
- Proposed progression: carrying capacity, access to deeper areas, and visible cosmetic collections. Friends share the space; solo play must still be considered.
- The approved gameplay behavior is recorded in `docs/specs/v1/gameplay.md`. That document takes precedence over these background summaries. Progression, monetization, and other topics outside its scope remain proposals, not approved requirements.

## Scope and cost

Prefer a compact map, simple geometric assets, few object types, one clear core loop, and built-in platform services. Avoid unnecessary external servers, recurring services, or runtime model calls.

An earlier proposed first release had one warehouse, three risk zones, six collectible types, one closure mechanism, and a few upgrades. This scope is not approved.

Earlier estimates were NIS 300–1,000 for a small Roblox release and 90–150 hours of Adam's involvement with development help for this concept. These exclude external developers and marketing, and are neither spending approval nor guarantees.

Monetization ideas: bag/cart appearances, deposit effects, base decorations, permanent bundles, and convenience features. Products, prices, paid advantages, and ads are undecided. Validate the core loop before expanding scope.

## Tooling and evidence

A read-only check found Roblox Studio 0.743.0.7431133 and its built-in StudioMCP executable installed. No successful connection or game operation has been verified. Recheck the available tools before relying on earlier observations.

Chosen approach for future authorized development: local Luau files, Rojo for syncing them into Studio, and Git for history. Adam reports that Rojo is installed and working; this chat has not verified its connection for this game. Local files are the source of truth for Rojo-managed code: do not edit that code directly in Studio, through MCP, or through Script Sync. MCP is the connection that lets development tools operate Studio. Luau is Roblox's scripting language. Future Studio MCP inspection and testing still require separate authorization and connection verification. Rojo does not imply that every map object or asset is already represented in Git.

Before future implementation, verify the connection on a disposable test place. Test inspection, a block edit, play mode, screenshots, console output, and stopping play. Check multi-player testing separately. This verification is planned, not performed.

Open Cloud, Roblox's service API, may later support publishing automation. Do not request keys for the local prototype or put credentials in project files.

## Docs layout

Use this layout for the authorized design work. Create substantive feature drafts and indexes as needed; do not create placeholder specifications or plans. No implementation plan is authorized before its specification is approved.

- `docs/specs/index.md` — map of all specifications and named later work.
- `docs/specs/v1/index.md` — map of the first version's features.
- `docs/specs/v1/<feature>.md` — one small specification per feature.
- `docs/plans/v1/index.md` — map of the first version's implementation plans.
- `docs/plans/v1/<feature>.md` — one plan for its approved specification, using the same feature name.
- Later versions use `v2`, `v3`, and the same layout.

A feature is either in or out of its specification. Approved specifications contain no unanswered questions. Record later work by name in `docs/specs/index.md`.

Pass only the index and relevant feature documents to a reviewer or delegated task. Delegation must follow the active session's permissions. Adam alone pushes.

## Project skills and hooks

- `.agents/skills/<skill-name>/SKILL.md` holds the fourteen project skills and their bundled references. Read only the skills relevant to the task. Skills do not grant coding, installation, Studio, or publishing permission.
- For substantive Hebrew writing and editing, read `hebrew-content-writer`; for RTL or mixed Hebrew-English display issues, read `hebrew-rtl-best-practices`. Preserve English technical terms and verify the actual rendered direction.
- `hebrew-document-generator` supports Hebrew DOCX, PDF, and PPTX work alongside the corresponding document skill. `hebrew-nlp-toolkit` and `israeli-accessibility-compliance` apply only when NLP or accessibility work is in scope; neither is required for ordinary project prose.
- `.codex/hooks/luau-check.sh` is the original imported hook. It expects Claude-style input and `CLAUDE_PROJECT_DIR`; it is retained for future adaptation, not connected to Codex or Git.
- `.codex/hooks/README.md` records the hook's status. No automatic hooks are enabled. Do not execute it during the current setup task.
- Root `/references/` remains ignored by Git; references bundled inside skills must remain trackable.

## Validation and maintenance

Use primary Roblox documentation to verify changing publishing requirements, fees, discovery, and monetization. Previous research may become stale.

Future code validation must cover collection, returning, banking, failure, saving across rejoining, simultaneous players, touch controls, and purchases where implemented. Follow the test rules, including fresh-player defaults and full-session coverage. Human playtests are still needed to judge clarity, frustration, and replay appeal.

Keep this file current when Adam makes decisions. Distinguish proposals, verified facts, and completed work.

## References

- Studio connection: https://create.roblox.com/docs/studio/mcp
- Script Sync: https://create.roblox.com/docs/scripting/sync
- Discovery: https://create.roblox.com/docs/discovery
- Monetization: https://create.roblox.com/docs/production/monetization
- Publishing: https://create.roblox.com/docs/production/publishing/publish-games-and-places
