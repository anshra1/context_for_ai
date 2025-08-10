abstract class ClipboardRepository {
  Future<void> copyToClipboard(String content);
  Future<bool> isClipboardAvailable();
}