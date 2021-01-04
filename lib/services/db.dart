// import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import './globals.dart';

class Document<T> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String path;
  DocumentReference ref;

  Document({this.path}) {
    ref = _db.doc(path);
  }

  Future<T> getData() {
    return ref.get().then((v) => Global.models[T](v.data(), v.id) as T);
  }

  Stream<T> streamData() {
    return ref.snapshots().map((v) => Global.models[T](v.data(), v.id) as T);
  }

  Future<void> upsert(Map data) {
    return ref.set(Map<String, dynamic>.from(data), SetOptions(merge: true));
  }
}

class Collection<T> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String path;
  CollectionReference ref;

  Collection({this.path}) {
    ref = _db.collection(path);
  }

  Stream<List<T>> get collectionStream {
    return _auth.authStateChanges().switchMap((user) {
      if (user != null) {
        Collection<T> collec = Collection<T>(path: '$path');
        return collec.streamData();
      } else {
        return Stream<List<T>>.value(null);
      }
    });
  }

  Future<List<T>> getData() async {
    var snapshots = await ref.get();
    return snapshots.docs
        .map((doc) => Global.models[T](doc.data(), doc.id) as T)
        .toList();
  }

  Future<List<T>> getDataOrdered() async {
    var snapshots = await ref.orderBy('name').get();
    return snapshots.docs
        .map((doc) => Global.models[T](doc.data(), doc.id) as T)
        .toList();
  }

  Stream<List<T>> streamData() {
    return ref.snapshots().map((list) => list.docs
        .map((doc) => Global.models[T](doc.data(), doc.id) as T)
        .toList());
  }

  Future<DocumentReference> add(Map data) {
    return ref.add(Map<String, dynamic>.from(data));
  }

  Future<void> upsertInBatch(List<String> ids, Map data) {
    final batchWrite = _db.batch();
    ids.forEach((id) {
      batchWrite.set(ref.doc('$id'), Map<String, dynamic>.from(data),
          SetOptions(merge: true));
    });
    return batchWrite.commit();
  }
}

class SubCollection<T> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection;
  final String document;
  final String subcollection;
  CollectionReference ref;

  SubCollection({this.collection, this.document, this.subcollection}) {
    ref = _db.collection(collection).doc(document).collection(subcollection);
  }

  Future<List<T>> getData() async {
    var snapshots = await ref.get();
    return snapshots.docs
        .map((doc) => Global.models[T](doc.data(), doc.id) as T)
        .toList();
  }

  Future<List<T>> getDataOrderedByDate() async {
    var snapshots = await ref.orderBy("date", descending: true).get();
    return snapshots.docs
        .map((doc) => Global.models[T](doc.data(), doc.id) as T)
        .toList();
  }

  Stream<List<T>> streamData() {
    return ref.snapshots().map((list) => list.docs
        .map((doc) => Global.models[T](doc.data(), doc.id) as T)
        .toList());
  }

  Future<DocumentReference> add(Map data) {
    return ref.add(Map<String, dynamic>.from(data));
  }

  Future<void> upsertInBatchItemsOrdered(List<String> ids) {
    final batchWrite = _db.batch();
    ids.forEach((id) {
      batchWrite.set(
          ref.doc('$id'),
          Map<String, dynamic>.from({
            'count': FieldValue.increment(1),
            'lastOrdered': FieldValue.serverTimestamp()
          }),
          SetOptions(merge: true));
    });
    return batchWrite.commit();
  }
}

class UserData<T> {
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String collection;

  UserData({this.collection});

  Stream<T> get documentStream {
    return /* Observable */ _auth.authStateChanges().switchMap((user) {
      if (user != null) {
        Document<T> doc = Document<T>(path: '$collection/${user.uid}');
        return doc.streamData();
      } else {
        return Stream<T>.value(null);
      }
    }); //.shareReplay(maxSize: 1).doOnData((d) => print('777 $d'));// as Stream<T>;
  }

  Future<T> getDocument() async {
    User firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      Document doc = Document<T>(path: '$collection/${firebaseUser.uid}');
      return doc.getData();
    } else {
      return null;
    }
  }

  Future<void> upsert(Map data) {
    User firebaseUser = _auth.currentUser;
    Document<T> ref = Document(path: '$collection/${firebaseUser.uid}');
    return ref.upsert(data);
  }
}
