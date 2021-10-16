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

  MinioCollection(
      this._items, this._collectionService, this._socketService, this._creator);

  E operator [](int index) {
    return _items[index];
  }

  Future<E> add(E value) async {
    final result =
        await _collectionService.addItemToCollection(value, _creator);
    if (result.isValid()) {
      _items.add(result);
      return result;
    } else {
      throw Exception("Invalid result");
    }
  }

  Future<E> update(E value) async {
    final result = await _collectionService.updateItemFromCollection(
        value, value.id, _creator);
    if (result.isValid()) {
      _items.add(result);
      return result;
    } else {
      throw Exception("Invalid result");
    }
  }

  Future<bool> removeFromId(String id) async {
    final result =
        await _collectionService.removeItemFromCollection(id, _creator);
    if (result.isValid()) {
      _items.removeWhere((item) => item.id == id);
      return true;
    } else {
      throw Exception("Invalid result");
    }
  }

  Future<bool> remove(Object value) async {
    final result =
        await _collectionService.removeItemFromCollection(value, _creator);
    if (result.isValid()) {
      return _items.remove(value);
    } else {
      throw Exception("Invalid result");
    }
  }

  bool any(bool Function(E element) test) {
    return _items.any(test);
  }

  Iterable<R> cast<R>() {
    return _items.cast<R>();
  }

  bool contains(Object element) {
    return _items.contains(element);
  }

  E elementAt(int index) {
    return _items.elementAt(index);
  }

  bool every(bool Function(E element) test) {
    _items.every(test);
  }

  Iterable<T> expand<T>(Iterable<T> Function(E element) toElements) {
    return _items.expand(toElements);
  }

  // TODO: implement first
  E get first => _items.first;

  E firstWhere(bool Function(E element) test, {E Function() orElse}) {
    return _items.firstWhere(test, orElse: orElse);
  }

  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    return _items.fold(initialValue, combine);
  }

  Iterable<E> followedBy(Iterable<E> other) {
    return _items.followedBy(other);
  }

  void forEach(void Function(E element) action) {
    _items.forEach(action);
  }

  // TODO: implement isEmpty
  bool get isEmpty => _items.isEmpty;

  // TODO: implement isNotEmpty
  bool get isNotEmpty => _items.isNotEmpty;

  // TODO: implement iterator
  Iterator<E> get iterator => _items.iterator;

  String join([String separator = ""]) {
    return _items.join(separator);
  }

  // TODO: implement last
  E get last => _items.last;

  E lastWhere(bool Function(E element) test, {E Function() orElse}) {
    return _items.lastWhere(test, orElse: orElse);
  }

  // TODO: implement length
  int get length => _items.length;

  Iterable<T> map<T>(T Function(E e) toElement) {
    return _items.map(toElement);
  }

  E reduce(E Function(E value, E element) combine) {
    return _items.reduce(combine);
  }

  // TODO: implement single
  E get single => _items.single;

  E singleWhere(bool Function(E element) test, {E Function() orElse}) {
    return _items.singleWhere(test, orElse: orElse);
  }

  Iterable<E> skip(int count) {
    return _items.skip(count);
  }

  Iterable<E> skipWhile(bool Function(E value) test) {
    return _items.skipWhile(test);
  }

  Iterable<E> take(int count) {
    return _items.take(count);
  }

  Iterable<E> takeWhile(bool Function(E value) test) {
    return _items.takeWhile(test);
  }

  List<E> toList({bool growable = true}) {
    return _items.toList(growable: growable);
  }

  Set<E> toSet() {
    return _items.toSet();
  }

  Iterable<E> where(bool Function(E element) test) {
    return _items.where(test);
  }

  Iterable<T> whereType<T>() {
    return _items.whereType<T>();
  }

  void subscribeOnSynchronisationLost(Function callback) {
    _socketService.subscribeOnDisconnected(callback);
  }

  void subscribeOnSynchronisationEstablished(Function callback) {
    _socketService.subscribeOnConnected(callback);
  }
}
