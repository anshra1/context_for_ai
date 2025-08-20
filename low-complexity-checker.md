# Low Complexity Checker

A utility to analyze and validate code complexity in Dart projects.

## Features

- **Cyclomatic Complexity Analysis**: Measures the complexity of methods and classes
- **Line Count Metrics**: Tracks lines of code per method/class
- **Maintainability Index**: Calculates overall code maintainability score
- **Threshold Validation**: Configurable complexity thresholds
- **Report Generation**: Detailed complexity reports

## Usage

```dart
import 'package:context_for_ai/utils/low_complexity_checker.dart';

final checker = LowComplexityChecker();
final result = await checker.analyzeFile('lib/my_file.dart');

if (result.isValid) {
  print('Code meets complexity requirements');
} else {
  print('Complexity violations found: ${result.violations}');
}
```

## Configuration

```dart
final config = ComplexityConfig(
  maxCyclomaticComplexity: 10,
  maxLinesPerMethod: 50,
  maxLinesPerClass: 200,
  minMaintainabilityIndex: 70,
);

final checker = LowComplexityChecker(config: config);
```

## Complexity Metrics

### Cyclomatic Complexity
Measures the number of linearly independent paths through a program's source code.

- **1-10**: Simple, easy to test
- **11-15**: Moderate complexity
- **16-20**: High complexity, difficult to test
- **21+**: Very high complexity, should be refactored

### Maintainability Index
A composite metric that considers:
- Cyclomatic complexity
- Lines of code
- Halstead complexity

Score ranges from 0-100, with higher scores indicating better maintainability.

## Best Practices

1. Keep methods under 10 cyclomatic complexity
2. Limit methods to 50 lines of code
3. Keep classes under 200 lines
4. Maintain a maintainability index above 70
5. Refactor when thresholds are exceeded