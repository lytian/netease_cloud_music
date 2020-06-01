import 'package:flutter/material.dart';

typedef ItemWidgetBuilder = Widget Function(
    BuildContext context,
    int index,
    );

/// 横向分页式表格布局
class PaginationGridView extends StatefulWidget {
  /// 容器高度
  final double height;
  /// 子元素个数
  final int itemCount;
  /// 多少行
  final int crossAxisCount;
  /// 横向的分割间距
  final double crossAxisSpacing;
  /// 纵向的分割间距
  final double mainAxisSpacing;
  /// 子元素的比例
  final double childAspectRatio;
  /// 内间距
  final EdgeInsets padding;
  /// 单项构建方法
  final ItemWidgetBuilder builder;

  PaginationGridView({
    @required this.height,
    @required this.crossAxisCount,
    @required this.itemCount,
    @required this.builder,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.padding,
  });

  @override
  _PaginationGridViewState createState() => _PaginationGridViewState();
}

class _PaginationGridViewState extends State<PaginationGridView> {
  ScrollController _gridController = ScrollController();
  Offset _gridStartPosition;
  int _gridPage = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.height,
        child: Listener(
          onPointerDown: (event) {
            _gridStartPosition = event.position;
          },
          onPointerUp: (event) {
            double distance = _gridStartPosition.dx - event.position.dx;
            double screenWidth = (widget.height - widget.crossAxisSpacing * (widget.crossAxisCount - 1)) / (widget.crossAxisCount * widget.childAspectRatio) + widget.mainAxisSpacing;

            if (distance.abs() < 10) {
              // 滑动太短，保留当前页
              _gridController.animateTo(_gridPage * screenWidth, duration: Duration(milliseconds: 200), curve: Curves.linear);
            } else if (distance > 0) {
              // 下一页
              _gridPage++;
              _gridController.animateTo(_gridPage * screenWidth, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            } else if (distance < 0) {
              // 上一页
              _gridPage--;
              _gridController.animateTo(_gridPage * screenWidth, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
            }
          },
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            controller: _gridController,
            padding: widget.padding,
            itemCount: widget.itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,
                childAspectRatio: widget.childAspectRatio
            ),
            itemBuilder: (context, index) => widget.builder(context, index),
          ),
        )
    );
  }
}