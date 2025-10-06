# 📘 Documentation for `features/code_combiner/presentation/pages/file_explorer/pages/file_explorer_page.dart`

> Describe this module’s purpose, structure, and business logic here.1 Scaffold
    
    3    └─ child: Container
    4       └─ child: Column
    5          └─ children:
    6             ├─ Row (Header)
    7             │  ├─ child: Row (Title)
    8             │  │  └─ children:
    9             │  │     ├─ Icon(description)
   10             │  │     └─ Text('File Export')
   11             │  └─ child: Column (Info)
   12             │     └─ children:
   13             │        ├─ Text('# No. of Files')
   14             │        └─ Row
   15             │           └─ children:
   16             │              ├─ Icon(calculate)
   17             │              └─ Text('Token Estimate...')
   18             ├─ Divider
   19             ├─ Text('Filters')
   20             ├─ Row (Filter Input)
   21             │  └─ children:
   22             │     ├─ Expanded
   23             │     │  └─ child: TextField
   24             │     └─ ElevatedButton
   25             ├─ Wrap (Filter Tags)
   26             │  └─ children:
   27             │     ├─ Chip(label: Text('.dart'))
   28             │     ├─ Chip(label: Text('.yaml'))
   29             │     └─ Chip(label: Text('.json'))
   30             ├─ Row (Search Bar)
   31             │  └─ children:
   32             │     ├─ Expanded
   33             │     │  └─ child: TextField(prefixIcon: Icon)
   34             │     └─ TextButton('Clear All Selections')
   35             ├─ Expanded (File List)
   36             │  └─ child: Container
   37             │     └─ child: ListView.builder
   38             │        └─ itemBuilder: ListTile
   39             │           ├─ leading: Icon(folder)
   40             │           ├─ title: Text
   41             │           └─ trailing: Checkbox
   42             ├─ Divider
   43             └─ Center (Bottom Buttons)
   44                └─ child: Wrap
   45                   └─ children:
   46                      ├─ OutlinedButton.icon(icon: Icon,label: Text('Preview'))
   47                      ├─ ElevatedButton.icon(icon: Icon,label: Text('Copy to Clipboard'))
   48                      └─ ElevatedButton.icon(icon: Icon,label: Text('Save as .txt'))