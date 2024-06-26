

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyPageFul();
  }

}

class EmptyPageFul extends StatefulWidget {
  const EmptyPageFul({super.key});

  @override
  State<StatefulWidget> createState() {
    return EmptyPageState();
  }
}

class EmptyPageState extends State<EmptyPageFul> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: FlutterLogo(
            size: 50
        ),
      ),
    );
  }

}