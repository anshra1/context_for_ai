import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/file_explorer_cubit.dart';
import '../../data/models/export_preview.dart';
import '../../data/models/app_settings.dart';

class ExportPreviewPage extends StatelessWidget {
  final ExportPreview exportPreview;
  final AppSettings appSettings;
  
  const ExportPreviewPage({
    Key? key,
    required this.exportPreview,
    required this.appSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Add export statistics display
            Text('Selected Files: ${exportPreview.selectedFileCount}'),
            Text('Estimated Tokens: ${exportPreview.estimatedTokenCount}'),
            Text('Size: ${exportPreview.estimatedSizeInMB.toStringAsFixed(2)} MB'),
            Text('Parts: ${exportPreview.estimatedPartsCount}'),
            
            // TODO: Add token warning if exceeds limit
            if (exportPreview.willExceedTokenLimit)
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Warning: Export exceeds token limit'),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // TODO: Add file list preview
            const Text('Selected Files:'),
            Expanded(
              child: ListView.builder(
                itemCount: exportPreview.selectedFilePaths.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(exportPreview.selectedFilePaths[index]),
                    leading: const Icon(Icons.description),
                  );
                },
              ),
            ),
            
            // TODO: Add action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement clipboard export
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy to Clipboard'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement file export
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save to File'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}