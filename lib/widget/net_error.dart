import 'package:flutter/material.dart';

class NetErrorWidget extends StatelessWidget {
  final VoidCallback callback;

  NetErrorWidget({@required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        alignment: Alignment.center,
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 40,
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              '点击重新请求',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            )
          ],
        ),
      ),
    );
  }
}
