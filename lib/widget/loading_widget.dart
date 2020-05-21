import 'package:flutter/material.dart';

/// 播放音乐的加载组件
class MusicLoading extends StatefulWidget {
  final String text;
  final EdgeInsets margin;

  MusicLoading({
    this.text = '努力加载中...',
    this.margin = const EdgeInsets.only(top: 60),
  }) : super();

  @override
  _MusicLoadingState createState() => _MusicLoadingState();
}

class _MusicLoadingState extends State<MusicLoading> with SingleTickerProviderStateMixin{
  AnimationController _controller;
  Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..repeat();
    _animation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              String frame = _animation.value.toString();
              return Image.asset(
                'images/music_loading_$frame.png',
                gaplessPlayback: true,
                width: 16,
                height: 16,
              );
            },
          ),
          SizedBox(
            width: 12,
          ),
          Text(widget.text, style: TextStyle(fontSize: 13, color: Colors.grey),)
        ],
      ),
    );

  }
}

