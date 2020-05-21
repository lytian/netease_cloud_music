import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'input_password.dart';

class InputPhonePage extends StatefulWidget {
  @override
  _InputPhonePageState createState() => _InputPhonePageState();
}

class _InputPhonePageState extends State<InputPhonePage> {
  TextEditingController _textEditingController = new TextEditingController();
  String _inputText = "";

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          })
        ,
        title: Text('手机号登录', style: TextStyle(
          color: Colors.black
        ),),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 12),
              child: Text('未注册手机号，登录后将自动创建账号', style: TextStyle(
                  color: Colors.grey
              )),
            ),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.phone,
              controller: _textEditingController,
              cursorColor: Theme.of(context).primaryColor,
              maxLength: 11,
              decoration: InputDecoration(
                hintText: '请输入手机号码',
                suffixIcon: _inputText.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Future.delayed(Duration(milliseconds: 100), () {
                        setState(() {
                          _inputText = "";
                          _textEditingController.clear();
                        });
                      });
                    }
                  )
                  : Container(
                    height: 20,
                    width: 20,
                  )
              ),
              onChanged: (v) {
                setState(() {
                  _inputText = v;
                });
              },
              onSubmitted: (v) {
                RegExp exp = RegExp(
                    r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
                if (!exp.hasMatch(v)) {
                  BotToast.showText(text: "请输入正确的手机号码");
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return InputPasswordPage(v);
                }));
              },
            )
          ]
        ),
      ),
    );
  }
}
