# Project instructions — Grab It & Run! / One More Haul

## Read these rules first

Before any project task, read all eight files below. They apply to this whole project, not only to the `rules/` folder:

1. `rules/communication.md` — short, beginner-friendly communication in Hebrew for now.
2. `rules/readable-docs.md` — readable documents and clear names.
3. `rules/sdd.md` — approved specifications before plans; explicit permission before coding.
4. `rules/tdd.md` — failing test, smallest passing change, then cleanup.
5. `rules/git.md` — branches, commits, and no pushes.
6. `rules/code-review.md` — code review for code changes before completing a coding task.
7. `rules/research.md` — current sources, practical feasibility checks, and explicit evidence across all agreed capability areas.
8. `rules/studio.md` — verify the exact project target and never operate on other Studio projects or environments.

Keep the source rules in `rules/`. This root file makes reading them mandatory; the folder alone is not an automatic instruction source. Keep all configuration local to this project. `AGENTS.md` is the only root instruction file; do not create a duplicate `AGENT.md`.

The latest explicit instruction from Adam takes precedence over older project preferences. Communicate with Adam in Hebrew, at least for the current phase. Use short answers. Keep technical terms, identifiers, and product names in English; explain unfamiliar terms in simple Hebrew without replacing the English term with a translation.

## Phase and permission

On 2026-10-22 Adam approved the V1 design and explicitly requested building the game. This authorizes V1 implementation plans, code, and routine local Studio testing on this project's verified file only, including desktop and mobile. Plans are in `docs/plans/v1/`. Initial implementation exists in `src/`; evidence and unresolved acceptance gaps are recorded in `docs/research/v1-implementation.md`. V1 is not yet accepted.

On 2026-10-23 Adam requested continuing through all remaining V1 tasks without routine stops and authorized keeping the computer awake while working. Complete all feasible authorized implementation and verification work; report human playtests or other concrete dependencies accurately instead of claiming full acceptance. Temporary extra Studio instances are allowed only where multiplayer testing requires them, under `rules/studio.md`.

The process remains specification → Adam approves → implementation plan → Adam explicitly requests coding. Changes to specifications must precede changed behavior. Adam additionally required acceptance checks against project goals, the overall spec index, research-based graphics, all three selected reference games, and player preference. The new numerical preference threshold is a proposal awaiting approval before human testing.

On 2026-10-23 Adam required competitive visual review twice: during planning to define a concrete, feasible quality standard, and after implementation before human playtests and the remaining acceptance tests. The earlier V1 failed on 2026-10-23: insufficient color and shape variety and overly simple objects. Adam clarified that different sizes and shapes are a visual change; do not change carrying rules or slowdown by item value. A concrete replacement direction is drafted in `docs/specs/v1/visual-direction.md`, and Adam explicitly approved the changes and requested continuing implementation on 2026-10-23. Implement under the updated warehouse plan; keep one Studio instance and unchanged carrying mechanics. Adam rejected spending effort on illustrative images for this workflow: prefer reusable Roblox-native models shown in Studio, not SVG or image-generation mockups that cannot be used as the game assets. During that failed visual phase, downstream acceptance was paused until the revised visual gate passed. See `rules/research.md` and `docs/specs/v1/visual-quality.md`.

On 2026-10-24 Adam explicitly requested keeping the computer awake and continuing all feasible V1 work without asking him to inspect an unfinished build. Perform the visual gate review against the references in this chat and fix gaps before proceeding to downstream verification. Do not request intermediate user QA. Preserve the acceptance requirements: human observations and real cloud persistence cannot be invented or replaced with simulated results. Report any remaining external dependency accurately after completing independent work.

On 2026-10-24 the revised visual gate passed the main-chat review against all three references in the documented scenes. The required eight-player 600-second performance window passed at 1280×720 and QualityLevel5 on the preselected Player8 client. All eleven suites and seven leave-balance checks passed. A fresh phone session using native simulated touch completed deposit, closure loss, next round, full cargo and Copper unlock at 31 coins. Independent two-contact movement/collection, real cloud persistence and human playtests remain unverified. Current acceptance status is in `docs/research/v1-acceptance-status.md`. Do not request intermediate user QA or describe V1 as accepted.

No publishing, paid services, security-setting changes, or pushes are authorized. Prefer one verified Studio instance with Rojo and MCP. Do not access or operate unrelated places, including open generic Place1 windows. Follow `rules/studio.md` and the narrow-permission rules in `rules/communication.md`.

## Project context

- Platform: Roblox. On 2026-10-22 Adam required V1 acceptance checks on desktop and mobile, including Studio device/touch simulation. Two phone profiles and one simulated collection/deposit path were exercised locally; full touch and mobile acceptance remain unverified. Meta Quest is not a current target.
- Adam is a beginner Roblox programmer using a Mac and an existing basic subscription for development help. Keep the project inexpensive and manageable.
- Agreed project goals are recorded in `docs/specs/project-goals.md`: a simple, fast, compelling Roblox hyper casual game; quality comparable to similar Roblox games; lasting reasons to return; manageable development and maintenance with income potential; and preserving knowledge and reusable components for future games of the same kind. Keep this game's design focused; do not build a general framework for a series in advance. These are goals, not numeric targets or guarantees of profit or exposure.
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

On 2026-10-24 Adam requested including his locally saved environment in a commit. Track the single working file `build/GrabItV1_DesktopMobile.rbxlx`; other build outputs and lock files remain ignored. Preserve his older root backup. Adam also reports saving this game to Roblox. The new Studio connection was verified read-only as place 106986292768692, universe 10772701508, with the expected GrabIt hierarchy. Authorized work continues in that verified project only; cloud saving has not yet been validated. Adam will perform his manual check after independent work is finished.

Current implementation: `default.project.json` maps the game and Studio-only QA templates; `release.project.json` excludes QA and tests. Rojo serves the verified project on localhost:34872. The working file is `build/GrabItV1_DesktopMobile.rbxlx`, updated on 2026-10-24 from current managed sources while preserving unmanaged Workspace and Lighting content. The root manual save remains unchanged. Eleven suites, two/eight-client sessions and the exact local performance target have passed within documented limits. Temporary multiplayer instances were closed and one working Studio was verified afterward. Graphics quality was restored to Automatic and device simulation stopped. Studio persistence remains explicitly memory-only. Cloud persistence, independent two-contact collection and human acceptance remain open; use `docs/research/v1-acceptance-status.md` and `docs/research/v1-validation.md` for evidence. Historical environment observations below do not supersede these results.


The capability map in `docs/research/project-readiness.md` records Adam's six requested knowledge areas and four agreed additions, with sources, demonstrated capabilities, and remaining gaps. Update the relevant entry when new evidence is collected; the document is not an implementation plan or proof of overall game readiness.

Environment verification on 2026-10-22 found Roblox Studio 0.744.0.7441077 and confirmed the native Studio MCP connection in this chat. On a new unpublished Baseplate named Place1, hierarchy inspection, temporary block creation, screenshot capture, play start/stop, Server and Client execution, replication, and console reads succeeded. The temporary block was removed and Studio returned to Edit. Details and remaining gaps are in `docs/environment-check.md`. No game implementation was started.

Chosen approach for future authorized development: local Luau files, Rojo for syncing them into Studio, and Git for history. Rojo 7.7.1 live sync was verified from local files into the disposable Studio place. The reusable test project is `tools/environment-check/check.project.json`; the gameplay project now uses `default.project.json`. Local files are the source of truth for Rojo-managed code: do not edit that code directly in Studio, through MCP, or through Script Sync. MCP is the connection that lets development tools operate Studio. Luau is Roblox's scripting language. The current Studio MCP environment check was authorized by Adam; future operations must remain within the task he authorizes. Rojo does not imply that every map object or asset is already represented in Git.

Basic environment verification is complete: Git, Rojo build and live sync, Studio MCP, a failing-then-passing assertion test in Server and Client, StyLua, and Selene were exercised. Project `rokit.toml` pins cached Rojo 7.7.1, StyLua 2.5.2, and Selene 0.32.0; normal commands work. Selene uses the local pinned `roblox.yml` copied from existing cached definitions. The environment smoke test uses built-in Luau assertions and needs no external test package. No new tools were installed. Multi-player testing, touch controls, saving, purchases, and gameplay tests remain feature-specific work, not completed by this environment check.

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
