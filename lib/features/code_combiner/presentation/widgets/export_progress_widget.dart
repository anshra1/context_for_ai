import 'package:flutter/material.dart';

class ExportProgressWidget extends StatelessWidget {
  final String message;
  final double? progress;
  final bool isCompleted;
  final String? errorMessage;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  
  const ExportProgressWidget({
    Key? key,
    required this.message,
    this.progress,
    this.isCompleted = false,
    this.errorMessage,
    this.onCancel,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: Add progress indicator
            if (!isCompleted && errorMessage == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
            
            // TODO: Add success icon
            if (isCompleted && errorMessage == null) ...[
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
            ],
            
            // TODO: Add error icon
            if (errorMessage != null) ...[
              const Icon(
                Icons.error,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
            ],
            
            // TODO: Add progress message
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            
            // TODO: Add error message
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            
            // TODO: Add progress bar if progress is available
            if (progress != null && !isCompleted && errorMessage == null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text('${(progress! * 100).toInt()}%'),
            ],
            
            const SizedBox(height: 16),
            
            // TODO: Add action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isCompleted && errorMessage == null && onCancel != null) ...[
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
                
                if (errorMessage != null && onRetry != null) ...[
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ],
                
                if (isCompleted) ...[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}