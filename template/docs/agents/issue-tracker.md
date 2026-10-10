# Issue tracker: GitHub

Issues and specs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`
- **Doing the work**: follow the `contributing-workflow` skill. Each issue gets a branch named `<issue#>-short-description` and a PR whose body says `Closes #N`, using `.github/pull_request_template.md`. The commit hooks reject commits on `main`.

Infer the repo from `git remote -v`; `gh` does this automatically when run inside a clone.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; `/triage` reads this flag.)_

When set to `yes`, PRs run through the same labels and states as issues, using the `gh pr` equivalents:

- **Read a PR**: `gh pr view <number> --comments` and `gh pr diff <number>` for the diff.
- **List external PRs for triage**: `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments` then keep only `authorAssociation` of `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR`, or `NONE` (drop `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Comment / label / close**: `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

GitHub shares one number space across issues and PRs, so a bare `#42` may be either: resolve with `gh pr view 42` and fall back to `gh issue view 42`.

## Labels this repo already uses

Besides the triage labels in `triage-labels.md`:

- `module-readiness`: work on one module's content (one per module each semester, plus review findings for a module).
- `semester-prep` and `course-level`: semester setup, created by `./scripts/new_semester.sh "<Term YYYY>"`.
- `course-design`: one proposal from a `/course-design` review (see "Design reviews").
- `documentation` and `enhancement`: content fixes and tooling/skill changes.

## Skills that stop at the working tree

`/review-module`, `/add-images` and `/slide-prep` never branch, commit or open PRs. They stop at the working tree, and the work then goes through the issue → branch → PR flow above.

- **`/review-module NN` findings not applied in the session**: with the user's OK, publish them as one issue titled `Module N content review findings`. Label it `documentation` and `module-readiness`, and add the triage label that fits (`ready-for-agent` when every fix is fully specified). The body lists the findings in the skill's report shape, one per item: severity, `path:line`, problem and fix.
- **`/add-images NN`**: open the issue before drawing (for example "Add Module N lecture figures"). Note edits that resolve discrepancies go in the same PR as the figures.
- **`/slide-prep NN`**: open a `module-readiness` issue before generating (for example "Generate Module N SlideKraft slides file"). The PR commits `moduleNN_slides.md`, not the SlideKraft export or the `.slides` file. Flagged blocks the user does not shorten in the same PR, and Knowledge Checks the skill could not place, are listed in that issue.

## Design reviews

`/course-design` publishes a design review only after the instructor approves proposals.

- **Umbrella**: one issue per review, labelled `course-level`, titled `Design review <Term YYYY>`. The body lists the children as a task list (`- [ ] #N title`) and holds the CLO trace and the workload table.
- **Child**: one issue per approved proposal, labelled `course-design` plus a status label. The body is the filled `proposal-template.md`. Link it to the umbrella as a GitHub sub-issue: `gh api --method POST repos/<owner>/<repo>/issues/<umbrella>/sub_issues -F sub_issue_id=<child-db-id>` (the child's database id: `gh api repos/<owner>/<repo>/issues/<child> --jq .id`; the umbrella is addressed by its issue number). Where sub-issues are unavailable, put `Part of #<umbrella>` at the top of the child body.
- **Status**: `needs-triage` is proposed, `ready-for-agent` or `ready-for-human` is approved, and a closing PR is implemented. Structural (`L`) proposals are never `ready-for-agent`.
- **Ordering**: native blocked-by edges, added as in "Wayfinding operations" (the Blocking bullet).

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: a single issue labelled `wayfinder:map`, holding the Notes / Decisions-so-far / Fog body. `gh issue create --label wayfinder:map`.
- **Child ticket**: an issue linked to the map as a GitHub sub-issue (`gh api` on the sub-issues endpoint). Where sub-issues aren't enabled, add the child to a task list in the map body and put `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Once claimed, the ticket is assigned to the driving dev.
- **Blocking**: GitHub's **native issue dependencies**, the canonical, UI-visible representation. Add an edge with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric **database id** (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _not_ the `#number` or `node_id`). GitHub reports `issue_dependencies_summary.blocked_by` (open blockers only, the live gate). Where dependencies aren't available, fall back to a `Blocked by: #<n>, #<n>` line at the top of the child body. A ticket is unblocked when every blocker is closed.
- **Frontier query**: list the map's open children (`gh issue list --state open`, scoped to the map's sub-issues / task list), drop any with an open blocker (`issue_dependencies_summary.blocked_by > 0`, or an open issue in the `Blocked by` line) or an assignee; first in map order wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, the session's first write.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer (gist + link) to the map's Decisions-so-far.
