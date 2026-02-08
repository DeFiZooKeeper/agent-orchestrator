---
name: github-pr-review
description: Review a GitHub pull request — summarize changes, identify issues, and post review comments.
metadata: {"openclaw":{"requires":{"env":["GITHUB_TOKEN"]}}}
---

# GitHub PR Review Skill

When asked to review a pull request:

## Steps

1. **Fetch PR details**:
   ```bash
   gh pr view OWNER/REPO#NUMBER --json title,body,files,additions,deletions,commits
   gh pr diff OWNER/REPO#NUMBER
   ```

2. **Analyze the diff**: Look at every changed file and understand what the PR does.

3. **Provide a structured review**:
   - **Summary**: 2-3 sentences on what the PR does.
   - **Key Changes**: Bullet list of the most significant modifications.
   - **Issues Found**: Any bugs, logic errors, security concerns, or style problems.
   - **Suggestions**: Concrete improvements (with code snippets if helpful).
   - **Verdict**: Approve / Request Changes / Needs Discussion.

4. **Post the review** back in Discord with a formatted message.

## Notes

- Be constructive, not nitpicky. Focus on things that matter.
- If the PR is large, focus on the riskiest or most complex changes.
- Reference specific file paths and line numbers when pointing out issues.
