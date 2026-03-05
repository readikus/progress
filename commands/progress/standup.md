---
name: progress:standup
description: Generate a concise standup summary of recent development work
allowed-tools:
  - Read
  - Bash
  - Write
  - Glob
  - Grep
---

# Progress: Standup Report

Generate a concise standup-style summary of recent development work.

**User input:** $ARGUMENTS
(Optional: override the time period, e.g., "last 2 weeks", "since monday")

---

## Step 1: Load Profile

Read `~/.progress/profile.json`.

If it doesn't exist, tell the user:
"No profile found. Run `/progress:onboard` first to set up your preferences."
Then stop.

Parse the profile for: `git_author`, `repos`, `periods.standup`, `audiences.standup`, `highlight_areas`, `notes`.

---

## Step 2: Determine Period

- If the user provided input (e.g., "last 3 days"), use that as the period.
- Otherwise use `profile.periods.standup`.
- Fallback: "1 day".

Convert to a git-compatible `--since` value (e.g., "1 day ago", "3 days ago").

---

## Step 3: Gather Git Metrics

For each repo in `profile.repos`, AND the current working directory if it's a git repo not already in the list:

```bash
# Commit messages and dates
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=format:"%h|%s|%ad" --date=short 2>/dev/null

# Aggregate lines added/removed
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --numstat 2>/dev/null | awk 'NF==3 { added += $1; removed += $2 } END { print added+0, removed+0 }'

# Files changed
git -C <repo> log --author="<git_author>" --since="<period>" --pretty=tformat: --name-only 2>/dev/null | sort -u | grep -v '^$'
```

If `gh` CLI is authenticated, also try:
```bash
gh pr list --author <git_author> --state merged --search "merged:>$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d)" --json number,title,mergedAt 2>/dev/null
```
Adjust the date math to match the period. Don't fail if `gh` isn't available.

---

## Step 4: Analyze

Read through all commit messages, file paths, and PR titles. Group them into themes:
- What features or functionality were worked on
- What bugs were fixed
- What was refactored or improved
- What was reviewed (if PR data available)

Use `profile.highlight_areas` to prioritize what to surface.
Use `profile.notes` for team/project context that helps explain the work.

**Adapt language to `profile.audiences.standup`:**
- **Technical audience** (e.g., "engineering team"): Use technical terms freely — mention specific services, refactors, caching strategies, API changes. Engineers want to know *how* things were done.
- **Mixed audience** (e.g., "product and engineering"): Lead with what was achieved, add light technical context in parentheses. Balance outcomes with implementation.
- **Non-technical audience**: Focus purely on outcomes and impact. "Improved search speed" not "Added Redis caching layer to search endpoint".

---

## Step 5: Generate Standup Report

Output a concise, bullet-point summary. This is for standups — keep it tight.

Format:

```
## Standup Update — <period description>

**Done:**
- <Accomplishment grouped by theme — e.g., "Implemented user auth flow (5 commits across auth-service)">
- <Next accomplishment>
- <Next accomplishment>

**In Progress:**
- <Inferred from recent branch/commit activity — unfinished work, WIP commits>

**Blockers:**
- <Only if obvious from commit patterns — reverts, WIP loops, stalled branches>
- <Omit this section entirely if none detected>
```

Guidelines:
- 3-7 bullet points under "Done", grouped by theme not by individual commit
- Write in first person ("Implemented...", "Fixed...", "Refactored...")
- Include repo name in parentheses if multiple repos scanned
- Keep each bullet to one line

---

## Step 6: Save History

Write metrics snapshot for future comparisons:

```bash
mkdir -p ~/.progress/history
```

Save to `~/.progress/history/<YYYY-MM-DD>-standup.json`:
```json
{
  "date": "<today>",
  "period": "<period>",
  "audience": "standup",
  "repos": ["<scanned repos>"],
  "metrics": {
    "commits": 0,
    "prs_merged": 0,
    "lines_added": 0,
    "lines_removed": 0,
    "files_changed": 0
  }
}
```
