import 'dart:math';

import 'package:minio_client_dart/minio_client.dart';
import 'package:minio_client_dart/minio_collection.dart';
import 'package:minio_client_dart/socket.events.dart';
import 'package:test/test.dart';

import '../category.dart';
import '../todo.dart';

void main() async {
  final minioClient = MinioClient.init("http://localhost:8080");
  MinioCollection<Todo> todos;
  MinioCollection<Category> categories;

  group("minio client integration tests", () {
    group("authentication", () {
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
        todos = await minioClient.requestCollection<Todo>(
            (decoded) => Todo(decoded),
            schema: "todo");
        categories = await minioClient.requestCollection<Category>(
            (decoded) => Category(decoded),
            schema: "category");
        expect(todos, isNotNull);
      }, timeout: Timeout(Duration(seconds: 60)));

      // var random = Random();
      // var id = "id${random.nextInt(1000)}";
      // var newTodo = Todo.Init(
      //     id,
      //     "name${random.nextInt(1000)}",
      //     "description${random.nextInt(1000)}",
      //     DateTime.now(),
      //     false,
      //     Category.Init("id", "name", "description", "image"));

      // var newCategory = Category.Init(id, "name${random.nextInt(1000)}",
      //     "description${random.nextInt(1000)}", "https://picsum.photos/300");
      // Category addCategoryResult;
      // Todo addTodoResult;
      // Todo updatedTodoResult;

      // test("post item to collection", () async {
      //   addTodoResult = await todos.add(newTodo);
      //   expect(addTodoResult, isNotNull);
      // });
      // test("post item to collection", () async {
      //   addCategoryResult = await categories.add(newCategory);
      //   expect(addTodoResult, isNotNull);
      // });
      // test("update item from collection", () async {
      //   final toUpdate = Todo.Init(
      //       addTodoResult.id,
      //       "addTodoResult.title updated",
      //       "addTodoResult.description updated",
      //       DateTime.now(),
      //       true,
      //       addCategoryResult);
      //   updatedTodoResult = await todos.update(toUpdate);
      //   expect(updatedTodoResult, isNotNull);
      // });
      // test("remove item from collection", () async {
      //   await todos.removeFromId(addTodoResult.id);
      // });
    });

    // group("sockets", () {
    //   test("subscribe to channel and broadcast", () async {
    //     minioClient.broadcast({"message": "Hello", "from": "admin"});
    //     await Future.delayed(Duration(seconds: 60));
    //   });
    // });
  });

  tearDownAll(() {
    minioClient.dispose();
  });
}
