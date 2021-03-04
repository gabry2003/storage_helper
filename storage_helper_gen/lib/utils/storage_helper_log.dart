/// Print [msg] to screen with actually timestamp and "StorageHelperGenerator"
void storageHelperLog(String msg) {
  print(DateTime.now().toString());
  print("[StorageHelperGenerator]\n$msg");
}