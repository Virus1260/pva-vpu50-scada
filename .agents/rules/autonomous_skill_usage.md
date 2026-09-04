# Autonomous Skill Discovery & Usage

## Directive
The user has granted explicit standing authorization to discover, install, and execute agent skills proactively without asking for permission in chat sessions:

1. **Standing Approval for Skill Discovery & Installation**:
   - Whenever encountering a domain or task that benefits from specialized agent skills (e.g. testing, performance, UI/UX, cloud, frameworks, optimizations), use `find-skills` (`npx skills find ...`) or install relevant skills (`npx skills add <package> -g -y`).
   - Do NOT ask the user "Should I install this skill?" or "Do you want me to search for a skill?". Perform the search and installation autonomously when needed to achieve the user's objective.

2. **Global & Non-Interactive Installation**:
   - Always use global installation flags: `npx skills add <package> -g -y` (or with `--copy`).
   - After installing or when consulting a skill, read its `SKILL.md` instructions and execute the appropriate workflows.
