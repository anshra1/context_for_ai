class ClipboardDataSource {
  ClipboardDataSource();

  Future<void> copyToClipboard(String content) async {
    throw UnimplementedError();
  }

  bool _isContentValid(String content) {
    throw UnimplementedError();
  }

  int _getContentSizeInMB(String content) {
    throw UnimplementedError();
  }

  String _sanitizeContent(String content) {
    throw UnimplementedError();
  }

  Future<bool> isClipboardAvailable() async {
    throw UnimplementedError();
  }

  bool _isPlatformSupported() {
    throw UnimplementedError();
  }

  bool _hasClipboardPermissions() {
    throw UnimplementedError();
  }
}
