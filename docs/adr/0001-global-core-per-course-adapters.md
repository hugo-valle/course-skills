# Global core skills, per-course adapters, joined by COURSE.md

Status: accepted, 2026-10-10

The course-building skills were first written inside one course repo (CS 2810) with that course's paths, textbook, exam weeks and lab stack written into them. To reuse them, we keep one global copy of every course-neutral skill in this repo, symlinked into `~/.claude/`, and each course repo keeps a `COURSE.md` describing itself plus adapter skills only it needs (such as a lab-stack skill). The global skills read every course-specific fact from `COURSE.md`; `scripts/leak_check.sh` keeps course terms out of the core.

## Considered options

- **Copy all skills globally and generalise every one**, including lab and quiz adapters: rejected. Stack-specific skills would become vague and trigger in unrelated projects.
- **Copy the skills folder into each course repo**: rejected. Improvements made in one course would not reach the others, and the copies drift.
- **Package as a Claude Code plugin**: deferred. A git repo plus symlinks gives versioning and one source of truth with no packaging step; revisit if colleagues install the skills.

## Consequences

- A new course needs a `COURSE.md` before the global skills can work in it.
- Project copies of a global skill must be deleted from course repos so an old copy never shadows the global one.
