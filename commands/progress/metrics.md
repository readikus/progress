---
name: progress:metrics
description: Colorful CLI dashboard showing git metrics with period-over-period comparisons
allowed-tools:
  - Read
  - Bash
  - Glob
---

# Progress: Metrics Dashboard

Display a colorful CLI metrics dashboard with period-over-period comparisons — showing how the current period stacks up against previous periods of the same length.

**User input:** $ARGUMENTS
(Optional: override the time period, e.g., "last 2 weeks", "last month", "last sprint")

---

## Step 1: Load Profile

Read `~/.progress/profile.json`.

If it doesn't exist, tell the user:
"No profile found. Run `/progress:onboard` first to set up your preferences."
Then stop.

Parse the profile for: `name`, `git_author`, `repos`, `periods.sprint`.

---

## Step 2: Determine Period & Comparison Windows

- If the user provided input (e.g., "last 2 weeks"), use that as the period length.
- If user says "last sprint", use `profile.periods.sprint`.
- Fallback: "1 week".

Calculate **4 consecutive windows** of that period length, working backwards from now:

| Window | Label | Example (1 week) |
|--------|-------|-------------------|
| Current | "This period" | Last 7 days |
| Previous 1 | "Prev 1" | 8-14 days ago |
| Previous 2 | "Prev 2" | 15-21 days ago |
| Previous 3 | "Prev 3" | 22-28 days ago |

Convert each window to `--since` and `--until` date pairs for git. Use `date` commands to compute exact ISO dates:

```bash
# macOS date examples for 1-week windows:
now=$(date +%Y-%m-%dT%H:%M:%S)
p0_start=$(date -v-7d +%Y-%m-%dT00:00:00)
p1_start=$(date -v-14d +%Y-%m-%dT00:00:00)
p1_end=$(date -v-7d +%Y-%m-%dT00:00:00)
p2_start=$(date -v-21d +%Y-%m-%dT00:00:00)
p2_end=$(date -v-14d +%Y-%m-%dT00:00:00)
p3_start=$(date -v-28d +%Y-%m-%dT00:00:00)
p3_end=$(date -v-21d +%Y-%m-%dT00:00:00)
```

Adjust the day offsets for the chosen period length. For "2 weeks", use 14/28/42/56; for "1 month", use 30/60/90/120 day offsets, etc.

---

## Step 3: Gather Metrics for All 4 Windows

For each of the 4 time windows, for each repo in `profile.repos` (AND the current working directory if it's a git repo not already in the list), run:

```bash
# Commits
git -C <repo> log --author="<git_author>" --since="<window_start>" --until="<window_end>" --oneline 2>/dev/null | wc -l

# Lines added/removed
git -C <repo> log --author="<git_author>" --since="<window_start>" --until="<window_end>" --pretty=tformat: --numstat 2>/dev/null | awk 'NF==3 && $1 != "-" { added += $1; removed += $2 } END { print added+0, removed+0 }'

# Files changed
git -C <repo> log --author="<git_author>" --since="<window_start>" --until="<window_end>" --pretty=tformat: --name-only 2>/dev/null | sort -u | grep -c -v '^$'
```

For the **current window only** (no `--until`), omit the `--until` flag so it captures up to now.

If `gh` CLI is available:
```bash
# PRs merged (current window)
gh pr list --author <git_author> --state merged --search "merged:>$(p0_start_date)" --json number 2>/dev/null | jq length

# PRs merged (previous windows — use merged:START..END range)
gh pr list --author <git_author> --state merged --search "merged:$(p1_start_date)..$(p1_end_date)" --json number 2>/dev/null | jq length
```

Don't fail if `gh` isn't available — just skip PR metrics.

Aggregate across all repos per window.

---

## Step 4: Compute Comparisons

For each metric, calculate:
- **Average of previous 3 periods** (or however many have non-zero data)
- **Delta** = current - previous average
- **Percentage change** = ((current - avg) / avg) * 100 (guard against division by zero)
- **Trend direction**: up, down, or flat (within 5% = flat)

---

## Step 5: Render Colorful CLI Dashboard

Output the dashboard using a single `bash` command that uses `printf` with ANSI escape codes. This is critical — the output MUST be a bash command that prints colored terminal output, NOT markdown.

**Color scheme:**
- `\033[1;36m` — Cyan bold for headers/labels
- `\033[1;37m` — White bold for current period values
- `\033[1;32m` — Green for positive trends (up arrows)
- `\033[1;31m` — Red for negative trends (down arrows)
- `\033[1;33m` — Yellow for flat trends
- `\033[0;90m` — Gray for previous period values
- `\033[0m` — Reset
- `\033[4m` — Underline for section headers

**Bar characters:** Use Unicode block elements to create mini bar charts:
- Full block: `\xe2\x96\x88` (U+2588)
- Use these to create proportional bars for each period, scaled so the maximum value across all 4 windows = 20 characters wide.

**Dashboard layout:**

```
printf '\033[1;36m\033[4m'
printf '  PROGRESS METRICS'
printf '\033[0m\n'
printf '\033[0;90m  %s  |  Comparing 4 x %s periods\033[0m\n\n' "<name>" "<period>"
```

For EACH metric (Commits, Lines Added, Lines Removed, Files Changed, PRs Merged if available):

```
  <METRIC NAME>
  This period    ████████████████████  142    ▲ +34% vs avg
  Prev 1         ██████████████        98
  Prev 2         ████████████████      112
  Prev 3         ██████████            72
                                       ───
                                  avg: 94
```

Specifics:
- The metric name should be cyan bold
- "This period" value should be white bold
- The bar for the current period should be cyan (`\033[1;36m`)
- Bars for previous periods should be gray (`\033[0;90m`)
- The trend indicator (▲ +34%) should be green if positive, red if negative, yellow if flat
- Use `▲` for up, `▼` for down, `▸` for flat
- Right-align all numbers
- The avg line should be gray
- Add a blank line between each metric

**Bottom summary line:**

```
  ──────────────────────────────────────
  Net lines: +1,204  |  Commits/day: 3.2  |  Most active repo: <repo-name>
```

Calculate:
- **Net lines** = lines_added - lines_removed (current period)
- **Commits/day** = commits / days_in_period (to 1 decimal)
- **Most active repo** = repo with most commits in current period (just the basename)

**IMPORTANT rendering rules:**
1. ALL output must be via a single `bash` command using `printf` statements
2. Use `\033[` escape sequences for colors — these render in the terminal
3. Scale bars proportionally: find the max value across all 4 windows for each metric, then scale so max = 20 bar characters
4. Format large numbers with commas (e.g., 1,234)
5. Right-align numbers in a consistent column
6. If a metric is 0 across all windows, skip it entirely
7. If only 1-2 previous periods have data (e.g., new repo), compare against those and note it

---

## Step 6: No History Save

This command is a live dashboard view — do NOT save to `~/.progress/history/`. The standup, sprint, and review commands handle history tracking.
