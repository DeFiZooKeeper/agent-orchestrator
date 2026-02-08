# GitHub Code PR

Clone a repository, make code changes, and create a pull request.

## Usage

```
/github-code-pr <repo-url> <branch-name> <description>
```

## Parameters

- `repo-url`: GitHub repository URL (https or git format)
- `branch-name`: Name for the new feature branch
- `description`: Brief description of the changes to make

## Example

```
/github-code-pr https://github.com/user/repo.git fix-auth-bug "Fix authentication issue in login handler"
```

## Process

1. Clone the repository using GITHUB_TOKEN
2. Create a new branch with the specified name
3. Make the requested code changes
4. Run tests if available
5. Commit changes with conventional commit format
6. Push branch to origin
7. Create pull request with:
   - Clear title describing the change
   - Body explaining what was changed and why
   - Reference to the original request

## Requirements

- GITHUB_TOKEN must be set in environment
- gh CLI tool for GitHub operations
- Repository must be accessible to the token

## Notes

- Always creates a new branch for changes
- Never commits directly to main branch
- Follows conventional commit message format
- Includes test running when tests are present