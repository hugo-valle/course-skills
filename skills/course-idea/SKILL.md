---
name: course-idea
description: Capture a loose course idea as a GitHub issue labelled `idea` for future exploring
argument-hint: <the idea, in your own words>
allowed-tools: Bash(gh issue create:*), Bash(gh label create:*), Bash(gh label list:*), Bash(git remote:*), Read, Grep, Glob
disable-model-invocation: true
---

Turn this loose idea into a GitHub issue in the current repo, so it can be explored later:

$ARGUMENTS

If no idea was given above, ask for it in one line and stop.

## Steps

1. **Understand it.** If the repo has `COURSE.md`, skim it (and the `## Modules` table in `README.md`) only far enough to name the modules, labs or CLOs the idea touches. Don't research the idea itself. Capturing it is the whole job.
2. **Ask at most one question**, and only if the idea is too vague to write a meaningful title. Otherwise fill gaps with "unknown" and list them under Open questions.
3. **Pick one area:** `course-layout`, `lab`, `presentation`, `technology`, `assessment` or `other`.
4. **Draft the issue** and show it to me in chat:
   - Title: `Idea: <short imperative summary>`
   - Body:
     ```markdown
     ## Idea
     <the idea, cleaned up but faithful to my words. Don't add scope.>

     ## Why
     <the motivation I gave, or "unknown">

     ## Area
     <area> · touches: <modules / labs / CLOs, or "unknown">

     ## Open questions
     - <what would need to be answered before this becomes real work>

     ## Raw note
     > <my original text, verbatim>
     ```
5. **Wait for my OK**, then make sure the labels exist (`--force` is idempotent) and create the issue:
   ```bash
   gh label create idea --color C5DEF5 --description "Loose idea to explore later; not committed work" --force
   gh label create needs-triage --color FBCA04 --description "Maintainer needs to evaluate this issue" --force
   gh issue create --title "Idea: ..." --label idea --label needs-triage --body "$(cat <<'EOF'
   ...
   EOF
   )"
   ```
6. Reply with the issue URL in one line. No branch, no commit: an idea isn't work yet. When it's promoted, the instructor swaps `idea` for a real label (`course-design`, `enhancement`, `module-readiness`) and follows `contributing-workflow`.
