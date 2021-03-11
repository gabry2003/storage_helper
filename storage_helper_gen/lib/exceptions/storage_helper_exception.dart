/// Custom StorageHelper's exception
class StorageHelperException implements Exception {
  /// Message
  late String msg;

  StorageHelperException(msg) {
    this.msg = "${DateTime.now().toString()}\n[StorageHelperException]\n$msg";
  }
}