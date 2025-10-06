---
config:
  layout: fixed
---
flowchart TD
    A(["Start: open folder path"]) -- read disk --> B{"Folder readable?"}
    B -- no --> C(["Toast: Permission denied"])
    B -- yes --> D["Show File Tree UI"]
    D --> E{"User interacts"}
    E -- click folder chevron --> F["toggleExpand"]
    E -- toggle checkbox --> G["toggleSelection and update memory state"]
    E -- add/remove filter --> H["applyFilter and re-render visible nodes"]
    G --> I{"File readable?"}
    I -- no --> J(["Toast: Skipped unreadable file"])
    I -- yes --> K["Update selection list"]
    E -- "tap Save .txt" --> L["exportToFile and read selected files"]
    L --> M{"All reads ok?"}
    M -- no --> N(["Toast: Export failed"])
    M -- yes --> O["Write combined.txt"]
    O --> P(["File saved"])
    E -- tap Copy --> Q["copyToClipboard and read selected files"]
    Q --> R{"All reads ok?"}
    R -- no --> S(["Toast: Copy failed"])
    R -- yes --> T["Copy to system clipboard"]
    T --> U(["Copied!"])
    E -- tap Preview --> V["navigateToPreview"]
    V --> W(["Open Preview Screen"])
     C:::error
     J:::error
     N:::error
     P:::success
     S:::error
     U:::success
     W:::nav
    classDef success fill:#d4edda,stroke:#155724
    classDef error  fill:#f8d7da,stroke:#721c24
    classDef nav    fill:#cce5ff,stroke:#004085
