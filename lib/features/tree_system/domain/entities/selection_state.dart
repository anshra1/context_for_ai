enum SelectionState {
  /// File/folder is not selected
  unchecked,
  
  /// File/folder is fully selected
  checked,
  
  /// Folder has some but not all children selected
  intermediate,
}