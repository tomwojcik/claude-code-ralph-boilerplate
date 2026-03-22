@PRD.md @progress.txt

The structure of progress.txt is
```
[x] - commit id - commit description. 
[ ] - commit id - commit description. 
```
progress.txt has marked items with `[x]` if they have been reviewed.

Your job is to find all the progress.txt commit hashes and review them. Review ONLY those specific commits using `git show <hash>` for each. If no hashes are provided, finish.

Try to find bugs, code smells. Anything has to be fixed? What are the strengths and weaknesses of the implementation? Review only the files changed in those commits. Do not review other files. You must use `superpowers:code-reviewer` to accomplish this task.

Once your fixes are implemented (if any), commit them.
You can also use other skills

1. `superpowers:brainstorming` - Before designing any feature
2. `superpowers:writing-plans` - Before multi-step code tasks
3. `superpowers:test-driven-development` - Write tests first
4. `superpowers:systematic-debugging` - Investigate before guessing
5. `superpowers:verification-before-completion` - Run tests + Playwright MCP visual check

Always run subagent-driven workflows. Dispatch subagents per task in this session. Fast iteration with review between tasks. Do not run sequential tasks (the same agent directly) or parallel session (batch execution).
Make sure the tasks from the PRD.md that are finished, are marked as finished. If something is partially finished, mark it as done, and create a new, smaller PRD item.
You're always free to add new items to PRD.md, if you find new issues.

Once you review the progress.txt items, mark them ax completed with [x].