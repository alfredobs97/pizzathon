---
name: gh-pr
description: Creates a pull request targeting the 'dev' branch with a short description in Spanish using the gh CLI.
---

# GH PR Skill

When you are asked to create a PR or whenever you use this skill manually, follow these steps strictly:

1. Ensure all your current changes are committed before attempting to create a PR.
2. Ensure you have pushed your current branch to the remote repository. If not, push it with `git push -u origin <current-branch>`.
3. Assess the changes that were made on the branch.
4. Craft a concise title and a short description summarizing the changes. Both the title and the description MUST BE WRITTEN IN SPANISH.
5. Use the GitHub CLI (`gh`) to open the pull request targeting the **`dev`** branch.

Run the equivalent of the following bash command (via your `run_command` tool):
```bash
gh pr create --base dev --title "<Título descriptivo en español>" --body "<Descripción corta y concisa de los cambios realizados en español>"
```

### Constraints:
- **Base branch:** Always `dev`.
- **Language:** Spanish (Español).
- **Auto-merge:** Do NOT automatically merge the PR.
- **Reporting:** After successfully executing the command, return the URL of the created pull request to the user.
