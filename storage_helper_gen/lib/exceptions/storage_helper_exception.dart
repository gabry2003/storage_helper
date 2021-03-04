/// Custom StorageHelper's exception
class StorageHelperException implements Exception {
  /// Message
  String msg;

  StorageHelperException(msg) {
    this.msg = "${DateTime.now().toString()}\n[StorageHelperException]\n$msg";
  }
}