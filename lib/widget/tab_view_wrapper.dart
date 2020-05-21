
import 'package:flutter/material.dart';

class TabViewWrapper extends StatelessWidget {
  final Widget child;

  TabViewWrapper({ this.child }) : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 48 + MediaQuery.of(context).padding.top,
        ),
        Expanded(
          child: child,
        )
      ],
    );
  }
}
