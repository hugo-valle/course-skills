# Distribute the shared skills as a Claude Code plugin

Status: accepted, 2026-10-11; supersedes [ADR 0003](0003-install-skills-per-course-repo.md) for course repos that can use plugins

ADR 0003 linked the skills into each course repo with `install.sh`. The links hold absolute paths into one clone, so a fresh clone, a collaborator's machine and CI had no skills until someone ran the script. This repo is now a Claude Code plugin and its own marketplace (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `source: "./"`). A course repo commits `extraKnownMarketplaces` and `enabledPlugins` in its `.claude/settings.json` (`claude plugin marketplace add hugo-valle/course-skills --scope project`, then `claude plugin install course-skills@course-skills --scope project`). Whoever opens the repo and accepts the folder-trust prompt gets the skills and agents. `cs2810-master` and `cs6200-master` moved over in cs2810-master#121 and cs6200-master#10 (spike: cs2810-master#120).

## Decisions

- **Names stay as they are** (`course-*`); the plugin is `course-skills`, so commands read `/course-skills:course-review` and agents `course-skills:course-module-*-reviewer`. Renaming the plugin `course` and dropping the prefix was rejected: it would reverse [ADR 0002](0002-course-prefix-for-shared-skills.md) for a shorter command.
- **No `version`.** Every push to `main` is an update. Pinning and bumping a version on each release was rejected while the instructor is the only consumer.
- **`template/` stays a copy** in each course repo (ADR 0001 amendment).
- **`install.sh` stays as a fallback** for a repo that cannot use plugins (today `cs6610-master`, which has no `COURSE.md` yet). Delete it when no repo uses it.

## Considered options

- **Keep the symlinks** (ADR 0003): rejected for repos that can use plugins; machine-specific and absent on a fresh clone or in CI.
- **A committed copy of the skills in each repo**: rejected; copies drift (ADR 0001).
- **A git submodule**: rejected; skills must sit directly in `.claude/skills/<name>/`, which a submodule would nest.

## Consequences

- Each person needs git read access to this repo (it is private) with stored credentials; CI needs `GH_TOKEN` and `gh auth setup-git`. Making the repo public would remove this; it waits on the history and author-email decision in course-skills#1.
- A non-interactive `-p` run applies the project marketplace only in a folder whose trust was already accepted interactively.
- Auto-update is off by default; users enable it in `/plugin` or run `claude plugin marketplace update course-skills`.
- To edit the skills live, run `claude --plugin-dir ~/course-skills`; that copy replaces the installed one for the session.
