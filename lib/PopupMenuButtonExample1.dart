
import 'package:flutter/material.dart';

class PopupMenuButtonExample1 extends StatefulWidget {
  const PopupMenuButtonExample1({Key? key}) : super(key: key);

  @override
  _PopupMenuButtonExample1State createState() =>
      _PopupMenuButtonExample1State();
}

class _PopupMenuButtonExample1State extends State {
  var selectedItem = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AppMaking.com"),
        centerTitle: true,
        actions: [
          PopupMenuButton(onSelected: (value) {
            // your logic
            setState(() {
              selectedItem = value.toString();
            });
            print(value);
            Navigator.pushNamed(context, value.toString());
          }, itemBuilder: (BuildContext bc) {
            return const [
              PopupMenuItem(
                child: Text("Hello"),
                value: '/hello',
              ),
              PopupMenuItem(
                child: Text("About"),
                value: '/about',
              ),
              PopupMenuItem(
                child: Text("Contact"),
                value: '/contact',
              )
            ];
          })
        ],
      ),
      body: Center(
        child: Text(selectedItem),
      ),
    );
  }
}