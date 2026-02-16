Look at the locally commited changes that are not pushed yet. Try to find bugs, code smells. Anything has to be fixed? What are the strengths and weaknesses of the implementation? Be honest

Once the changes are implemented (if any), commit them

You should probably use superpowers:code-reviewer for reviewing the code. You can also use other skills, such as

1. `superpowers:brainstorming` - Before designing any feature
2. `superpowers:writing-plans` - Before multi-step code tasks
3. `superpowers:test-driven-development` - Write tests first
4. `superpowers:systematic-debugging` - Investigate before guessing
5. `superpowers:verification-before-completion` - Run tests + Playwright MCP visual check
6. Playwright MCP - `browser_navigate` to `http://localhost:1420`, `browser_snapshot`, `browser_click`

Always run subagent-driven workflows. Dispatch subagents per task in this session. Fast iteration with review between tasks. Do not run sequential tasks (the same agent directly) or parallel session (batch execution).

Once you're done, make sure you git push all the changes, even if you did not add any changes. At the end of your work the state must be clean.
