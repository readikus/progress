---
name: progress:onboard
description: Set up your progress reporting preferences (repos, report style, highlights)
allowed-tools:
  - Read
  - Bash
  - Write
  - Glob
  - Grep
---

# Progress: Onboarding

Set up your progress profile so future reports know your preferences without asking.

**User input:** $ARGUMENTS

---

## Step 1: Check Existing Profile

Read `~/.progress/profile.json`. If it exists, show the user their current settings and ask if they want to update them or start fresh.

---

## Step 2: Auto-Detect Defaults

Before asking questions, gather sensible defaults silently:

```bash
git config user.name
git config user.email
pwd
```

Also check if `gh` CLI is available:
```bash
gh auth status 2>&1
```

---

## Step 3: Interactive Setup

Ask the following questions **one at a time**, showing the auto-detected default in brackets. Accept the default if the user just presses enter / says "yes" / confirms.

**Q1 - Name**
"What name should I use in your reports?"
Default: [git config user.name]

**Q2 - Git author**
"What name or email should I filter git logs by? (used with `git log --author`)"
Default: [git config user.name]

**Q3 - Repos**
"Which repos should I scan? Give me absolute paths. I'll always include whichever repo you're in when you run the command."
Default: [current working directory]
Let them add multiple. Store as array.

**Q4 - Sprint length**
"How long are your sprints? (e.g., '1 week', '2 weeks')"
Default: "2 weeks"
This sets the default period for `/progress:sprint`.

**Q5 - Standup audience**
"Who's your standup audience? (e.g., 'engineering team', 'mixed technical and non-technical', 'just me')"
Default: "engineering team"
Explain: "This shapes the language — technical detail for engineers, outcomes and impact for mixed audiences."

**Q6 - Sprint demo audience**
"Who do you present sprint demos to? (e.g., 'product and engineering', 'stakeholders and leadership', 'whole company')"
Default: "product and engineering"
Explain: "For technical audiences I'll include implementation details. For non-technical audiences I'll focus on features delivered, business impact, and plain language."

**Q7 - Review audience**
"Who reads your performance reviews? (e.g., 'engineering manager', 'CTO', 'just me for self-tracking')"
Default: "engineering manager"
Explain: "This determines how much technical depth vs leadership/impact framing to use."

**Q8 - Highlight areas**
"What do you like to highlight in reports? Comma-separated. Examples: features, bug fixes, refactoring, mentorship, performance, testing, architecture, code reviews"
Default: "features, bug fixes, refactoring"

**Q9 - Context**
"Anything else I should know? Team name, project context, role — anything that helps me write better summaries. (optional, press enter to skip)"
Store as free text in `profile.notes`.

---

## Step 4: Save Profile

```bash
mkdir -p ~/.progress/history
```

Write to `~/.progress/profile.json`:
```json
{
  "name": "<name>",
  "git_author": "<author>",
  "repos": ["<path1>", "<path2>"],
  "periods": {
    "standup": "1 day",
    "sprint": "<sprint length from Q4>",
    "review": "3 months"
  },
  "audiences": {
    "standup": "<standup audience from Q5>",
    "sprint": "<sprint demo audience from Q6>",
    "review": "<review audience from Q7>"
  },
  "highlight_areas": ["<area1>", "<area2>"],
  "notes": "<free text or empty string>",
  "created": "<ISO date>",
  "updated": "<ISO date>"
}
```

Note: each report type has its own default period — standup covers the last day, sprint covers the sprint length, review covers a quarter. Users can always override with arguments.

---

## Step 5: Confirm

Show the saved profile in a readable format and confirm:

```
Profile saved to ~/.progress/profile.json

  Name:           Ian Read
  Git author:     Ian Read
  Repos:          /Users/ianread/Code/project-a
                  /Users/ianread/Code/project-b
  Report periods: standup = 1 day, sprint = 2 weeks, review = 3 months
  Audiences:      standup → engineering team
                  sprint  → stakeholders and leadership
                  review  → engineering manager
  Highlights:     features, bug fixes, refactoring
  Notes:          Payments team

You're all set. Try it out:
  /progress:standup   — what you did today/yesterday
  /progress:sprint    — your sprint summary
  /progress:review    — quarterly personal review

Override period with arguments: /progress:standup last 3 days
Update preferences anytime: /progress:onboard
```
