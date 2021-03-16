import 'package:flutter/material.dart';
import 'package:shopping_list/dbhelper.dart';
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/models/shopping_list.dart';
import 'package:shopping_list/ui/list_item_dialog.dart';

class ItemsScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  const ItemsScreen({Key key, this.shoppingList}) : super(key: key);

  @override
  _ItemsScreenState createState() => _ItemsScreenState(this.shoppingList);
}

class _ItemsScreenState extends State<ItemsScreen> {
  final ShoppingList shoppingList;
  DBHelper helper;

  _ItemsScreenState(this.shoppingList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
      ),
      body: FutureBuilder<List<ListItem>>(
        future: helper.getItems(shoppingList.id),
        builder: (context, snapshot) {
          if(snapshot.hasData){
          return ListView.builder(
              itemCount: (snapshot.data != null) ? snapshot.data.length : 0,
              itemBuilder: (BuildContext context, int i) {
                return Dismissible(
                  key: Key(snapshot.data[i].id.toString()),
                  onDismissed: (direction) async {
                    String strName = snapshot.data[i].name;
                    await helper.deleteItem(snapshot.data[i]);
                    setState(() {
                      snapshot.data.removeAt(i);
                    });
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("$strName deleted")));
                  },
                  child: ListTile(
                    title: Text(snapshot.data[i].name),
                    subtitle: Text(
                        'Quantity: ${snapshot.data[i].quantity} - Note: ${snapshot.data[i].note}'),
                    onTap: () {},
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                ListItemDialog().buildDialog(context, snapshot
                                    .data[i]));
                        setState(() {});
                      },
                    ),
                  ),
                );
              });

          } else {
            return Container();
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) => ListItemDialog().buildDialog(
                  context, ListItem(0, shoppingList.id, '', '', ''), isNew: true));
          setState(() {});
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this.helper = DBHelper();
  }
}
