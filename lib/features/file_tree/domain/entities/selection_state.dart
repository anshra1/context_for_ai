enum SelectionState {
  unchecked,    // Not selected
  checked,      // Fully selected  
  intermediate, // Partially selected (some children selected)
}

extension SelectionStateExtension on SelectionState {
  bool get isSelected => this == SelectionState.checked || this == SelectionState.intermediate;
  bool get isFullySelected => this == SelectionState.checked;
  bool get isPartiallySelected => this == SelectionState.intermediate;
  bool get isUnchecked => this == SelectionState.unchecked;

  /// Get checkbox value for tristate checkbox
  bool? get checkboxValue {
    switch (this) {
      case SelectionState.checked:
        return true;
      case SelectionState.unchecked:
        return false;
      case SelectionState.intermediate:
        return null; // Tristate checkbox shows indeterminate
    }
  }

  /// Toggle selection state (unchecked <-> checked, intermediate -> checked)
  SelectionState toggle() {
    switch (this) {
      case SelectionState.unchecked:
      case SelectionState.intermediate:
        return SelectionState.checked;
      case SelectionState.checked:
        return SelectionState.unchecked;
    }
  }
}