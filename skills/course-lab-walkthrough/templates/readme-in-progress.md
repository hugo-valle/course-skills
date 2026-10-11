# {{ title }}

<!--
This is the banner section only. Below it, paste the lab's existing static
reference content VERBATIM: course/points header line, Quick Links, spec
tables, register/variable maps, testing instructions, submission checklist,
etc. -- everything EXCEPT the per-task instruction sections (those move to
.github/steps/task-N.md and get revealed progressively instead).

readme-finished.md is a copy of this whole file with ONLY the banner block
below changed (see the diff comment at the bottom of this file).

GOTCHA: this banner goes at the very TOP of the file, right after the header
-- but that's specific to THIS file (and readme-finished.md), which only ever
gets written by the workflow into a real student repo. The static root
README.md that ships in the TEMPLATE repo (and stays there forever, since the
is_template guard means the workflow never touches it) needs a DIFFERENT,
non-personalized version of this banner instead -- no {{ }} variables, no
real issue link, just a generic note pointing at the Issues tab -- placed
LATER in the document (after Program Specification/spec tables, right before
Complete Sample Output), because that README reads as a curriculum landing
page, not an active assignment. See the skill's Phase 2 section for the
exact wording pattern.
-->

**Course:** <course code and title>
**Module:** N — Replace With Module Title
**Points:** NNN

---

## 🚀 Your exercise is live, {{ login }}!

This lab uses an interactive walkthrough. I'll check your work after every push and post the next task's instructions as a comment on your tracking issue.

[![](https://img.shields.io/badge/Go%20to%20Exercise-%E2%86%92-1f883d?style=for-the-badge&logo=github&labelColor=197935)]({{ issue_url }})

---

<!-- ... paste the rest of the static README content here ... -->

<!--
readme-finished.md differs ONLY in this banner block, replaced with:

## 🎉 All N automated tasks pass, {{ login }}!

That's XXX/XXX automated points. NN points (video, coding standards, git
workflow, submission -- whatever this course's manual-grading categories
are) are still graded manually by your instructor -- see the Submission
Checklist below and the notes on your tracking issue.

[![](https://img.shields.io/badge/Return%20to%20Exercise-%E2%86%92-1f883d?style=for-the-badge&logo=github&labelColor=197935)]({{ issue_url }})

Everything else in the file (Quick Links, spec, testing, checklist) stays
byte-identical between the two templates.
-->
