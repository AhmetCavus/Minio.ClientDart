import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:minio_client_dart/auth_service.dart';
import 'package:minio_client_dart/channel_service.dart';
import 'package:minio_client_dart/collection_service.dart';
import 'package:minio_client_dart/minio_client.dart';
import 'package:minio_client_dart/socket.events.dart';
import 'package:minio_client_dart/socket_service.dart';
import 'package:openapi/api.dart';
import 'package:test/test.dart';

import 'category.dart';
import 'profile.dart';

final _token = "eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYxM2RhZGIxYWNmZjcwZDM5ZjAxNWQxYyIsIm5hbWUiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW4iLCJpYXQiOjE2MzIzMTM1NzQsImV4cCI6MTYzMjM5OTk3NH0.j8zKP1Gn5hvGkohJqNEYd9dTXR05xu9vkKPGLBYtVuV8kOkX7mag7U6dnsgzFq9d";


void main() async {
  // group("authentication", ()  {
  //   test("get token", () {
  //     var minioClient = MinioClient();
  //     var future = minioClient.authenticate("admin", "admin");
  //     future.then((result) {
  //       print(result.token);
  //     });
  //   });
  // });
  // group("collection", () {
    // test("get collection", () {
    //   var minioClient = MinioClient();
    //   minioClient.setAuthToken(_token);
    //   var collFuture = minioClient.requestCollection<Category>((decoded) => Category(decoded));
    //   collFuture.then((result) {
    //     print(result);
    //   });
    // });
    // var random = Random();
    // var id = "id${random.nextInt(1000)}";
    // test("post item to collection", () {
    //     var minioClient = MinioClient();
    //     minioClient.setAuthToken(_token);
    //     var newBody = Category.Init(id, "name${random.nextInt(1000)}", "description${random.nextInt(1000)}", "https://lorempicsum.com/300");
    //     var collFuture = minioClient.addItemToCollection<Category>(newBody, (decoded) => new Category(decoded));
    //     collFuture.then((result) {
    //       print(result);
    //     });
    //   });
    // test("add item from collection", () async {
    //     final minioClient = MinioClient.init("http://localhost:8080");
    //     final authResult = await minioClient.authenticate("admin", "admin");
    //     final collection = await minioClient.requestCollection<Category>((decoded) => Category(decoded));
    //     await collection.add(Category.Init("id${Random.secure().nextInt(1001)}", "Ahmet Cavus", "description...", "https://lorem.picsum/300"));
    //     await Future.delayed(Duration(seconds: 30));
    //     print("Test finished");
    //   });
  // });
    final minioClient = MinioClient.init("http://localhost:8080");
    await minioClient.authenticate("admin", "admin");

    await minioClient.subscribeForChannel("test");
    minioClient.broadcast({"message": "Hello", "from": "admin"});

    // final categories = await minioClient.requestCollection<Category>((decoded) => Category(decoded));
    // final profiles = await minioClient.requestCollection<Profile>((decoded) => Profile(decoded));
    
    // await categories.add(Category.Init("id${Random.secure().nextInt(1001)}", "Ahmet Cavus", "description...", "https://lorem.picsum/300"));
    // await profiles.add(Profile.Init("id${Random.secure().nextInt(1001)}", "Ahmet Cavus", "cavus.ahmet@outlook.com", "admin", true, DateTime.now(), "testtest"));
    minioClient.subscribeForBroadcasts((data) {
      print(data);
    });
    minioClient.subscribeOn(SOCKET.EVENT_RECEIVE_PRIVATE_MESSAGE, (data) {
      print(data);
    });
    await Future.delayed(Duration(seconds: 30));
    print("Test finished");
}

