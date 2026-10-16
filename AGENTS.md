# U19-pipeline-matlab

The MATLAB side of the U19 DataJoint pipeline: schemas, the scheduled tasks that
run on Windows, and the utilities ViRMEn uses on the rigs. Needs DataJoint for
MATLAB (`dj_initial_conf(1)` once, then `connect_datajoint00`).

## Tests

MATLAB unit tests live in `tests/` (`matlab.unittest`). `TestBehaviorPopulate`
needs a test database (via `Prep`); the scheduled-task tests don't. With the repo
on the path, run e.g. `runtests('tests/TestScheduledTaskLogging.m')`.

Lint: `uvx prek run --all-files` (the same as CI's Lint workflow). The hooks only look for secrets,
merge-conflict markers, workflow problems and the AI trailer; nothing reformats
MATLAB files.

## Pins and gotchas

- Batch and MATLAB scripts that run on Windows keep CRLF line endings.
- Slack webhooks belong in the `lab.SlackWebhooks` table, not in code. Old ones
  remain in git history.

## Agent workflow

- Bugs: always log them. Before fixing an error, whether the user reported it in Slack or you found it while working, file an agent bug report issue from the user's account (`gh issue create -R BrainCOGS/U19-pipeline-matlab`, template `.github/ISSUE_TEMPLATE/agent_bug_report.md`). Put the error exactly as the user pasted it under **Reported error**; don't ask for or invent a Slack link. Then fix it with the `bugfix-from-slack` skill (agent-tooling); the PR says `Fixes #<issue>`. Commits, pushes, issues and PRs all go through the user's account.
- Commits end with one `Assisted-by: <Harness>:<model>` trailer per agent, e.g. `Assisted-by: ClaudeCode:claude-opus-5-5`. No AI co-authors, and no `Generated with` lines. `prek install` sets up the `ai-attribution` commit-msg hook (`.github/scripts/check_ai_attribution.py`, vendored from agent-tooling), and CI checks every commit of a PR.
- PRs target `master` on `BrainCOGS/U19-pipeline-matlab`, opened from the user's own account.
