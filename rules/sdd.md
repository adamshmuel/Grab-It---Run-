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

## Complete specifications at handoff — Adam's decision, 2026-10-25

- A request to write specifications means a complete, coherent deliverable for Adam to review. Resolve authoring questions during the work, before handing over the specification package. Calling incomplete specifications a "draft" does not fulfil that request unless Adam explicitly requested exploratory material.
- First use existing decisions, project evidence and relevant research. Do not ask Adam to repeat an answered question. Use judgment for routine details within the agreed scope; ask Adam about unresolved product decisions before writing dependent rules as settled.
- Ask one decision question at a time, when it arises. Every decision question must include a recommendation and a short explanation of why it fits the project's goals, grounded in checked sources or project evidence under `research.md` and the recommendation rule in `communication.md`. Identify the supporting evidence and material limits. If that basis is missing, investigate first within the authorized scope; do not invent support or recommend an unverified workflow as usable. If verification requires new permission, explain the specific gap and the required action.
- While awaiting an answer, continue only independent authorized work. Do not silently choose a product decision for Adam, infer an answer from silence, or defer it to the final document review.
- At the end of specification authoring, audit project documents and instructions for stale open decisions and vague future-discussion directives, not only the new feature files. The main chat owns this audit. Finish it before reporting the specifications ready: resolve current-scope decisions, update dependent text and coverage links, and remove superseded working notes only after their substance is resolved. Any genuine later work must have a named scope, responsible owner, concrete next action and an observable completion condition; a generic intention to revisit is not an action item. Do not erase historical evidence or turn unperformed tests into successes to pass this check. Renaming a heading or moving a gap to another file does not satisfy it.
- Before handoff, read the entire related specification package, including its index and coverage mapping. Resolve missing values, scope choices, alternative behaviors, dependencies, contradictions, edge cases and decision-critical feasibility gaps. Define starting values and adjustment criteria even where later playtests will tune them. Check meaning, not only keywords.
- Do not deliver unresolved decisions as "השלמה מוצעת לדיון", "הצעה שדורשת את החלטתך", "טרם הוחלט", "ייקבע בהמשך", "TBD", or similar wording inside specifications presented as finished. Renaming the label or moving questions to another document does not close them. Progress reports may state unfinished work clearly; they must not claim the requested definitions are complete or send Adam through multiple files to discover what still needs deciding.
- At handoff Adam reviews the resulting definitions for approval; he is not responsible for finding the author's remaining questions. Distinguish complete authoring from Adam's approval, implementation permission and later empirical validation. Complete specifications do not prove enjoyment, balance or acceptance results that have not been observed.
- Apply this gate to the current V1 improvement package too. It remains unfinished working material until its decisions and required evidence are resolved during authoring; its coverage mapping alone is not completion.

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

Follow the two gates in `research.md`: establish the reference-based visual standard during planning, then verify the implemented game against it before human player tests and the remaining acceptance tests. An approved technical plan or passing code tests is not approval of competitive visual quality. A failed visual gate returns to the relevant specification before a revised implementation plan or code. Adam's standing authorization of 2026-10-26 covers in-scope design/graphics corrections needed to meet the agreed threshold; do not ask him to re-approve each such correction. Keep spec → plan → TDD implementation → visual verification, with the two gate points and art-before-layout order defined in `research.md`. Gameplay/economy and unrelated scope changes are not covered.

## Goal and gameplay continuity gates — Adam's decision, 2026-10-25

- Before presenting a relevant specification for approval and before writing its implementation plan, check the design against `docs/specs/project-goals.md`, not only against its own feature list. Record concrete examples covering the first success, repeated rounds, progression and visible rewards, exhaustion of available content, and what meaningful action remains while a timer or shared round continues. Cover the effect on other players where state is shared. Keep these examples in the owning feature spec and link them from the version index; avoid duplicating rules across documents.
- State what changes for the player over time and why another round is worth attempting. Distinguish difficulty within one attempt from development across attempts, static variety between areas from variety unlocked through progress, and a cosmetic color change from substantial new content. A currency counter or a tier name alone does not establish the goal. This gate does not prescribe levels, a difficulty curve, a button, or any other unapproved solution.
- Give every relevant example an expected outcome and a feasible verification method. An absent answer, a known conflict with the goals, or an unverified mechanism required for the proposed solution blocks progression to an implementation plan. Surface the gap to Adam; do not defer a known design flaw to human playtests or quietly remove the goal from scope.
- After implementation, repeat the goal review and the relevant continuous-session scenarios before handoff or additional player acceptance. Check content exhaustion and the period after reaching the first reward, not only success and failure mechanics. Preserve technical test results separately. A known goal failure returns to the relevant spec even when all implementation tests pass.
- Report implementation conformance, product-goal assessment, and observed human results separately. Do not report independent work as complete or the build as ready for player acceptance while a known design failure remains. Human enjoyment still needs human evidence; a design review cannot certify it.
- The agreed failure record is `docs/research/v1-design-failure-review.md`. These are process checks, not permission to implement improvements or proof that the new checks already work.

## Evidence-based experience acceptance — Adam approved, 2026-10-25

- Follow `rules/game-experience-validation.md` when assessing designs, relevant changes and version readiness. The main chat owns this assessment; it must not transfer detection of known design gaps to Adam or future human testers. This rule does not require delegation.
- Before approving a design for implementation, establish a concrete reference standard for each relevant experience component and its project goal. Record what comparable games actually demonstrate and why it applies here. A principle such as “meaningful progression” without an observable example and a rejection condition is insufficient.
- Design scenarios that can disprove readiness: continue across successive stages, beyond the first reward and through exhaustion of available content. Compare actual outcomes with the defined reference standard. A mechanism's existence or a passing implementation test does not establish that it fulfils its purpose.
- Every “passed” judgment must identify the exact claim, supporting evidence, comparison and reasoning, including evidence that contradicts it. Missing evidence means unverified, never presumed parity with competitors. An unverified readiness requirement or a known goal failure blocks overall readiness; a scoped technical result can still pass independently.
- Distinguish code correctness, structural design assessment, competitive experience assessment and observed human enjoyment. Do not invent human satisfaction, retention or player preference. Equally, do not defer visible design failures to a human playtest.
- Apply the same experience checks during planning and after implementation, before costly downstream acceptance and handoff. A failure returns to the owning specification and Adam's decision, not to a silent change of goals or scope. Focused TDD and feasibility work needed to assess a change remain part of their authorized workflow.
- Check that the method rejects the known V1 failures and does not automatically reject the components Adam chose to retain. Record a document-based calibration as such, not as a new gameplay experiment or proof that every future defect will be detected. Update scenarios when new failures are found.
