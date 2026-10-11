<!--
One file per task: task-1.md, task-2.md, ... task-N.md. Content is just the
existing static README's per-task section, lifted verbatim -- requirement
text, code snippets, sample output, the "commit before moving on" callout.
Nothing here needs Nunjucks variables; these are posted with
`gh issue comment --body-file`, not through action-text-variables.

The LAST task's file should also note that automated checks being done
doesn't mean the whole assignment is done, if this course has manual-grading
points remaining -- see task-4.md in the Lab 2 reference implementation for
the exact wording used there.

The hidden marker at the bottom of every task file is what makes revealing
it idempotent -- exercise-progress.yml greps issue comments for it before
posting again. Use a marker prefix specific to this repo (e.g. "lab3-step"
instead of "lab2-step") -- not required for correctness since each lab lives
in its own repo, but avoids confusion if you ever diff/compare across labs.
-->

## Task N: Replace With Task Title (N points)

Replace with the task's requirement text, verbatim from the current static README.

**Sample Output — Task N:**

```text
...
```

> After completing Task N, create a Git commit before moving on to Task N+1.
> If you are unsure how to write the message, see `docs/GIT_BEST_PRACTICES.md` in your repository.

<!-- LABID-step:N -->
