# GitHub Issue Triage

Analyze and triage GitHub issues for better organization and prioritization.

## Usage

```
/github-issue-triage <repo-url> [options]
```

## Parameters

- `repo-url`: GitHub repository URL
- `options`: Optional flags
  - `--label=<label>`: Focus on specific label
  - `--state=<open|closed|all>`: Filter by issue state (default: open)
  - `--limit=<number>`: Maximum issues to analyze (default: 10)

## Example

```
/github-issue-triage https://github.com/user/repo.git --label=bug --limit=5
```

## Analysis Includes

1. **Issue Classification**:
   - Bug reports vs feature requests
   - Priority assessment (high/medium/low)
   - Complexity estimation

2. **Labels Review**:
   - Check for missing labels
   - Suggest appropriate labels
   - Identify inconsistent labeling

3. **Duplication Detection**:
   - Identify potentially duplicate issues
   - Suggest consolidation opportunities

4. **Action Items**:
   - Recommend issue assignments
   - Suggest priority adjustments
   - Flag stale issues

## Output Format

Provides a comprehensive report with:
- Total issues analyzed
- Classification breakdown
- Priority recommendations
- Label suggestions
- Duplicate candidates
- Actionable next steps

## Requirements

- GITHUB_TOKEN must be set in environment
- Repository must be accessible to the token
- gh CLI tool for GitHub operations