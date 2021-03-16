import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list/dbhelper.dart';
import 'package:shopping_list/models/shopping_list.dart';

class ShoppingListDialog {
  final textName = TextEditingController();
  final textPriority = TextEditingController();
  final helper = DBHelper();

  Widget buildDialog(BuildContext context, ShoppingList list,
      {bool isNew = false}) {
    if (!isNew) {
      this.textName.text = list.name;
      this.textPriority.text = list.priority.toString();
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      title: Text((isNew) ? 'New Shopping List' : 'Edit Shopping List'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: textName,
              decoration: InputDecoration(hintText: 'List name'),
            ),
            TextField(
              controller: textPriority,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'List priority (1-3)'),
            ),
            RaisedButton(
                child: Text('Save'), onPressed: () => _submit(context, list))
          ],
        ),
      ),
    );
  }

  void _submit(context, list) async {
    list.name = textName.text;
    list.priority = int.parse(textPriority.text);
    await helper.insertList(list);
    _clear();
    Navigator.pop(context);
  }

  void _clear() {
    textName.clear();
    textPriority.clear();
  }
}
