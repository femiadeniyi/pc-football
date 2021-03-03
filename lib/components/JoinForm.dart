import 'package:flutter/material.dart';

class JoinForm extends StatelessWidget {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Football Form"),
      actions: [
        TextButton(
          child: Text('Approve'),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              Navigator.pop(context, _controller.text);
            }
          },
        ),
      ],
      content: Form(
          key: _formKey,
          child: Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                      labelText: "Football Name", hintText: 'Enter your football name'),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }

                    return null;
                  },
                ),
              ),
            ]),
          )),
    );
  }
}

