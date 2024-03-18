import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  int? id;
  String? name;

  String? image;

  int? pricet;
  String? mainCat;
  String? subCat;
  Todo(
      {this.id, this.name, this.image, this.pricet, this.mainCat, this.subCat});

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
        id: map['id'],
        name: map['name'],
        pricet: map['price'],
        image: map['image'],
        mainCat: map['maincat'],
        subCat: map["subcat"]
        //  subcat: map['subcat'],
        //  subsubcat: map['subsubcat']);
        );
  }

  Map<String, dynamic> tojson() {
    return {
      'id': id,
      'name': name,
      'price': pricet,
      'image': image,
      'maincat': mainCat,
      'subcat': subCat
      //  'subcat': subcat,
      //    'subsubcat': subsubcat
    };
  }
}

class Admin {
  String? id;
  DocumentReference? reference;

  Admin({
    this.id,
    this.reference,
  });

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(id: map['id'], reference: map['ref']);
  }

  Map<String, dynamic> tojson() {
    return {'id': id, 'ref': reference};
  }
}
