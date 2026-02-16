@PRD.md @progress.txt

If something needs to be clarified, ask the user.
Always run subagent-driven workflows. Dispatch subagents per task in this session. Fast iteration with review between tasks. Do not run sequential tasks (the same agent directly) or parallel session (batch execution).

Pick up the next task.

1. Read progress.txt to see what is already done.
2. Find the highest-priority incomplete task from the PRD.
3. Implement it fully (write code + tests where applicable).
4. Run tests
5. Run type checks
6. If both pass, commit the changes with a descriptive commit message.
7. Append the completed task to progress.txt and commit that too.

ONLY WORK ON A SINGLE TASK. Do not start a second task.

### Required Skills (invoke before acting)

1. `superpowers:brainstorming` - Before designing any feature
2. `superpowers:writing-plans` - Before multi-step code tasks
3. `superpowers:test-driven-development` - Write tests first
4. `superpowers:systematic-debugging` - Investigate before guessing
5. `superpowers:verification-before-completion` - Run tests + Playwright MCP visual check
6. Playwright MCP - `browser_navigate` to `http://localhost:1420`, `browser_snapshot`, `browser_click`

**Schema-first rule:** Lead agent MUST define and commit all TypeScript interfaces BEFORE spawning agents. Shared interfaces are the contract.
