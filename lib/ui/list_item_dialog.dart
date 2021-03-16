import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list/dbhelper.dart';
import 'package:shopping_list/models/list_item.dart';

class ListItemDialog {
  final textName = TextEditingController();
  final textQuantity = TextEditingController();
  final textNote = TextEditingController();
  final helper = DBHelper();

  Widget buildDialog(BuildContext context, ListItem item,
      {bool isNew = false}) {
    if (!isNew) {
      textName.text = item.name;
      textQuantity.text = item.quantity.toString();
      textNote.text = item.note;
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      title: Text((isNew) ? 'New List Item' : 'Edit List Item'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: textName,
              decoration: InputDecoration(hintText: 'Item name'),
            ),
            TextField(
              controller: textQuantity,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Item quantity'),
            ),
            TextField(
              controller: textNote,
              decoration: InputDecoration(hintText: 'Item note'),
            ),
            RaisedButton(
                child: Text('Save'),
                onPressed: () => _submit(context, item))
          ],
        ),
      ),
    );
  }

  void _submit(context, item) async {
    item.name = textName.text;
    item.quantity = textQuantity.text;
    item.note = textNote.text;
    await helper.insertItem(item);
    _clear();
    Navigator.pop(context);
  }

  void _clear() {
    textName.clear();
    textQuantity.clear();
    textNote.clear();
  }
}
