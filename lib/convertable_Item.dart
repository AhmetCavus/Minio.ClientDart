abstract class ConvertableItem {
  String get id;
  Map<String, dynamic> toJson();
  bool isValid();
}