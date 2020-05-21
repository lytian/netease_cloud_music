import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'input_phone.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin  {
  // 第一个外圈动画
  AnimationController _animationController1;
  Animation _opacityAnimation1;
  Animation _sizeAnimation1;
  // 第二个外圈动画
  AnimationController _animationController2;
  Animation _opacityAnimation2;
  Animation _sizeAnimation2;

  bool _angree = false;

  @override
  void initState() {
    super.initState();
    _animationController1 = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this
    )..addListener(() {
      setState(()=>{});
    });
    _opacityAnimation1 =  TweenSequence([
      TweenSequenceItem(
          tween: ConstantTween(0.0),
          weight: 10
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 90
      )
    ]).animate(CurvedAnimation(
        parent: _animationController1, curve: Interval(0.0, 0.4)));
    _sizeAnimation1 =  Tween(begin: 100.0, end: 320.0).animate(CurvedAnimation(
        parent: _animationController1, curve: Interval(0.15, 1)));
    _animationController1.repeat();

    _animationController2 = AnimationController(
        duration: Duration(seconds: 5),
        vsync: this
    )..addListener(() {
      setState(()=>{});
    });
    _opacityAnimation2 =  TweenSequence([
      TweenSequenceItem(
          tween: ConstantTween(0.0),
          weight: 90
      ),
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0),
          weight: 10
      )
    ]).animate(CurvedAnimation(
        parent: _animationController1, curve: Interval(0.0, 0.7)));
    _sizeAnimation2 =  Tween(begin: 120.0, end: 250.0).animate(CurvedAnimation(
        parent: _animationController2, curve: Interval(0.65, 1)));
    _animationController2.repeat();
  }

  @override
  void dispose() {
    _animationController1.dispose();
    _animationController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 360,
              child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Container(
                      width: _sizeAnimation1.value,
                      height: _sizeAnimation1.value,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffea072f).withOpacity(_opacityAnimation1.value), width: 0.5),
                          shape: BoxShape.circle
                      ),
                    ),
                    Container(
                      width: _sizeAnimation2.value,
                      height: _sizeAnimation2.value,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffe81238).withOpacity(_opacityAnimation2.value), width: 0.5),
                          shape: BoxShape.circle
                      ),
                    ),
                    Image.asset('images/logo_circle.png', height: 72,),
                  ]
              ),
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    if (!_angree) {
                      BotToast.showText(text: '请仔细阅读用户协议、隐私政策，并同意');
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return InputPhonePage();
                    }));
                  },
                  elevation: 0,
                  focusElevation: 0,
                  highlightElevation: 0,
                  hoverElevation: 0,
                  minWidth: double.infinity,
                  height: 42,
                  color: Colors.white,
                  textColor: Color(0xffDD001B),
                  child: Text('手机号登录', style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.normal
                  )),
                  shape: StadiumBorder(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: () {
                          },
                          child: Image.asset('images/login_wechat.png', width: 40),
                          shape: CircleBorder(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: () {
                          },
                          child: Image.asset('images/login_qq.png', width: 40),
                          shape: CircleBorder(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: () {
                          },
                          child: Image.asset('images/login_weibo.png', width: 40),
                          shape: CircleBorder(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: () {
                          },
                          child: Image.asset('images/login_yi.png', width: 40),
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      value: _angree,
                      checkColor: Colors.white,
                      activeColor: Colors.white.withOpacity(0.6),
                      onChanged: (val) {
                        setState(() {
                          _angree = val;
                        });
                      },
                    ),
                    Text('同意', style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        height: 1.25
                    )),
                    Text('《用户协议》', style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.25
                    )),
                    Text('《隐私政策》', style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.25
                    )),
                    Text('《儿童隐私政策》', style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.25
                    )),
                    Text('《天翼账号服务协议》', style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.25
                    )),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}