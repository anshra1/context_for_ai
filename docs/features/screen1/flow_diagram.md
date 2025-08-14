flowchart TD
A[📁 Workspace Selector Screen]:::ui --> B{{loadFolderHistory from DB}}:::dataSource
B --> C[📋 Show Recent Workspaces List                                        ]:::ui
B -->|Error| T1[⚠️ Toast: Invalid folder history]:::error
%% Select Directory Flow
A --> D[👆 Tap 'Select Directory' Button]:::ui
D --> E{{pickDirectory from FilePicker}}:::dataSource
E -->|Valid Folder| E1[💾 Save to Recent Workspaces DB]:::dataSource
E1 --> F[📦 Navigate to File Navigation Screen]:::navigation
E -->|Invalid Folder| T2[⚠️ Toast: Invalid folder selected]:::error
%% Drag and Drop Flow
A --> G[📂 Drop Item in Drop Area]:::ui
G --> H{{handleDrop from FileSystem}}:::dataSource
H -->|Is Folder| H1[💾 Save to Recent Workspaces DB]:::dataSource
H1 --> I[📦 Navigate to File Navigation Screen]:::navigation
H -->|Not a Folder| T3[⚠️ Toast: Only folders allowed]:::error
%% Recent Workspace Open
C --> J[👆 Tap on Recent Workspace Item]:::ui
J --> K{{loadWorkspace from DB}}:::dataSource
K -->|Valid| K1[📦 Navigate to File Navigation Screen]:::navigation
K -->|Invalid| T4[⚠️ Toast: Workspace not found]:::error
%% Delete Recent Workspace
C --> L[🗑 Tap Delete Icon on Recent Workspace]:::ui
L --> M{{removeFromRecentDB}}:::dataSource
M --> M1[🧹 Refresh List UI]:::ui
%% Mark Favorite
C --> N[⭐ Tap Favorite Icon on Recent Workspace]:::ui
N --> O{{markAsFavoriteInDB}}:::dataSource
O --> O1[⬆ Move to Top in List UI]:::ui
%% DB Connections
B -.-> DB1([🧠 Local DB]):::dataSource
E1 -.-> DB1
H1 -.-> DB1
K -.-> DB1
M -.-> DB1
O -.-> DB1
%% File Picker/OS References
E -.-> FS1([📂 OS File Picker]):::dataSource
H -.-> FS1
%% Highlight Screens
classDef navigation fill:#cce5ff,stroke:#2a80b9,stroke-width:2px;
classDef ui fill:#d4edda,stroke:#2f9e44,stroke-width:2px;
classDef logic fill:#ffeeba,stroke:#d39e00,stroke-width:2px;
classDef dataSource fill:#d6d8d9,stroke:#343a40,stroke-width:2px;
classDef error fill:#f8d7da,stroke:#c82333,stroke-width:2px;
classDef success fill:#e2d9f3,stroke:#6f42c1,stroke-width:2px;
class A,C,D,G,J,L,N,M1,O1 ui
class B,E,E1,H,H1,K,M,O,DB1,FS1 dataSource
class T1,T2,T3,T4 error
class F,I,K1 navigation