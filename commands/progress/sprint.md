# Progress: Sprint Report

Generate a narrative sprint summary with metrics and comparisons — suitable for sprint demos, team presentations, or stakeholder updates.

**User input:** $ARGUMENTS
(Optional: override the time period, e.g., "last 2 weeks", "since feb 20")

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
- Fallback: "2 weeks" (sprints are typically longer than standups).

Convert to a git-compatible `--since` value.

---

## Step 3: Gather Git Metrics

For each repo in `profile.repos`, AND the current working directory if it's a git repo not already in the list:

```bash
# Commit count
git -C <repo> log --author="<git_author>" --since="<period>" --oneline 2>/dev/null | wc -l

# Commit details
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=format:"%h|%s|%ad" --date=short 2>/dev/null

# Lines added/removed
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --numstat 2>/dev/null | awk 'NF==3 { added += $1; removed += $2 } END { print added+0, removed+0 }'

# Files changed count
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --name-only 2>/dev/null | sort -u | grep -c -v '^$'

# Diff stat summary (for seeing which areas got most changes)
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --dirstat=lines 2>/dev/null
```

If `gh` CLI is authenticated:
```bash
# Merged PRs
gh pr list --author <git_author> --state merged --search "merged:>$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)" --json number,title,mergedAt,additions,deletions 2>/dev/null

# PRs reviewed
gh pr list --state merged --search "reviewed-by:<git_author> merged:>$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)" --json number,title 2>/dev/null
```

Adjust dates to match the actual period. Don't fail if `gh` isn't available.

---

## Step 4: Load Previous History

Find the most recent `*-sprint.json` file in `~/.progress/history/` to calculate deltas.

```bash
ls -1t ~/.progress/history/*-sprint.json 2>/dev/null | head -1
```

If found, read it and compute:
- Delta commits (this period vs last)
- Delta lines added/removed
- Delta PRs merged

If no history exists, skip comparisons and note "first report — no comparison available".

---

## Step 5: Analyze Work

Read through all commit messages, file paths, PR titles, and dirstat output. Identify:

1. **Features delivered** — new functionality, user-facing changes
2. **Technical improvements** — refactors, performance, test coverage, infra
3. **Collaboration** — PR reviews, mentorship (if data available)
4. **Areas of codebase** — which directories/modules saw the most activity

Use `profile.highlight_areas` to weight what gets top billing.
Use `profile.notes` for project/team context.

Also read `CLAUDE.md` in each scanned repo (if it exists) for additional project context.

---

## Step 6: Generate Sprint Report

Format:

```
## Sprint Summary — <period description>

### Metrics
| Metric | This Sprint | vs Last Sprint |
|--------|-------------|----------------|
| Commits | N | +/-N |
| PRs Merged | N | +/-N |
| PRs Reviewed | N | +/-N |
| Lines Added | N | +/-N |
| Lines Removed | N | +/-N |
| Files Changed | N | — |

### What Was Delivered
[Narrative paragraph — 3-5 sentences describing the key features and functionality delivered this sprint. Write in third person using the developer's name from profile. Give context about why the work matters, not just what was done.]

### Technical Improvements
[Paragraph on refactors, performance improvements, test coverage, infrastructure work. Only include if relevant work was done.]

### Collaboration
[PR reviews done, mentorship, cross-team work. Only include if data available.]

### Codebase Impact
[Which areas of the codebase saw the most activity — based on dirstat. 2-3 bullet points.]
```

Guidelines:
- Write in narrative form, not bullet points (this is for presentations)
- Use the developer's name from profile
- Include specific numbers where they add weight
- If metrics are up vs last sprint, frame positively; if down, provide neutral context
- Omit sections that have no relevant data rather than saying "none"

---

## Step 7: Save History

```bash
mkdir -p ~/.progress/history
```

Save to `~/.progress/history/<YYYY-MM-DD>-sprint.json`:
```json
{
  "date": "<today>",
  "period": "<period>",
  "audience": "sprint",
  "repos": ["<scanned repos>"],
  "metrics": {
    "commits": 0,
    "prs_merged": 0,
    "prs_reviewed": 0,
    "lines_added": 0,
    "lines_removed": 0,
    "files_changed": 0
  }
}
```
