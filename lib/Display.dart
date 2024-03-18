import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailing/Todo.dart';
import 'package:mailing/main.dart';

class TodoScreen extends StatelessWidget {
  final CollectionReference prodCollectionRef;

  TodoScreen({required this.prodCollectionRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: fetchTodoStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          List<Todo>? todos = snapshot.data;

          if (todos == null || todos.isEmpty) {
            return Center(
              child: Text('No todos found.'),
            );
          }

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  title: Text(
                    todo.name.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                      } else if (value == 'delete') {
                        await FirebaseFirestore.instance
                            .collection('admin')
                            .doc(user!.uid)
                            .collection('prod')
                            .doc('${todo.id}')
                            .delete()
                            .whenComplete(() {
                          print('complete');
                        });
                        await FirebaseFirestore.instance
                            .collection('product')
                            .doc('${todo.id}')
                            .delete()
                            .whenComplete(() {
                          print('complete');
                        });
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Row(
                            children: [Icon(Icons.delete), Text('delete')],
                          ),
                          value: 'delete',
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [Icon(Icons.edit), Text('Edit')],
                          ),
                          value: 'edit',
                        ),
                      ];
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Price: ${todo.pricet}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Category: ${todo.mainCat}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Subcategory: ${todo.subCat}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Add onTap functionality here
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<List<Todo>> fetchTodoStream() {
    return prodCollectionRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var admin = Admin.fromMap(doc.data() as Map<String, dynamic>);
        return admin.reference!.get().then((productSnapshot) {
          var productData = productSnapshot.data() as Map<String, dynamic>;
          return Todo.fromMap(productData);
        });
      }).toList();
    }).asyncMap((futures) => Future.wait(futures));
  }
}
