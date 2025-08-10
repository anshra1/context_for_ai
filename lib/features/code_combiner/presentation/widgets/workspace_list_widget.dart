import 'package:flutter/material.dart';
import '../../data/models/recent_workspace.dart';

class WorkspaceListWidget extends StatelessWidget {
  final List<RecentWorkspace> workspaces;
  final Function(String)? onWorkspaceSelected;
  final Function(String)? onWorkspaceRemoved;
  final Function(String)? onWorkspaceFavoriteToggled;
  
  const WorkspaceListWidget({
    Key? key,
    required this.workspaces,
    this.onWorkspaceSelected,
    this.onWorkspaceRemoved,
    this.onWorkspaceFavoriteToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Sort workspaces with favorites first
    final sortedWorkspaces = [...workspaces];
    sortedWorkspaces.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return b.lastAccessed.compareTo(a.lastAccessed);
    });
    
    return ListView.builder(
      itemCount: sortedWorkspaces.length,
      itemBuilder: (context, index) {
        final workspace = sortedWorkspaces[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            // TODO: Add workspace icon
            leading: Icon(
              workspace.isFavorite ? Icons.star : Icons.folder,
              color: workspace.isFavorite ? Colors.amber : Colors.blue,
            ),
            
            // TODO: Add workspace info
            title: Text(
              workspace.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workspace.path,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Last opened: ${_formatDate(workspace.lastAccessed)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            
            // TODO: Add selection callback
            onTap: () => onWorkspaceSelected?.call(workspace.path),
            
            // TODO: Add trailing actions
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: Add favorite toggle
                IconButton(
                  onPressed: () => onWorkspaceFavoriteToggled?.call(workspace.path),
                  icon: Icon(
                    workspace.isFavorite ? Icons.star : Icons.star_border,
                    color: workspace.isFavorite ? Colors.amber : Colors.grey,
                  ),
                  tooltip: workspace.isFavorite 
                      ? 'Remove from favorites' 
                      : 'Add to favorites',
                ),
                
                // TODO: Add remove button
                IconButton(
                  onPressed: () => _showRemoveConfirmation(context, workspace),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                  tooltip: 'Remove workspace',
                ),
              ],
            ),
            
            // TODO: Add visual indicator for favorites
            isThreeLine: true,
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  void _showRemoveConfirmation(BuildContext context, RecentWorkspace workspace) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Workspace'),
        content: Text('Remove "${workspace.name}" from recent workspaces?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onWorkspaceRemoved?.call(workspace.path);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}