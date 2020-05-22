import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:netease_cloud_music/models/profile.dart';
import 'package:netease_cloud_music/pages/main_page.dart';
import 'package:netease_cloud_music/provider/profile_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputPasswordPage extends StatefulWidget {
  final String phone;

  InputPasswordPage(this.phone);

  @override
  _InputPhonePageState createState() => _InputPhonePageState();
}

class _InputPhonePageState extends State<InputPasswordPage> {

  TextEditingController _textEditingController = TextEditingController();
  String _inputText = "";
  bool _submitLoading = false;

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
          children: <Widget>[
            TextField(
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              cursorColor: Theme.of(context).primaryColor,
              maxLength: 16,
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '请输入密码',
                suffix: Text('忘记密码', style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent
                ),)
              ),
              onChanged: (v) {
                setState(() {
                  _inputText = v;
                });
              },
              onSubmitted: (v) {
                submitLogin();
              },
            ),
            MaterialButton(
              minWidth: double.maxFinite,
              color: Theme.of(context).primaryColor,
              textColor: _submitLoading ? Colors.grey : Colors.white,
              disabledColor: Colors.grey[200],
              shape: StadiumBorder(),
              child: Text(_submitLoading ? '登录中...' : '登录', style: TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.normal
              )),
              onPressed: _inputText.length >= 6 ? submitLogin : null,
            )
          ],
        ),
      ),
    );
  }

  void submitLogin() {
    if (_submitLoading) return;
    if (_inputText.length < 6) {
      BotToast.showText(text: '请输入正确的密码');
      return;
    }
    setState(() {
      _submitLoading = true;
    });
    DioUtils.get('/login/cellphone', queryParameters: {
      "phone": widget.phone,
      "password": _inputText
    }).then((data) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Provider.of<ProfileProvider>(context, listen: false).setProfile(Profile.fromJson(data['profile']));
      await prefs.setString('userId', data['profile']['userId'].toString());
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
        return MainPage();
      }), (Route<dynamic> route) => false);
    }).catchError((e) {
      print(e.message);
    }).whenComplete(() {
      setState(() {
        _submitLoading = false;
      });
    });
  }
}
