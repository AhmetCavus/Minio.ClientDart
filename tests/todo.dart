import 'package:minio_client_dart/convertable_Item.dart';

import 'category.dart';

class Todo extends ConvertableItem {
  final String id;
  final String title;
  final String description;
  final DateTime creationDate;
  final bool isDone;
  final Category category;

  Todo(Map<String, dynamic> json)
      : id = json["_id"],
        title = json["title"],
        description = json["description"],
        creationDate = json["creationDate"] != null
            ? DateTime.tryParse(json["creationDate"])
            : DateTime.fromMicrosecondsSinceEpoch(0),
        isDone = json["isDone"],
        category = Category(json);

  Todo.Init(this.id, this.title, this.description, this.creationDate,
      this.isDone, this.category);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'creationDate': creationDate.toIso8601String(),
        'isDone': isDone,
        'category': category.toJson()
      };
}
