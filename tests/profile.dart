
import 'package:minio_client_dart/convertable_Item.dart';

class Profile extends ConvertableItem{
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isOnline;
  final DateTime connectedSince;
  String password;

  Profile(Map<String, dynamic> json):
    id = json["_id"],
    name = json["name"],
    email = json["email"],
    role = json["role"],
    isOnline = json["isOnline"],
    connectedSince = json["connectedSince"] != null ? DateTime.tryParse(json["connectedSince"]) : DateTime.fromMicrosecondsSinceEpoch(0),
    password = json["password"];
  
  Profile.Init(this.id, this.name, this.email, this.role, this.isOnline, this.connectedSince, this.password);

  Map<String, dynamic> toJson() => {
    '_id' : id,
    'name': name,
    'email': email,
    'role': role,
    'isOnline': isOnline,
    'connectedSince': connectedSince.toIso8601String(),
    'password': password
  };

  @override
  bool isValid() => id.isNotEmpty;
}