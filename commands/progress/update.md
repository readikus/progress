---
name: progress:update
description: Update Progress skill to the latest version
allowed-tools:
  - Bash
---

# Progress: Update

Update the Progress skill to the latest version from GitHub.

Run this command:

```bash
curl -fsSL https://raw.githubusercontent.com/readikus/progress/main/install.sh | bash
```

After it completes, tell the user:
"Updated. Restart Claude Code to pick up any new commands."
