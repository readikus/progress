# Progress

A Claude Code skill that summarizes your development work from git history, tailored for different audiences.

Stop repeating yourself every standup. Progress remembers your preferences, scans your repos, and generates reports in seconds.

## Install

One command:

```bash
curl -fsSL https://raw.githubusercontent.com/readikus/progress/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/readikus/progress.git ~/.progress/repo
ln -sf ~/.progress/repo/commands/progress ~/.claude/commands/progress
```

## Usage

First time, run onboarding to set your preferences (repos, report style, highlights):

```
/progress:onboard
```

Then generate reports:

```
/progress:standup              # Concise bullet points for daily standups
/progress:sprint               # Narrative + metrics for sprint demos
/progress:review               # Detailed breakdown for self-tracking
```

Override the time period with arguments:

```
/progress:standup last 2 weeks
/progress:sprint since feb 20
/progress:review last month
```

Re-run onboarding anytime to update preferences:

```
/progress:onboard
```

## What it does

- Scans git history across multiple repos you configure
- Pulls PR data via GitHub CLI (optional)
- Groups commits into meaningful themes (features, fixes, refactors)
- Formats output for your audience: standup, sprint, or personal review
- Tracks metrics history locally for period-over-period comparisons
- Remembers your preferences after a one-time setup

## What gets stored

Everything stays local on your machine:

```
~/.progress/
  profile.json                # Your preferences (created by /progress:onboard)
  history/                    # Metrics snapshots for trend comparisons
    2026-03-05-standup.json
    2026-02-26-sprint.json
  repo/                       # Cloned skill repo (if installed via curl)
```

## Uninstall

```bash
rm -rf ~/.claude/commands/progress ~/.progress
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Git
- GitHub CLI (`gh`) — optional, enables PR and review data
