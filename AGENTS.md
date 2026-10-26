# Project instructions — Grab It & Run! / One More Haul

## Read these rules first

Before any project task, read all nine files below. They apply to this whole project, not only to the `rules/` folder:

1. `rules/communication.md` — short, beginner-friendly communication in Hebrew for now.
2. `rules/readable-docs.md` — readable documents and clear names.
3. `rules/sdd.md` — approved specifications before plans; explicit permission before coding.
4. `rules/tdd.md` — failing test, smallest passing change, then cleanup.
5. `rules/git.md` — branches, commits, and no pushes.
6. `rules/code-review.md` — code review for code changes before completing a coding task.
7. `rules/research.md` — current sources, practical feasibility checks, and explicit evidence across all agreed capability areas.
8. `rules/studio.md` — verify the exact project target and never operate on other Studio projects or environments.
9. `rules/game-experience-validation.md` — mandatory goal, competitor and gameplay-experience checks before planning and handoff.

Keep the source rules in `rules/`. This root file makes reading them mandatory; the folder alone is not an automatic instruction source. Keep all configuration local to this project. `AGENTS.md` is the only root instruction file; do not create a duplicate `AGENT.md`.

The latest explicit instruction from Adam takes precedence over older project preferences. Communicate with Adam in Hebrew, at least for the current phase. Use short answers. Keep technical terms, identifiers, and product names in English; explain unfamiliar terms in simple Hebrew without replacing the English term with a translation.


## Current phase and permission — 2026-10-26

**LATEST INSTRUCTION — PAUSED:** Adam explicitly requested a smart stop on 2026-10-26 and reiterated stopping while checkpointing. Do not continue implementation or validation until he asks to resume. Read `docs/research/v1-improvement-checkpoint.md` first on resumption: it records local uncommitted work, all 54 preserved final captures, remaining acceptance work, cleanup and protected files. The last committed source is `884284f`; Adam subsequently requested a local safety commit of the equipment-facing fix, its passing test/evidence and this checkpoint; this commit does not resume development or validation. Studio is in Edit with one verified project instance. The owned caffeinate process was sent TERM for the pause; recheck sleep prevention on resume. Earlier resume instructions below are historical authorization and do not override this pause.

Adam approved the complete V1 improvement specifications and explicitly requested feasibility checks followed by coding on 2026-10-25. The revision is implemented in local sources on `codex/v1-improvements`, based on the approved specification commit (the required dependency was not yet on main; main was left untouched). Entry point: `docs/specs/v1/improvements.md`; implementation order: `docs/plans/v1/improvements.md`; current evidence and exact limits: `docs/research/v1-improvement-implementation.md`.

Adam raised the model strength and explicitly resumed work on 2026-10-26. The requested pause before validation is over. Review the implemented revision and verify competitive visuals and experience first, then proceed to the remaining route, multiplayer, device and isolated QA persistence acceptance checks only after that gate passes. Fix implementation defects within the approved scope using TDD. No publishing, installations, spending or player invitations. The historical QA runner requires adaptation to the new rules before it is used; its guard blocks accidental baseline-only acceptance runs. Current validation evidence belongs in `docs/research/v1-improvement-validation.md`; missing evidence is not a pass.

The art/finish portion passed the scoped main-chat comparison recorded in `docs/research/v1-improvement-art-review.md` on 2026-10-26. The full visual gate remains open until detailed cross-device readability, camera/occlusion and input checks pass on the final assets. The approved Scores dialog is implemented; 20 Edit and four client layout suites passed and native desktop/touch open-close, live deposit update and automatic transition closure were observed (not eight-client acceptance). On 2026-10-26 Adam approved the flat wall finish prototype and gave standing authorization to correct in-scope design/graphics defects that fail the agreed threshold, without asking him to approve each visual fix. Update the owning spec and plan before code, use TDD and code review, preserve before/after evidence, and recheck against references. This does not authorize changing gameplay/economy, lowering acceptance, spending, publication, new permissions or unrelated scope.

Adam reiterated that design comparison must happen during planning before the implementation plan, and again FIRST after implementation, before detailed readability, occlusion, overlap or downstream acceptance. Finish the art/finish comparison and resolve known design gaps before detailed UI/device polishing. After a visual change rerun affected presentation checks on the final assets. The previous order was wrong: readability fixes began before the full art comparison. Record that process failure rather than claiming those fixes completed the art gate.

Adam requested local commits for the pending approved work and implementation; do not push. Preserve the untracked `sourcemap.json`, Adam's root manual save `GrabItV1_DesktopMobile.rbxlx.rbxl`, and unmanaged Studio content. Do not rebuild over the saved Studio file to insert sources: Rojo is the source-sync path. Studio was returned to Edit with the same project window after the art captures; verify the current mode before operating it. No delegation is required or authorized here. Sleep/display prevention was enabled at Adam's request and remained active at the pause; record its current state rather than assuming it in a later session. Adam alone pushes.

## Current design and canonical sources

Platform: Roblox; current targets: desktop and landscape mobile. Keep the game manageable and inexpensive for a beginner developing on a Mac. Goals are in `docs/specs/project-goals.md`: a simple, fast, compelling hyper casual experience, quality comparable to relevant Roblox games, reasons to return, maintainable development with income potential, and reusable knowledge for later games. Do not build a general framework in advance or promise profit/exposure.

Use `docs/specs/v1/improvements.md` for the coverage and document ownership map. `carrying-weight.md` owns total weight and slowdown; `stage-progression.md` owns three stages, decreasing time, synchronized transitions, joining/leaving and ranking; `item-catalog.md` owns item data; `stage-content.md` owns environment and variety; `cosmetics.md` owns purchases with earned currency; `controls-feedback.md` owns presentation; `saving.md` owns persistence. `improvement-acceptance.md` owns the revised acceptance evidence. All are under `docs/specs/v1/`.

Important decisions not to re-ask: same stage capacity for new/veteran players; 30 regulars in two columns of 15, five types per stage; additional personal special item only in stage 3, far-end center on a dedicated display; no replacement of regulars. Special weight/reward are hidden before banking, including aggregate UI leaks. Shelves are removed from the design and their spatial test was canceled; the special stand is the explicit exception. Environment varies through visible flat surface motifs without blocking sightlines.

Solo and multiplayer advance at expiry without full clear or forced retry. Solo can advance early after banking everything; shared early transition requires every current ready player, including Unranked joiners, to finish. Attempt mode is fixed for the stage, recounted at the next stage. Stage ranking now prioritizes deposited reward, superseding item-percentage priority; placement points determine match winners separately from spendable Coins. Ties share places/points/wins. The live board is on an inner front wall and results also appear on screen. Cosmetics are bought with earned Coins and confer no stat advantage; purchasing supersedes automatic cosmetic unlocks.

Latest loss decision: unbanked collected items return to their original personal positions after cargo loss during an active stage; banked items do not return. No new collection starts in an expired stage. Keep transient same-server duplicate-reward protection distinct from cloud stage checkpoints. Cloud saving keeps currency, owned designs and choice, not stage/time/cargo. Rejoin into a server with any active participant joins its current state without resetting it, including a stage that began solo; a previously empty server starts a new match.

No real-money/Robux purchases, public release, PvP, theft, trading, new maps, saved capacity upgrades or global leaderboard are authorized by this specification task. Later scopes and ownership are in `docs/specs/index.md`.

## Historical implementation and evidence

Gameplay was approved on 2026-10-21; V1 specifications and implementation were authorized on 2026-10-22. The baseline was built and tested, then Adam's manual review on 2026-10-25 identified goal failures: no meaningful difficulty progression, insufficient evolving content/rewards, and dead time after content exhaustion. Preserve `docs/research/v1-design-failure-review.md` and prior test evidence. Do not call V1 accepted or technical passes proof of enjoyment.

The revised visual review on 2026-10-24 passed only its recorded scenes and limits, before the later goal failure. Twelve suites, two/eight-client sessions, local performance and both phone touch profiles were tested within the limits in `docs/research/v1-validation.md`. Isolated QA cloud saving/rejoin was verified in this game's approved environment. These results do not cover the new weight, stages, models, leaderboard or purchases. See `docs/research/v1-acceptance-status.md` and `docs/research/project-readiness.md` for evidence; update readiness only when actual evidence changes.

The pause before post-implementation validation was honored and Adam resumed that work on 2026-10-26. Adam will manually inspect after independent authorized verification; later human testing requires his coordination and verified access, not assumed feasibility.

## Tooling and Studio protection

Follow the mandatory Rojo start/stop lifecycle in `rules/studio.md`: shut down this project’s Rojo server at every pause or end of work, verify shutdown, and recheck the correct server and actual Studio sync at every authorized resumption before code or tests. Documentation or commits during a pause do not resume syncing.

Local Luau sources are the source of truth for Rojo-managed code. Do not edit that code through Studio, MCP or Script Sync. MCP is the Studio connection; Rojo syncs local sources. Do not assume every map object is represented in Git.

For future authorized operations, verify the exact target under `rules/studio.md` before each mutation/run group and pass explicit studio_id. Approved historical identity: place `106986292768692`, universe `10772701508`, expected GrabIt hierarchy. Recheck it; no other open Place1/Baseplate or project is a fallback. Use one project Studio window; temporary clients/files only when necessary, identify them and clean them afterward without losing unsaved work. Do not request sensitive computer-control permissions when existing dedicated tools suffice.

Working file: `build/GrabItV1_DesktopMobile.rbxlx`, tracked by Adam's specific request on 2026-10-24. Preserve its unmanaged content rather than rebuilding over it routinely. The root manual save is a separate protected backup. Other builds/locks remain ignored. `default.project.json` includes Studio-only QA; `release.project.json` excludes tests and QA. Historical Rojo port: localhost:34872, not proof a server is running now.

Studio API services were enabled with Adam's explicit approval for this game only. Ordinary Studio persistence is memory-only; opt-in isolated QA used a separate store and per-run keys, subsequently cleaned. Never infer permission to alter production data or publish. Open Cloud keys are not needed for local prototyping; do not request or store credentials.

Verified environment history is in `docs/environment-check.md`. `rokit.toml` pins cached Rojo 7.7.1, StyLua 2.5.2 and Selene 0.32.0; assertions support local tests. Installed and past-working tools are not proof of current connection. No installation was required for that check.

## Docs layout and review

- `docs/specs/index.md`: goals, version entry points and named later work.
- `docs/specs/v1/index.md`: baseline and current revision map.
- `docs/specs/v1/<feature>.md`: complete feature behavior, starting values and edge cases.
- `docs/plans/v1/index.md` and `<feature>.md`: plans only after approval and a request to proceed; match feature names.
- Later versions use the same layout under `v2`, `v3`.

One owner per rule; link to canonical data rather than duplicating it. Preserve historical approvals/results clearly as history. A spec is complete before Adam reviews it: no unresolved choices hidden in wording. For a review pass only the index and relevant feature documents. Code changes require TDD and code review; doc-only work requires clarity, link, consistency and actual RTL rendering checks. Main-chat review is the default, not mandatory subagent approval.

## Skills and hooks

`.agents/skills/<skill-name>/SKILL.md` holds fourteen project skills and bundled references. Read relevant skills only; they grant no additional permission. Use project `hebrew-content-writer` for substantial Hebrew and `hebrew-rtl-best-practices` for direction/mixed text. Keep clean Markdown and separate RTL HTML reading views; inspect the actual rendered view. Keep English technical terms.

`hebrew-document-generator` is for DOCX/PDF/PPTX; NLP and accessibility skills apply only when those topics are in scope. `.codex/hooks/luau-check.sh` is an imported Claude-style hook retained for future adaptation, not connected or enabled; see its README and do not execute it here. Root `/references/` remains ignored; skill-bundled references must stay trackable. Never replace Roblox-native assets and actual Studio evidence with generated illustrations for this project.

## Maintenance

Research current technical/platform facts and recommendation feasibility before relying on them, across every capability area Adam requested. Use primary technical sources, multiple appropriate research sources for product/competitor work, and label inference, dates and limits. Do not infer revenues from visits or images, or game progression from a still frame.

Follow both competitive/experience gates before planning and after implementation. Known goal failures or missing required evidence block readiness even with passing tests. Preserve human results separately; no claim of enjoyment, long-term retention or profit without relevant observations. Update this file and affected canonical documents when decisions change; avoid accumulating superseded chronological instructions.
