---
name: progress:review
description: Generate a detailed personal review with full metrics, trends, and commit history
allowed-tools:
  - Read
  - Bash
  - Write
  - Glob
  - Grep
---

# Progress: Personal Review

Generate a detailed personal review of your development work — full metrics, categorized breakdown, commit log, and trends. For self-tracking, performance reviews, and personal reflection.

**User input:** $ARGUMENTS
(Optional: override the time period, e.g., "last month", "since jan 1")

---

## Step 1: Load Profile

Read `~/.progress/profile.json`.

If it doesn't exist, tell the user:
"No profile found. Run `/progress:onboard` first to set up your preferences."
Then stop.

Parse the profile for: `name`, `git_author`, `repos`, `default_period`, `highlight_areas`, `notes`.

---

## Step 2: Determine Period

- If the user provided input, use that as the period.
- Otherwise use `profile.default_period`.
- Fallback: "1 month" (reviews tend to cover longer periods).

Convert to a git-compatible `--since` value.

---

## Step 3: Gather Full Git Data

For each repo in `profile.repos`, AND the current working directory if it's a git repo not already in the list:

```bash
# Full commit log with stats
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=format:"%h|%s|%ad|%D" --date=short 2>/dev/null

# Per-commit stats
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=format:"%h" --shortstat 2>/dev/null

# Aggregate lines
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --numstat 2>/dev/null | awk 'NF==3 { added += $1; removed += $2 } END { print added+0, removed+0 }'

# All files changed with change counts
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --numstat 2>/dev/null | awk 'NF==3 { files[$3] += ($1 + $2) } END { for (f in files) print files[f], f }' | sort -rn

# Directory-level breakdown
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --dirstat=lines 2>/dev/null

# Commits per day (for activity pattern)
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=format:"%ad" --date=short 2>/dev/null | sort | uniq -c | sort -k2
```

If `gh` CLI is authenticated:
```bash
# Merged PRs with full details
gh pr list --author <git_author> --state merged --search "merged:>$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)" --json number,title,mergedAt,additions,deletions,changedFiles,reviews 2>/dev/null

# PRs reviewed
gh pr list --state merged --search "reviewed-by:<git_author> merged:>$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)" --json number,title 2>/dev/null

# Issues closed
gh issue list --assignee <git_author> --state closed --search "closed:>$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)" --json number,title 2>/dev/null
```

Adjust dates to match the actual period.

---

## Step 4: Load History for Trends

Read ALL matching history files in `~/.progress/history/` (not just the most recent):

```bash
ls -1t ~/.progress/history/*-review.json 2>/dev/null
```

Also read standup and sprint histories if review histories are sparse:
```bash
ls -1t ~/.progress/history/*.json 2>/dev/null
```

Build a trend view: how metrics have changed over the last 3-5 periods.

---

## Step 5: Deep Analysis

Categorize every commit into one of:
- **Features** — new functionality
- **Bug Fixes** — fixing broken behavior
- **Refactoring** — improving code without changing behavior
- **Tests** — test additions or improvements
- **Documentation** — docs, comments, READMEs
- **Infrastructure** — CI/CD, build, deployment, config
- **Dependencies** — package updates, version bumps
- **Other** — anything that doesn't fit

Use commit messages, file paths, and PR titles to classify. When ambiguous, use best judgment from file paths (e.g., `test/` files = Tests, `docs/` = Documentation, `.github/` = Infrastructure).

Also identify:
- Most-modified files (hotspots)
- Activity patterns (which days were most active)
- Largest individual commits

Use `profile.highlight_areas` and `profile.notes` for context.
Read `CLAUDE.md` files in scanned repos for project context.

---

## Step 6: Generate Review

Format:

```
## Personal Review — <period description>

### Overview
[2-3 sentence summary of the period. What was the main focus? What was accomplished?]

### Metrics
| Metric | This Period | Trend |
|--------|-------------|-------|
| Commits | N | [arrow or description based on history] |
| PRs Merged | N | ... |
| PRs Reviewed | N | ... |
| Issues Closed | N | ... |
| Lines Added | N | ... |
| Lines Removed | N | ... |
| Files Changed | N | ... |
| Repos Active | N | ... |
| Active Days | N/M | ... |

### Work Breakdown

**Features**
- [Feature name]: [description from commits] — [N commits, +X/-Y lines]
  - Key files: [most-changed files for this feature]

**Bug Fixes**
- [Bug fix]: [what was wrong, how it was fixed] — [commit hash]

**Refactoring**
- [Refactor scope]: [what was improved] — [N commits]

**Tests**
- [Test additions/improvements]

**Infrastructure**
- [CI/CD, build, config changes]

**Code Reviews**
- Reviewed N PRs: [list with titles if available]

(Omit categories with no activity)

### Hotspots
Top 5 most-modified files:
1. `path/to/file` — N changes
2. ...

### Activity Pattern
[Which days/weeks were busiest. Note any gaps or bursts of activity.]

### Trends
[If history available: comparison table showing metrics over last 3-5 periods. Note patterns — increasing velocity, shifting focus areas, etc.]

### Commit Log
[Full list grouped by date, most recent first]

#### <date>
- `<hash>` <message> [<repo name if multiple>]
- `<hash>` <message>
```

Guidelines:
- Be thorough — this is for the developer's own records
- Include specific numbers, file paths, and commit hashes
- Frame trends objectively — no cheerleading, just data
- The commit log at the end should be complete, not summarized

---

## Step 7: Save History

```bash
mkdir -p ~/.progress/history
```

Save to `~/.progress/history/<YYYY-MM-DD>-review.json`:
```json
{
  "date": "<today>",
  "period": "<period>",
  "audience": "review",
  "repos": ["<scanned repos>"],
  "metrics": {
    "commits": 0,
    "prs_merged": 0,
    "prs_reviewed": 0,
    "issues_closed": 0,
    "lines_added": 0,
    "lines_removed": 0,
    "files_changed": 0,
    "active_days": 0
  },
  "breakdown": {
    "features": 0,
    "bug_fixes": 0,
    "refactoring": 0,
    "tests": 0,
    "docs": 0,
    "infra": 0,
    "other": 0
  }
}
```
