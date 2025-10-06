MaterialApp
└── Scaffold
    ├── AppBar
    │   └── Text("Workspace Screen")
    └── Padding
        └── Column
            ├── SizedBox(height: 24)
            ├── TextButton
            │   └── Row
            │       ├── Icon(Icons.folder)
            │       └── Text("Select a Directory")
            ├── SizedBox(height: 32)
            ├── DragTarget<FileSystemEntity>
            │   └── Container
            │       └── Column
            │           ├── Icon(Icons.arrow_downward)
            │           ├── Text("Drag & Drop Folder or File(s) Here")
            │           └── Text("(Detects only valid directories with supported files — .dart, .ts, .java, etc.)")
            ├── SizedBox(height: 32)
            └── Column
                ├── Text("Recent Workspaces")
                ├── Divider()
                └── Column
                    ├── TextButton
                    │   └── Text("/Users/ansh/dev/myproject1")
                    ├── TextButton
                    │   └── Text("/Users/ansh/Desktop/ai-prompt-extractor")
                    └── TextButton
                        └── Text("/home/ansh/temp/")