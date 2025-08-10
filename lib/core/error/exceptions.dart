// class FileSystemException implements Exception {
//   final String message;
//   final String? code;
//   final dynamic originalError;

//   const FileSystemException({
//     required this.message,
//     this.code,
//     this.originalError,
//   });

//   @override
//   String toString() => 'FileSystemException: $message';
// }

// class PermissionException implements Exception {
//   final String message;
//   final String path;

//   const PermissionException({
//     required this.message,
//     required this.path,
//   });

//   @override
//   String toString() => 'PermissionException: $message (Path: $path)';
// }

// class NotFoundPathException implements Exception {
//   final String message;
//   final String path;

//   const NotFoundPathException({
//     required this.message,
//     required this.path,
//   });

//   @override
//   String toString() => 'NotFoundPathException: $message (Path: $path)';
// }

// class CacheException implements Exception {
//   final String message;

//   const CacheException(this.message);

//   @override
//   String toString() => 'CacheException: $message';
// }