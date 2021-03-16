import 'package:flutter/material.dart';
import 'package:shopping_list/dbhelper.dart';
import 'package:shopping_list/ui/items_screen.dart';
import 'package:shopping_list/ui/shopping_list_dialog.dart';

import '../models/shopping_list.dart';

class ShList extends StatefulWidget {
  @override
  _ShListState createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  DBHelper helper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
      ),
      body: FutureBuilder<List<ShoppingList>>(
          future: helper.getLists(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: (snapshot.data != null) ? snapshot.data.length : 0,
                  itemBuilder: (context, i) {
                    return Dismissible(
                      key: Key(snapshot.data[i].id.toString()),
                      onDismissed: (direction) async {
                        String strName = snapshot.data[i].name;
                        await helper.deleteList(snapshot.data[i]);
                        setState(() {
                          snapshot.data.removeAt(i);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("$strName deleted")));
                      },
                      child: ListTile(
                        title: Text(snapshot.data[i].name),
                        leading: CircleAvatar(
                          child: Text(snapshot.data[i].priority.toString()),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ShoppingListDialog().buildDialog(
                                      context, snapshot.data[i]);
                                });
                            setState(() {});
                          },
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemsScreen(
                                      shoppingList: snapshot.data[i],
                                    ))),
                      ),
                    );
                  });
            } else {
              return Container();
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) => ShoppingListDialog()
                  .buildDialog(context, ShoppingList(0, '', 0), isNew:
              true));
          setState(() {});
        },
      ),
    );
  }

}
