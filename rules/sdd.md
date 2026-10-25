# Spec-driven development

Specs live in `docs/specs/`. Implementation plans live in `docs/plans/`. Both use the folder layout in `AGENTS.md` ("Docs layout"): one folder per version, with an `index.md` map and one small file per feature. An agent gets the index plus only its own feature file.

The order is always: **spec → Adam approves → plan → code.**

- No feature is coded before its spec exists in `docs/specs/` and Adam has
  approved it.
- A spec describes *what* and *why*: screens, behaviour, data, edge cases. Not
  code.
- A plan describes *how*: the steps to build it, in TDD order. One plan file per
  spec, written only after that spec is approved.
- When the code and the spec disagree, the spec is updated first, then the code.
- Specs contain no "TBD" and no open questions. Every question is answered by
  its owner before the spec reaches Adam's gate. If a value can only be set by a
  playtest, the spec still sets a starting value and says what playtest result
  would change it.

## In or out, never "nice to have"

Every feature, story, rule and task is either **in** (it gets built as part of this
spec) or **out** (it is not built in this spec). There is no "nice to have", no
priority levels like P1/P2, no "optional" and no "fallback if it's too hard".

- Something that is out but still needed later goes into a named later spec in
  `docs/specs/index.md`, for example "Launch polish: walking animation".
- If a choice depends on difficulty, the owner decides now which version is built.

## Coding starts only when Adam says so

Approving a spec, or approving a plan, is **not** permission to write code.

The assistant keeps planning — specs, designs, build plans — until Adam says
explicitly: *"let's start coding X."* Then only X is coded, nothing else.

If a plan seems to lead naturally into code, it stops at the plan anyway and
waits.

## Competitive visual standard before and after implementation

Follow the two gates in `research.md`: establish the reference-based visual standard during planning, then verify the implemented game against it before human player tests and the remaining acceptance tests. An approved technical plan or passing code tests is not approval of competitive visual quality. A failed visual gate returns to the relevant specification before a revised implementation plan or code.

## Goal and gameplay continuity gates — Adam's decision, 2026-10-25

- Before presenting a relevant specification for approval and before writing its implementation plan, check the design against `docs/specs/project-goals.md`, not only against its own feature list. Record concrete examples covering the first success, repeated rounds, progression and visible rewards, exhaustion of available content, and what meaningful action remains while a timer or shared round continues. Cover the effect on other players where state is shared. Keep these examples in the owning feature spec and link them from the version index; avoid duplicating rules across documents.
- State what changes for the player over time and why another round is worth attempting. Distinguish difficulty within one attempt from development across attempts, static variety between areas from variety unlocked through progress, and a cosmetic color change from substantial new content. A currency counter or a tier name alone does not establish the goal. This gate does not prescribe levels, a difficulty curve, a button, or any other unapproved solution.
- Give every relevant example an expected outcome and a feasible verification method. An absent answer, a known conflict with the goals, or an unverified mechanism required for the proposed solution blocks progression to an implementation plan. Surface the gap to Adam; do not defer a known design flaw to human playtests or quietly remove the goal from scope.
- After implementation, repeat the goal review and the relevant continuous-session scenarios before handoff or additional player acceptance. Check content exhaustion and the period after reaching the first reward, not only success and failure mechanics. Preserve technical test results separately. A known goal failure returns to the relevant spec even when all implementation tests pass.
- Report implementation conformance, product-goal assessment, and observed human results separately. Do not report independent work as complete or the build as ready for player acceptance while a known design failure remains. Human enjoyment still needs human evidence; a design review cannot certify it.
- The agreed failure record is `docs/research/v1-design-failure-review.md`. These are process checks, not permission to implement improvements or proof that the new checks already work.
