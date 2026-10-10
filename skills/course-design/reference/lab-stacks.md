# Lab stacks

Seed defaults for recommending lab tooling. Last checked: 2026-10-06. Before recommending a choice, re-verify it through `/research` (SKILL.md, "Field currency") and put the newer source in the proposal; this file is a starting point, not evidence.

| Stack | Test runner | CI setup | Sources |
|---|---|---|---|
| Python | pytest (Python 3.10+) | `actions/setup-python`, then `pytest` | https://docs.pytest.org/en/stable/, https://docs.github.com/en/actions/tutorials/build-and-test-code/python |
| Bash | bats-core (Bash 3.2+) | none seeded | https://bats-core.readthedocs.io/en/stable/ |
| Rust | `cargo test` (unit, integration and doc tests) | none seeded | https://doc.rust-lang.org/cargo/commands/cargo-test.html |
| MIPS | MARS 4.5 command-line mode (last release August 2014), driven by a script | `actions/setup-java` | https://dpetersanderson.github.io/, https://github.com/actions/setup-java |

"none seeded" means the catalog holds no sourced choice; find one through `/research` before recommending it.

## Recommended set per stack

A complete lab pipeline for one stack has:

- **Authoring skill**: writes the reference solution and derives the student template.
- **Test skill**: runs the test harness locally and per task.
- **CI skill**: the CI job and when it triggers. One adapter skill may cover authoring, test and CI.
- **Lab reviewer subagent**: reviews a lab against the contract and its rubric. Deferred while the course has a single stack; recommend it once a second stack exists.
- **Integrity recommendation**: a policy suggestion only, such as a recorded code walkthrough, varied test inputs or an AI-use disclosure.

Report each item as present (with its path), deferred or missing; a missing item is a `tooling` proposal.
