---
name: review-module
description: Review one module's lecture notes, quizzes, hands-on exercises and discussion with three parallel read-only reviewer agents (Accuracy, Style, Alignment) and report ranked findings that cite the course's sources by name and page. Use when asked to review, proofread, audit or quality-check a module's course content.
---

# Review Module

Review the content of one module, `moduleNN`, and report findings. The unit of work is one module. Reviewers run as isolated, read-only agents so none is biased by another or by whoever wrote the content.

Invocation: `/review-module NN [--only <artifact type>] [--reviewer accuracy|style|alignment]`

Course details come from `COURSE.md` at the repo root: "Module layout" (artifact table, modules with no content, rebuild command), "Sources" (manifest, course edition, citation form), "Course style rules", "Syllabus" and "Pointers" (glossary, tracker). If `COURSE.md` is missing, stop and suggest `/course-design`, which drafts it.

Reference files in `reference/` (relative to this skill; `<skill>` below is the base directory shown when the skill loads, normally `~/.claude/skills/review-module`):

- `style-rubric.md`: the generic style rules (N, Q, E, D).
- `extract-sources.sh`: builds the source cache from the manifest. `test_extract_sources.sh` is its self-test.

The reviewers are the agents `module-accuracy-reviewer`, `module-style-reviewer` and `module-alignment-reviewer`. They have only read and search tools.

## Rules

- **Review first, edit later.** Never edit anything until the user approves specific findings (Phase 4).
- Only edit files that match a "Source files" pattern in the artifact table. Generated files (the "Generated files" column) are written only by the rebuild command (Phase 4), never by hand. Report anything else instead of editing it.
- Never branch, commit or open PRs. Stop at the working tree (see Done).
- Findings live in chat only. Do not save reports into the repo. The only exception: with the user's OK, findings left unapplied may be published as an issue (see Done).
- Never quote a source at length in findings: a short phrase and a section or page reference is enough. Sources are copyrighted and their folder is git-ignored; never stage it.
- Every number, name and claim in a finding must trace to a file and line, or to a source by name and page. Never invent values. Line numbers come from `grep -n` or `cat -n`, never from estimation; spot-check a few in the merged report before presenting it.
- Source claims that cannot be located are tagged `unverified against <source names>`. Never "correct" them.
- **Source conflicts:** if a note disagrees with a source, do not pick a side silently. Ask the user with `AskUserQuestion`, one question per conflict, quoting both versions with file and line (and source name and page) and offering each resolution as an option (recommended first).

## Phase 1: Resolve the module

1. Parse `NN` and zero-pad it (`9` → `09`). If `COURSE.md` lists `NN` among the modules with no content (exam weeks), refuse and say so. If the module's notes folder does not exist, stop and say so.
2. Collect the artifact set: each artifact type in the "Module layout" table whose root is a per-module folder (`moduleNN`), with its source files. Leave out generated files. A missing artifact type is a coverage gap in the report, not an error. Apply `--only` to this set; reject a flag combination that selects nothing (report the gap and stop).
3. Staleness check (no reviewer needed): for each source file with a generated sibling of the same stem (for example a quiz `.md` and its `.zip`), compare modification times with `stat`. Mtimes are unreliable right after a `git checkout` or clone; say so in the report when the gap is under a minute. Record each source whose generated file is older by a minute or more as a rebuild target for Phase 4; a smaller gap is checkout noise.
4. Sources: unless only the Style reviewer is selected, run `<skill>/reference/extract-sources.sh` from the repo root. If it exits non-zero, stop and show its message. Read the manifest it names for each source's `id` (its cache folder under `instructor_material/.source-cache/`) and `name` (how findings cite it).
5. Read the glossary named in "Pointers", if any, and the "Course style rules" section.

## Phase 2: Dispatch reviewers

Launch the selected reviewer agents **in one message, in parallel**, by name (`subagent_type`). Each prompt contains:

- the module number and the artifact file list (absolute paths) from Phase 1, labelled by artifact type
- the repo root as the working directory, so relative paths resolve
- Accuracy and Alignment: the source cache path, each source's `id`, `name` and PDF path, and the course edition and citation form from "Sources"
- Style: the absolute path of `<skill>/reference/style-rubric.md` and the "Course style rules" section, pasted in
- Alignment: the syllabus path and the rubric path (it reads only rules Q7 and Q10)
- Style and Alignment: the glossary path
- the finding shape and severity definitions below, pasted in, so all reviewers grade alike
- for artifact types that are absent, a line saying so; reviewers do not report absences, the orchestrator does

Each reviewer returns findings in this exact shape, one per finding:

```
- severity: Blocker | Major | Minor
  artifact: <artifact type>
  where: path:line
  quote: "<verbatim text, 25 words max>"
  problem: <one sentence>
  fix: <suggested replacement or action>
  evidence: <computation, other file:line, rule ID, or source name and page; or "unverified against <source names>">
  conflict: yes | no   # yes = note disagrees with a source
```

Severity:
- **Blocker:** factually wrong, a wrong answer key, an incorrect solution, or a quiz that will not import.
- **Major:** misalignment, ambiguity, an undefined term used in an assessment, a missing section, a citation that sends students to the wrong place.
- **Minor:** style, formatting, wording.

## Phase 3: Merge and report

1. Merge the findings. Treat two findings as duplicates when they point at the same file and nearby lines (or the same claim in different files) and describe the same underlying problem, even if worded differently. Keep the highest severity and name every reviewer that raised it.
2. Edition label: the Alignment reviewer owns the finding "a citation names an edition other than the course edition". Collapse it to one Major finding per distinct citation form, not one per occurrence, and ask about it once.
3. For each remaining `conflict: yes` finding, ask the user with `AskUserQuestion` (see Rules) before listing it: one question per conflict, up to four per call. If there are more than eight conflicts, ask about the Blocker and Major ones first and list the rest as unresolved.
4. Present the report in chat:
   - Summary table: severity × reviewer counts.
   - Findings grouped by artifact type, then Blocker, Major, Minor. Number them `F1`, `F2`, …
   - Coverage gaps (missing artifact types, outcomes without questions).
   - Stale generated files from Phase 1 (rebuilt in Phase 4 unless Phase 4 is declined).

## Phase 4: Apply (only after approval)

1. Ask which findings to apply with `AskUserQuestion` (multi-select, Blockers first; batches of four). Offer "none" as an option.
2. Edit only the approved findings, only in source files.
3. When a term's usage is settled, add or update its entry in the glossary (term and meaning only; no implementation detail).
4. Re-check each edited number against its source after editing.
5. Rebuild: run the rebuild command from "Module layout" from the repo root with every source edited in step 2 that has generated files, plus the Phase 1 rebuild targets. Do this even when the user approved no findings; skip it only when the caller declines Phase 4 entirely (as `/course-design` does). If the command reports a generated file with no source, report it instead of deleting it. If a quiz fails to build, that is a Blocker: fix its source and rerun until it builds.

## Done

Report: findings by severity, what was applied, what was skipped, and which generated files were rebuilt; they belong in their own commit after the source fixes (for example "Rebuild Module NN quiz zips and exercise pages"). End with "next: `/add-images NN`, then `/slide-prep NN`".

If findings were skipped or deferred, ask with `AskUserQuestion` whether to publish them as an issue. Follow the tracker doc named in "Pointers" for the title, labels and body format. Create the issue only on a yes.

Remind the user that the course's issue → branch → PR flow (the git workflow in "Pointers") applies.
