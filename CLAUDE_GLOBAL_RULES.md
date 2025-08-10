# Claude Global Project Rules

## ⚠️ **CRITICAL SAFETY RULE - DELETE CONFIRMATION REQUIRED**

### **Mandatory Delete Protection**
**Before performing ANY of the following actions, Claude MUST stop and request explicit "delete" confirmation:**

- Deleting any files or directories
- Removing existing code blocks or functions
- Modifying existing files in destructive ways
- Clearing or resetting data/configurations
- Overwriting existing content
- Running destructive commands (rm, git reset --hard, etc.)

**Process:**
1. Claude identifies a destructive action is needed
2. Claude STOPS and explains what will be deleted/modified
3. Claude asks: "Type 'delete' to confirm this action"
4. User MUST type exactly "delete" (case-insensitive)
5. Only then can Claude proceed with the destructive action

**This rule applies GLOBALLY across ALL projects and sessions.**

---

## 🎯 **Core Development Principles**

### **Project Structure & Architecture**
- Always follow clean architecture principles (data/domain/presentation layers)
- Use repository pattern for data abstraction
- Implement proper dependency injection
- Create modular, testable code with clear separation of concerns

### **Code Quality Standards**
- Write comprehensive method signatures before implementation
- Use TODO placeholders for systematic development tracking
- Follow consistent naming conventions across all files
- Implement proper error handling and validation
- Never commit code that doesn't compile or breaks existing functionality

### **File Management**
- ALWAYS prefer editing existing files over creating new ones
- Never create documentation files unless explicitly requested
- Use meaningful file and class names that reflect their purpose
- Organize imports consistently and remove unused imports
- Create comprehensive folder structures upfront for complex features

### **State Management & Architecture**
- Use Cubit/BLoC for state management in Flutter projects
- Implement proper state immutability with copyWith methods
- Create separate state classes for complex state management
- Handle loading, success, and error states consistently
- Use proper stream management to prevent memory leaks

### **Development Workflow**
- Use TodoWrite tool proactively for task tracking and progress visibility
- Break complex features into implementable phases
- Create complete method signatures before implementation
- Test critical functionality before considering tasks complete
- Always run lint/type checking before committing changes

### **Git & Version Control**
- Write descriptive, professional commit messages
- Use conventional commit format when appropriate
- Never commit build files, dependencies, or temporary files
- Create proper .gitignore files for each project type
- Use meaningful branch names for feature development

### **Communication & Documentation**
- Be concise and direct in responses
- Minimize output tokens while maintaining quality
- Provide code without unnecessary explanations unless requested
- Use structured markdown for complex explanations
- Focus on the specific task at hand without tangential information

### **Flutter-Specific Rules**
- Use proper Widget lifecycle management
- Implement responsive UI designs
- Follow Material Design or Cupertino guidelines consistently
- Use proper asset management and resource optimization
- Implement proper navigation patterns (GoRouter preferred)

### **Error Handling & Debugging**
- Implement comprehensive error handling at all layers
- Use proper logging for debugging without exposing sensitive data
- Create user-friendly error messages
- Handle edge cases and null safety properly
- Implement proper validation for user inputs

### **Performance & Optimization**
- Consider memory management in long-running operations
- Use proper async/await patterns
- Implement lazy loading for large datasets
- Optimize UI rendering with proper Widget rebuilding
- Use efficient data structures and algorithms

## 🚀 **Implementation Standards**

### **Before Starting Any Feature:**
1. Create complete folder structure
2. Define all class interfaces with method signatures
3. Set up proper dependency injection
4. Create TODO placeholders for systematic development
5. Use TodoWrite tool to track implementation phases

### **During Development:**
1. Implement one layer at a time (data → domain → presentation)
2. Test each component before moving to the next
3. Update TodoWrite tool progress regularly
4. Handle errors gracefully at every step
5. Follow established patterns from existing code

### **Before Completion:**
1. Run all linting and type checking tools
2. Test critical user flows
3. Update TodoWrite tool to mark tasks complete
4. Remove TODO placeholders only when fully implemented
5. Ensure proper documentation is in place

## 📋 **Project-Specific Adaptations**

These rules should adapt based on project context:
- **Mobile Apps**: Focus on responsive design and performance
- **Web Apps**: Emphasize SEO and accessibility
- **APIs**: Prioritize security and proper HTTP responses  
- **Desktop Apps**: Consider platform-specific UI patterns
- **Libraries**: Focus on API design and comprehensive documentation

## ⚡ **Quick Reference Checklist**

Before completing any task:
- [ ] Code follows clean architecture
- [ ] All method signatures are complete
- [ ] TodoWrite tool shows current progress
- [ ] Error handling is implemented
- [ ] Imports are organized and clean
- [ ] No build/debug files in commits
- [ ] Linting passes without errors
- [ ] Functionality has been tested
- [ ] Code is documented appropriately
- [ ] Git commit message is descriptive

---

## 🔧 **How to Use This Globally**

To make these rules apply to ALL your projects:

### **Option 1: Global Claude Code Settings**
Add to your global Claude Code configuration:
```json
{
  "rules": {
    "architecture": "clean_architecture_required",
    "state_management": "cubit_bloc_preferred", 
    "task_tracking": "todowrite_required",
    "file_management": "edit_over_create",
    "commit_quality": "descriptive_messages_required"
  }
}
```

### **Option 2: Copy to Every Project**
Copy this `CLAUDE_GLOBAL_RULES.md` file to the root of every project you work on.

### **Option 3: Environment Variable**
Set a global environment variable that Claude can reference:
```bash
export CLAUDE_GLOBAL_RULES_PATH="/path/to/CLAUDE_GLOBAL_RULES.md"
```

*This ensures consistent, high-quality development practices across ALL your projects while maintaining flexibility for project-specific requirements.*