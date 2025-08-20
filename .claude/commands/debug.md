# Debug Command

Help me debug this issue: $ARGUMENTS

## Analysis Steps
1. **Understand the Problem**: Analyze the error message, stack trace, or issue description
2. **Search Codebase**: Look for relevant files, functions, and related code
3. **Identify Root Cause**: Determine what's causing the issue
4. **Suggest Solution**: Provide specific fixes or recommendations
5. **Verify Fix**: If possible, test the solution

## Focus Areas
- Check for common Flutter/Dart issues (null safety, async/await, state management)
- Look for file path errors, missing imports, or dependency issues
- Analyze error logs and stack traces
- Review recent code changes that might have introduced the bug
- Consider data flow and state management patterns

## Output Format
Provide a clear explanation of:
- What the issue is
- Why it's happening  
- How to fix it
- Any preventive measures for the future

Please be thorough but concise in your analysis.

Please analyze and fix the GitHub issue: $ARGUMENTS.

Follow these steps:

1. Use `gh issue view` to get the issue details
2. Understand the problem described in the issue
3. Search the codebase for relevant files
4. Implement the necessary changes to fix the issue
5. Write and run tests to verify the fix
6. Ensure code passes linting and type checking
7. Create a descriptive commit message
8. Push and create a PR

Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.