# Custom Agent Roster

Two lightweight mode-switch agents. Both are read-focused and cheap to invoke — invoke explicitly or describe your task and Claude will route appropriately.

## Agents

### code-reviewer
**Purpose**: Security-focused code review, configuration safety, production reliability  
**When to use**: After writing/modifying code, before committing, for config changes  
**Triggers**: "review this", "check for security issues", "is this config safe"  
**Specialization**: Configuration security (connection pools, timeouts, resource limits); real-world outage pattern detection

### debugger
**Purpose**: Root cause analysis for errors, test failures, unexpected behavior  
**When to use**: When encountering errors, failing tests, or mysterious bugs  
**Triggers**: "debug this error", "why is this failing", "investigate this issue"  
**Approach**: Capture error → isolate → minimal fix → verify

