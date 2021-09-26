import 'dart:async';
import 'dart:math';

import 'package:minio_client_dart/minio_client.dart';
import 'package:minio_client_dart/minio_collection.dart';
import 'package:minio_client_dart/socket.events.dart';
import 'package:test/test.dart';

import '../category.dart';

void main() async {
  final minioClient = MinioClient.init("http://localhost:8080");
  MinioCollection<Category> categories;
  
  group("minio client integration tests", (){
    group("authentication", ()  {
        test("get token", () async {
          var token = await minioClient.authenticate("admin", "admin");
          print(token.data);
          expect(token, isNotNull);
          expect(token.data, isNotEmpty);
        });
      });

      group("subscriptions", () {
        test("subscribe for necessary events", () {
          minioClient.subscribeForBroadcasts((data) {
            print("Broadcast: $data");
          });
          minioClient.subscribeOn(SOCKET.EVENT_RECEIVE_PRIVATE_MESSAGE, (data) {
            print("Private message: $data");
          });
          minioClient.subscribeOn(SOCKET.EVENT_COLLECTION_ADD_ITEM, (data) {
            print("Add item: $data");
          });
          minioClient.subscribeOn(SOCKET.EVENT_COLLECTION_REMOVE_ITEM, (data) {
            print("Remove item: $data");
          });
        });
      });

      group("collection", () {
        test("get collection", () async {
          categories = await minioClient.requestCollection<Category>((decoded) => Category(decoded));
          expect(categories, isNotNull);
        });

        var random = Random();
        var id = "id${random.nextInt(1000)}";
        var newCategory = Category.Init(id, "name${random.nextInt(1000)}", "description${random.nextInt(1000)}", "https://lorempicsum.com/300");
        var addCategoryResult;
        
        test("post item to collection", () async {
            addCategoryResult = await categories.add(newCategory);
            expect(addCategoryResult, isNotNull);
          });
        test("remove item from collection", () async {
            await categories.removeFromId(addCategoryResult.id);
          });
      });

      group("sockets", () {
        test("subscribe to channel and broadcast", () async {
          minioClient.broadcast({"message": "Hello", "from": "admin"});
          await Future.delayed(Duration(seconds: 10));
        });
      });
  });
  
  tearDownAll(() {
    minioClient.dispose();
  });
}

