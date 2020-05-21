import 'package:flutter/material.dart';

/// 音乐列表的圆角头
class MusicListHeader extends StatelessWidget implements PreferredSizeWidget {
  MusicListHeader({this.count, this.content, this.tail, this.onTap});
  final int count;
  final Widget content;
  final Widget tail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    // 添加内容
    if (this.content != null) {
      children.add(this.content);
    } else {
      children.addAll(<Widget>[
        Icon(
          Icons.play_circle_outline,
          size: 28,
        ),
        SizedBox.fromSize(
          size: Size.fromWidth(8),
        ),
        Text(
          "播放全部",
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ]);

      // 添加总计
      if (this.count != null) {
        children.add(SizedBox.fromSize(
          size: Size.fromWidth(5),
        ));
        children.add(Text(
          "(共$count首)",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ));
      }
    }

    // 添加占位符
    children.add(Spacer());
    // 添加尾部
    if (this.tail != null) {
      children.add(tail);
    }

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)
      ),
      child: Container(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.fromSize(
            size: preferredSize,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: children,
              ),
            )
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(44);
}