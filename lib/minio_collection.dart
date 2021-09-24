import 'dart:async';

import 'package:minio_client_dart/collection_service.dart';
import 'package:minio_client_dart/convertable_Item.dart';
import 'package:minio_client_dart/socket_service.dart';

class MinioCollection<E extends ConvertableItem> {

  final List<E> _items;
  final ItemCreator<E> _creator;
  final SocketService _socketService;
  final CollectionService _collectionService;

  bool get isSynchronised => _socketService.isConnected; 

  MinioCollection(this._items, this._collectionService, this._socketService, this._creator) {
    _init();
  }

  void _init() {
    _socketService.connect(E.toString().toLowerCase());

    _socketService.subscribeOnConnected((data) {
      print("Socket connected...");
    });

    _socketService.subscribeOnDisconnected((data) {
      print("Socket disconnected...");
    });
  }

  E operator [] (int index) {
    return _items[index];
  }

  Future<void> add(E value) async {
    final result = await _collectionService.addItemToCollection(value, _creator);
    if(result.isValid()) {
      _items.add(result);
    } else {
      throw Exception("Invalid result");
    }
  }

  Future<bool> remove(Object value) async {
    return _items.remove(value);
  }

  bool any(bool Function(E element) test) {
    return _items.any(test);
  }

  Iterable<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  bool contains(Object element) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  E elementAt(int index) {
    // TODO: implement elementAt
    throw UnimplementedError();
  }

  bool every(bool Function(E element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  // TODO: implement first
  E get first => throw UnimplementedError();

  E firstWhere(bool Function(E element) test, {E Function() orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  Iterable<E> followedBy(Iterable<E> other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  void forEach(void Function(E element) action) {
    // TODO: implement forEach
  }

  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  // TODO: implement iterator
  Iterator<E> get iterator => throw UnimplementedError();

  String join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  // TODO: implement last
  E get last => throw UnimplementedError();

  E lastWhere(bool Function(E element) test, {E Function() orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  // TODO: implement length
  int get length => throw UnimplementedError();

  Iterable<T> map<T>(T Function(E e) toElement) {
    // TODO: implement map
    throw UnimplementedError();
  }

  E reduce(E Function(E value, E element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  // TODO: implement single
  E get single => throw UnimplementedError();

  E singleWhere(bool Function(E element) test, {E Function() orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  Iterable<E> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  Iterable<E> skipWhile(bool Function(E value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  Iterable<E> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  Iterable<E> takeWhile(bool Function(E value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  List<E> toList({bool growable = true}) {
    // TODO: implement toList
    throw UnimplementedError();
  }

  Set<E> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  Iterable<E> where(bool Function(E element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  Iterable<T> whereType<T>() {
    // TODO: implement whereType
    throw UnimplementedError();
  }

  void subscribeOnSynchronisationLost(Function callback) {
    _socketService.subscribeOnDisconnected(callback);
  }

  void subscribeOnSynchronisationEstablished(Function callback) {
    _socketService.subscribeOnConnected(callback);
  }

}