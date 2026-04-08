# Skill Registry

**Delegator use only.** Any agent that launches sub-agents reads this registry to resolve compact rules, then injects them directly into sub-agent prompts. Sub-agents do NOT read this registry or individual SKILL.md files.

## User Skills

| Trigger | Skill | Path |
|---------|-------|------|
| When designing or reviewing landing pages, CTA hierarchy, product feedback states, accessibility, or conversion-oriented user flows. | `apple-ux-patterns` | `/home/johan/code/todoaldia/skills/apple-ux-patterns/SKILL.md` |
| When creating a pull request, opening a PR, or preparing changes for review. | `branch-pr` | `/home/johan/.config/opencode/skills/branch-pr/SKILL.md` |
| When writing Go tests, using teatest, or adding test coverage. | `go-testing` | `/home/johan/.config/opencode/skills/go-testing/SKILL.md` |
| When creating a GitHub issue, reporting a bug, or requesting a feature. | `issue-creation` | `/home/johan/.config/opencode/skills/issue-creation/SKILL.md` |
| When user says "judgment day", "judgment-day", "review adversarial", "dual review", "doble review", "juzgar", "que lo juzguen". | `judgment-day` | `/home/johan/.config/opencode/skills/judgment-day/SKILL.md` |
| When user asks to create a new skill, add agent instructions, or document patterns for AI. | `skill-creator` | `/home/johan/.config/opencode/skills/skill-creator/SKILL.md` |

## Compact Rules

Pre-digested rules per skill. Delegators copy matching blocks into sub-agent prompts as `## Project Standards (auto-resolved)`.

### apple-ux-patterns
- Communicate user-facing state explicitly: idle, pending, success, validation issue, and failure.
- Feedback must answer what happened and what the user can do next.
- Prefer inline, local feedback and quick recovery paths over blocking flows.
- Keep one dominant CTA per screen; secondary actions must be visibly quieter.
- Landing structure should prioritize value, outcome, friction reduction, proof, and CTA in that order.
- Use Apple patterns only as interaction guidance: calm hierarchy, progressive disclosure, clear status.
- Never clone Apple visuals, product marketing style, or brand language.
- Accessibility is non-negotiable: visible focus, semantic landmarks, labels, contrast, and mobile-sized targets.

### branch-pr
- Every PR must link an approved issue and include exactly one `type:*` label.
- Use non-interactive workflow: verify issue, create branch `type/description`, implement, open PR, label it.
- Follow conventional commits with valid type and optional scope.
- Run required verification for touched shell scripts before pushing.
- Use the repo PR template, include `Closes #N`, summary bullets, changes table, and test plan.
- Never add AI attribution trailers or skip required checks.

### go-testing
- Prefer table-driven tests for multiple cases and cover success plus error branches.
- Test Bubbletea model state transitions directly before using broader integration coverage.
- Use teatest for interactive TUI flows and golden files for stable view output.
- Mock side effects and use `t.TempDir()` for file-based tests.
- Keep tests focused on observable behavior, not implementation noise.

### issue-creation
- Search for duplicates before opening a new issue.
- Always use the correct issue template; blank issues are not allowed.
- New issues get `status:needs-review`; implementation should wait for `status:approved`.
- Questions belong in discussions, not issues.
- Fill all required template fields with reproducible steps or concrete problem framing.
- Use conventional commit style in issue titles when applicable.

### judgment-day
- Before launching judges, resolve matching compact rules from this registry and inject them into every sub-agent prompt.
- Always launch two blind judges in parallel; neither judge should know about the other.
- The orchestrator synthesizes findings into confirmed, suspect, and contradictory results.
- Fix confirmed criticals and real warnings with a separate fix agent, then re-judge when required.
- Theoretical warnings are informational and should not block approval.
- After two fix iterations, ask the user before continuing further loops.

### skill-creator
- Create skills only for reusable, non-trivial patterns that benefit from explicit agent guidance.
- Follow the standard skill structure with frontmatter, usage guidance, critical patterns, examples, commands, and resources.
- Name skills with lowercase hyphenated identifiers and include trigger text in the description frontmatter.
- Prefer references to local docs over duplicating large documentation blocks.
- Register new project skills in `AGENTS.md` after creating them.

## Project Conventions

| File | Path | Notes |
|------|------|-------|
| `AGENTS.md` | `/home/johan/code/todoaldia/AGENTS.md` | Project instructions and skill index |

Read the convention files listed above for project-specific patterns and rules. All referenced paths have been extracted where applicable.
