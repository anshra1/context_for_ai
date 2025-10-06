import 'package:flutter/material.dart';

class FilePathTile extends StatelessWidget {
  const FilePathTile({required this.filePath, required this.onTap, super.key});
  final String filePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          filePath,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}
