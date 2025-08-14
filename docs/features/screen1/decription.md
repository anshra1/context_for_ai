Screen Initialization
✅ UI Layout & Components:
📁 Select Directory Button
📨 Drag & Drop Area (accepts folders only)
🕘 Recent Workspaces List
💡 (Optionally shows toast/snackbars for errors)
🎯 User Actions & Flows:

User Clicks "Select Directory"
Triggers: pickDirectory()
Result: Folder selected → validates → loads → navigates to FileNavigationScreen
If invalid: show toast/snackbar → “Invalid Folder”
Data Source: OS File Picker + validation

User Drops Item on Drop Area
Triggers: onDrop(item)

Check: Is folder?
❌ If file or invalid → show toast "Not a valid folder"
✅ If valid folder → show loading → navigate to FileNavigationScreen

User Taps on Recent Workspace
Triggers: loadWorkspace(path)
Data Source: Local DB (loadFolderHistory())
If exists → go to FileNavigationScreen
If invalid → show toast/snackbar
📦 Dynamic Data Source
Recent workspace list is loaded on screen init from Local DB (via loadFolderHistory())
🚫 Error Handling
If invalid folder → Show toast/snackbar → "Folder not found"
If recent workspace folder is deleted → Show fallback UI or retry