import 'package:flutter/material.dart';
import 'package:netease_cloud_music/widget/loading_widget.dart';

import 'net_error.dart';

typedef ValueWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T value,
);

/// FutureBuilder 简单封装，除正确返回和错误外，其他返回加载中
class CustomFutureBuilder extends StatefulWidget {
  final ValueWidgetBuilder builder;
  final Function futureFunc;
  final Widget loadingWidget;
  final double defaultHeight;

  CustomFutureBuilder({
    @required this.futureFunc,
    @required this.builder,
    Widget loadingWidget,
    this.defaultHeight
  }) : loadingWidget = loadingWidget ?? MusicLoading();

  @override
  _CustomFutureBuilderState createState() => _CustomFutureBuilderState();
}

class _CustomFutureBuilderState extends State<CustomFutureBuilder> {
  Future _future;

  @override
  void initState() {
    super.initState();
    _future = widget.futureFunc();
  }

  @override
  void didUpdateWidget(CustomFutureBuilder oldWidget) {
    if (oldWidget.futureFunc != widget.futureFunc) {
      setState(() {
        _future = widget.futureFunc();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _future == null
      ? widget.loadingWidget
      : FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (widget.defaultHeight != null) {
                return SizedBox(
                  height: widget.defaultHeight,
                  child: widget.loadingWidget,
                );
              }
              return widget.loadingWidget;
            case ConnectionState.done:
              if (snapshot.hasData) {
                return widget.builder(context, snapshot.data);
              } else if (snapshot.hasError) {
                return NetErrorWidget(
                  callback: () {
                    setState(() {
                      _future = widget.futureFunc();
                    });
                  },
                );
              }
          }
          if (widget.defaultHeight != null) {
            return SizedBox(
              height: widget.defaultHeight,
            );
          }
          return Container();
        },
      );
  }
}
