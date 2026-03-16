---
name: git-worktree-isolation
description: Use for significant features or bug fixes that require isolation from the main workspace. Trigger when complexity, scope, or impact justifies an independent environment (e.g., multi-layer changes, state management refactors, or critical path fixes).
---

# Git Worktree Isolation

## Overview

Git worktree isolation creates separate workspaces sharing the same repository, allowing work on multiple branches simultaneously without polluting the main environment. This ensures a clean development flow and easy context switching.

**Core Principle:** Systematic Isolation + Safety Verification + Clean Baseline.

**Announce at start:** "Using the git-worktree-isolation skill to set up an isolated workspace."

## When to Use

Invoke this skill when a task is "big enough" to warrant an independent workspace. Use the following criteria:

### 1. High Complexity
- Tasks involving complex state management refactors (e.g., Bloc/Cubit restructuring).
- Changes to core architectural patterns or shared utilities.
- Implementation of complex business logic with many edge cases.

### 2. Broad Scope
- Features that touch multiple layers (Data, Domain, Presentation).
- Tasks requiring modifications to more than 5 files.
- Refactors that trigger widespread changes across the codebase.

### 3. Critical Impact
- Fixes for critical bugs on the main execution path.
- Changes that could significantly impact application stability or performance.
- When you need to maintain a stable "known-good" environment in the main directory for side-by-side comparison.

## Directory Selection Process

Follow this priority order to ensure consistency and portability:

### 1. Check Project Instruction Files (AGENT.md)

```bash
# Look for worktree or isolation directory preferences in AGENT.md
# Fallback to provider-specific files like GEMINI.md or CLAUDE.md if AGENT.md is missing
grep -iE "worktree.*directory|isolation.*directory" AGENT.md GEMINI.md CLAUDE.md 2>/dev/null
```

**If preference specified:** Use it without asking (e.g., `.worktrees/` or `.isolated/`).

### 2. Auto-Detect Existing Directories

```bash
# Check for common isolation directories (hidden or standard)
ls -d .worktrees 2>/dev/null || ls -d .isolated 2>/dev/null || ls -d worktrees 2>/dev/null
```

### 3. Ask User

If no directory exists and no instruction file preference is found:

```
No isolation directory found. Where should I create worktrees?

1. .worktrees/ (Project-local, hidden)
2. .isolated/ (Project-local, standard)
3. ~/.config/worktrees/<project-name>/ (Global location)

Which would you prefer?
```

## Safety Verification and Setup

**Action:** Use the provided script to automate safety checks, creation, and baseline verification.

**Command:** 
```bash
./.agent/skills/git-worktree-isolation/scripts/verify-and-setup.sh <BRANCH_NAME> <ISOLATION_PATH>
```

**Safety Mandate (Must verify before script):**
Ensure the `ISOLATION_PATH` is ignored by git:
```bash
git check-ignore -q "$ISOLATION_PATH"
```
**If NOT ignored:** Add the path to `.gitignore`, commit it, and only then proceed.

## Quick Reference

| Situation | Action |
|-----------|--------|
| `AGENT.md` has path | Use it (verify ignored) |
| Local dir exists | Use it (verify ignored) |
| Dir not ignored | Add to .gitignore + commit |
| Baseline tests fail | Report failures + ask |
| Work complete | Cleanup (ONLY after user agreement) |

## Red Flags

**Never:**
- Create worktree without verifying it is ignored (if local).
- Hardcode absolute paths (e.g., `/Users/name/...`).
- Skip baseline test verification.
- Proceed with worktree creation if it violates project conventions found in `AGENT.md`.
- Remove a worktree without getting explicit approval from the user first.

**Always:**
- Follow priority: `AGENT.md` > existing > ask.
- Ensure the main workspace remains clean.
- Use `flutter pub get` after creating the worktree.
- Ask the user for permission before running cleanup commands that delete worktrees.

## Resources

- **Helper Script:** [scripts/verify-and-setup.sh](./scripts/verify-and-setup.sh)
- **Baseline Template:** [resources/baseline-template.md](./resources/baseline-template.md)
