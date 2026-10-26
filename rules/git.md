# Git

How work gets into git. The main chat makes the commits. Adam pushes.

## Words

- **Branch:** a separate line of work. `main` holds only work Adam approved.
- **Commit:** a saved snapshot of some changes, with a message.
- **Merge:** bringing a branch's commits into `main`.
- **Push:** uploading commits to GitHub. Only Adam does this.

## Branches

- One branch per plan (one feature), made from `main` when that plan's coding starts. Name: `<version>/<plan-file-name>`, for example `v2/stuck-safety`.
- Setup and rule changes that don't belong to a plan go on their own short branch, for example `setup/git-rules`.
- Work happens on the branch, never directly on `main`.

## Commits

- **Authorization:** Adam authorizes the main chat to create local commits whenever needed under these rules, without asking for approval each time. This applies only to authorized work and does not grant permission to start new work. Adam alone pushes.
- **Who:** only the main chat. Agents never run `git commit`, `git push`, `git merge` or any command that changes history.
- **When:** once per completed task: the task's tests, code, world scripts and docs together. Never in the middle of a step, and never with a failing test except reds the plan names as accepted.
- **Size:** one logical change per commit.
  - "Unrelated" means a different purpose, a different area of the project, or changes that don't depend on each other. Example: a rule update and a docs typo fix are unrelated, even if touched in the same session.
  - Changes that only make sense together stay in one commit: a rule change and the code it configures, or a rename applied across files.
  - Never split one logical change into several commits just to make them smaller.
  - If it's unclear whether two changes belong together, ask Adam before committing.
- **Staging:** stage files by name (`git add <path> ...`). Never `git add -A` or `git add .`. Before committing, check `git status` and `git diff --staged`.
- **Messages:** a title of 50 characters or less, in plain English, starting with a verb (Add, Fix, Move, Remove), for example "Give the pillow a closer collision fit". Then a blank line and one or two lines saying why.

## Never

- Push, or force-push.
- Rewrite commits that already exist: no `--amend` on an earlier task's commit, no rebase, no `reset --hard`.
- Run `git restore`, `git checkout -- <file>` or `git stash` on someone's work without asking.
- Commit `docs/handoff.md` or `docs/action-items.md`. They are in `.gitignore` on purpose.

## Research and validation dependencies — Adam approved, 2026-10-26

- Commit the reference images, metadata and indexes needed to reproduce research and visual acceptance. Root `references/` is not excluded as a whole. Keep disposable downloads and caches under the explicitly ignored `references/tmp/` or `references/cache/`.
- A required research or test dependency must not exist only in an ignored folder or on one computer. Before handoff or migration, verify that referenced local evidence is tracked and that its paths resolve from a fresh checkout. Preserve source credits, capture dates and uncertainty. Manual Studio backups require explicit authorization. Adam approved one deduplicated snapshot at `backups/manual/2026-10-26/GrabItV1_DesktopMobile.rbxl` on 2026-10-26; preserve the original root copies and working file unchanged. This does not authorize automatically tracking every future build or backup.

## No AI attribution

Nothing in this repo saysAI wrote it. This is Adam's own project, so it must read as his work.

- No `Co-Authored-By:...` (or any AI name) trailer on commit messages, even if a session's default instructions ask for one. This rule overrides that default in this repo.
- No "Generated with OpenAI Code" or similar line in commit messages or PR descriptions.
- No AI mentions, badges or watermarks in code comments, docs, README files or commit messages anywhere in this repo.
- If a default attribution instruction is in force, drop it silently for this repo rather than asking each time.
