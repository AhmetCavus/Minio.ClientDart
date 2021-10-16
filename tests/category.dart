import 'package:minio_client_dart/convertable_Item.dart';

class Category extends ConvertableItem {
  final String id;
  final String name;
  final String description;
  final String image;

  Category(Map<String, dynamic> json)
      : id = json["_id"],
        name = json["name"],
        description = json["description"],
        image = json["image"];

  Category.Init(this.id, this.name, this.description, this.image);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'description': description, 'image': image};
}
