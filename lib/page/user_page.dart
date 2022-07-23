import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning_firebase/model/user.dart';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDate = TextEditingController();

  Future createUser({required User user}) async {
    // Reference to document
    final docUser = FirebaseFirestore.instance.collection("users").doc();
    user.id = docUser.id;

    final json = user.toJson();
    await docUser.set(json);
  }

  Future updateUser() async {
    // Reference to document
    final docUser = FirebaseFirestore.instance.collection("users").doc('jFTIfzFskgVz5tXFRCkG');

    // Update specific fields
    // docUser.update({
    //   'name': "tuan anh"
    // });
    // docUser.update({
    //   'city.country': "England",
    //   'city.name': "Lon don"
    // });
    // docUser.update({
    //   'city.name': FieldValue.delete()
    // });
    // docUser.update({
    //   'city': FieldValue.delete()
    // });
    // docUser.set({
    //   'name': "tuan anh"
    // });

    docUser.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add text'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: controllerName,
            decoration: decoration("Name"),
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controllerAge,
            decoration: decoration("Age"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          DateTimeField(
            controller: controllerDate,
            decoration: decoration("Birthday"),
            format: DateFormat("yyyy-MM-dd"),
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                initialDate: currentValue ?? DateTime.now(),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // final user = User(
              //   name: controllerName.text,
              //   age: int.parse(controllerAge.text),
              //   birthday: DateTime.parse(controllerDate.text),
              // );
              // createUser(user: user);
              // Navigator.pop(context);

              updateUser();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  InputDecoration decoration(String labelText) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      labelText: labelText,
      suffixIcon: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.clear),
      ),
    );
  }
}
