class FileInfoModel {
  FileInfoModel({required this.name}) {
    size = 0.0;
    createdTime = DateTime.now();
    lastUpdate = DateTime.now();
  }
  String name;
  late DateTime lastUpdate;
  late DateTime createdTime;
  late double size;
}
