<div align="center">

# Progress

**Developer work summaries from git history — for standups, sprint demos, and performance reviews.**

**Set up once. Never repeat yourself.**

[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)

</div>

---

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/readikus/progress/main/install.sh | bash
```

Restart Claude Code, then:

```
/progress:onboard              # one-time setup (mostly auto-detected)
/progress:standup               # what you did today
```

<details>
<summary><strong>Manual install / Update / Uninstall</strong></summary>

**Manual install:**
```bash
git clone https://github.com/readikus/progress.git ~/.progress/repo
ln -sfn ~/.progress/repo/commands/progress ~/.claude/commands/progress
```

**Update:**
```
/progress:update
```
Or from the terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/readikus/progress/main/install.sh | bash
```

**Uninstall:**
```bash
rm -rf ~/.claude/commands/progress ~/.progress
```

</details>

---

## Why

Engineers tend to undersell themselves. You spend a week deep in a gnarly migration, untangling race conditions, or fixing that one bug that took three days to reproduce — and when it comes time for the sprint demo or your annual review, you shrug and say "not much, just some fixes." The fiddly, tedious work that keeps systems running gets forgotten first, even though it's often the most valuable.

Progress is a Claude Code skill that makes sure none of that gets lost. It scans your git history, groups commits into meaningful themes, and generates reports tailored to your audience — so the work you actually did gets the credit it deserves.

Set it up once. It remembers your repos, your team context, and what you care about highlighting.

---

## Commands

| Command | What it does | Default Period |
|---------|--------------|----------------|
| `/progress:onboard` | Set up or update your profile (repos, audiences, highlights) | — |
| `/progress:standup` | Concise standup summary | Last day |
| `/progress:sprint` | Sprint demo with metrics and comparisons | Last sprint |
| `/progress:review` | Detailed personal review with trends and full commit log | Last quarter |
| `/progress:metrics` | Colorful CLI dashboard with period-over-period comparisons | Last week |
| `/progress:update` | Update Progress to the latest version | — |

All report commands accept period overrides: `/progress:standup last 3 days`, `/progress:sprint since feb 20`, `/progress:review last 6 months`

Language adapts automatically — technical detail for engineering teams, business impact and plain language for stakeholders and leadership.

---

### `/progress:standup`

Concise bullet-point summary for daily standups.

```
/progress:standup                  # What you did today
/progress:standup last 3 days      # Override period
/progress:standup since monday     # Natural language works
```

Output:
```
## Standup Update — last day

**Done:**
- Implemented user auth flow (5 commits across auth-service)
- Fixed pagination bug in search results
- Reviewed 2 PRs on payments-api

**In Progress:**
- Checkout flow refactor (WIP commits on feature branch)
```

---

### `/progress:sprint`

Narrative summary with metrics table and period-over-period comparisons. Built for sprint demos and team presentations.

```
/progress:sprint                   # Last sprint
/progress:sprint last 3 weeks      # Override period
```

Output includes:
- **Metrics table** with deltas vs last sprint (commits, PRs, LOC)
- **What was delivered** — narrative paragraph with context
- **Technical improvements** — refactors, performance, tests
- **Collaboration** — reviews, mentorship
- **Codebase impact** — which areas saw the most activity

---

### `/progress:review`

Detailed personal review with full metrics, categorized breakdown, trends, and complete commit log. For self-tracking and performance reviews.

```
/progress:review                   # Last quarter
/progress:review last 6 months     # Override period
/progress:review since jan 1       # Annual review
```

Output includes:
- **Metrics with trends** across multiple periods
- **Work breakdown** — features, bug fixes, refactoring, tests, infra, reviews
- **Hotspots** — most-modified files
- **Activity patterns** — busiest days/weeks
- **Full commit log** grouped by date

---

### `/progress:metrics`

Standalone colorful CLI dashboard — no report, just the numbers. Compares 4 consecutive periods with proportional bar charts and trend arrows.

```
/progress:metrics                  # Last week vs previous 3 weeks
/progress:metrics last 2 weeks     # Override period
/progress:metrics last sprint      # Uses your sprint length
```

Output (rendered with ANSI colors in your terminal):
```
  PROGRESS METRICS
  Ian Read  |  Comparing 4 x 1 week periods

  COMMITS
  This period    ████████████████████  42     ▲ +34% vs avg
  Prev 1         ██████████████        28
  Prev 2         ████████████████      35
  Prev 3         ██████████            18
                                  avg: 27

  LINES ADDED
  This period    ████████████████      1,204  ▲ +12% vs avg
  ...
  ──────────────────────────────────────
  Net lines: +891  |  Commits/day: 6.0  |  Top repo: next-app
```

The metrics dashboard also appears inline at the end of `/progress:standup`, `/progress:sprint`, and `/progress:review` — comparing against previous periods of the same length.

---

## Onboarding

`/progress:onboard` asks a few quick questions — most are auto-detected from your git config:

1. **Name** — for report headers
2. **Git author** — to filter commits
3. **Repos** — which repos to scan
4. **Sprint length** — your sprint cadence (default: 2 weeks)
5. **Standup audience** — who hears your standups (e.g., engineering team, mixed)
6. **Sprint demo audience** — who sees demos (e.g., stakeholders, product team)
7. **Review audience** — who reads reviews (e.g., engineering manager, CTO, just you)
8. **Highlights** — what you want to showcase (features, refactoring, mentorship, etc.)
9. **Context** — team name, project info, role, anything that helps write better summaries

Audience settings shape the language of each report — technical detail for engineers, business impact and plain language for stakeholders.

Saved to `~/.progress/profile.json`. Run `/progress:onboard` again anytime to update.

---

## How It Works

### 1. Profile — remember preferences

`/progress:onboard` saves your settings to `~/.progress/profile.json`. Every report command reads this so you never repeat yourself.

### 2. Gather — scan git history

Each command runs `git log` across your configured repos, filtered by your author name and the report's time period. If GitHub CLI (`gh`) is available, it also pulls PR and review data.

### 3. Analyze — group and contextualize

Commits are grouped into themes (features, fixes, refactors) using commit messages, file paths, and PR titles. Your highlight preferences and team context shape what gets surfaced.

### 4. Format — tailor to audience

Output is formatted for the specific audience — bullet points for standups, narrative + metrics for sprint demos, full data dump for reviews. Language adapts based on who's reading: technical detail for engineers, business impact and plain language for stakeholders.

### 5. Track — save for comparisons

Metrics are saved to `~/.progress/history/` so future reports can show trends and period-over-period deltas.

---

## Configuration

Everything stays local on your machine:

```
~/.progress/
  profile.json                # Your preferences (from /progress:onboard)
  history/                    # Metrics snapshots for trend comparisons
    2026-03-05-standup.json
    2026-02-26-sprint.json
    2026-01-01-review.json
  repo/                       # Cloned skill repo (if installed via curl)
```

### Profile fields

| Field | Set during | What it does |
|-------|-----------|--------------|
| `name` | Onboarding | Name used in report headers |
| `git_author` | Onboarding | Filters `git log --author` |
| `repos` | Onboarding | Repos to scan (+ current directory always included) |
| `periods.standup` | Auto | Default: "1 day" |
| `periods.sprint` | Onboarding | Default: "2 weeks" (your sprint length) |
| `periods.review` | Auto | Default: "3 months" |
| `audiences.standup` | Onboarding | Who hears your standup (shapes technical depth) |
| `audiences.sprint` | Onboarding | Who sees sprint demos (technical vs business language) |
| `audiences.review` | Onboarding | Who reads reviews (manager vs self-tracking) |
| `highlight_areas` | Onboarding | What to prioritize in summaries |
| `notes` | Onboarding | Free-text context (team, project, role) |

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Git
- GitHub CLI (`gh`) — optional, enables PR and review data

---

<div align="center">

**Stop cobbling together updates from memory. Let your git history speak for itself.**

</div>
