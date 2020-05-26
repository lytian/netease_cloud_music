import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:netease_cloud_music/models/lyric.dart';
import 'package:date_format/date_format.dart';

class LyricWidget extends CustomPainter with ChangeNotifier {
  List<Lyric> lyrics;
  List<TextPainter> lyricPaints = []; // 其他歌词
  int curLine;
  bool isDragging = false; // 是否正在拖动
  double _offsetY = 0; // 向上偏移
  double totalHeight = 0; // 总高度

  Paint linePaint;  // 线画笔
  TextPainter draggingLineTimePainter; // 正在拖动中当前行的时间画笔
  int dragLineTime; // 拖动行的时间
  int dragLine = -1; // 拖动的行

  static const double LINE_SPACE = 16; // 行间距

  LyricWidget(this.lyrics, this.curLine) {
    // 线画笔
    linePaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.6;
    // 为所有的歌词添加画笔
    lyricPaints.addAll(lyrics.map((e) => TextPainter(
        text: TextSpan(text: e.text, style: TextStyle(fontSize: 16, color: Colors.grey)),
        textDirection: TextDirection.ltr
    )));
    lyricPaints.forEach((lp) => lp.layout());
    // 延迟一下计算总高度
    Future.delayed(Duration(milliseconds: 300), () {
      totalHeight = lyricPaints[0].height + LINE_SPACE * (lyricPaints.length - 1);
    });
  }

  get offsetY => _offsetY;

  set offsetY (double value) {
    if (isDragging) {
      // 偏移量小于等于0
      if (value.abs() < (lyricPaints[0].height + LINE_SPACE)) {
        // 不能小于最开始的位置
        _offsetY = (lyricPaints[0].height + LINE_SPACE) * -1;
      } else if (value.abs() > (totalHeight + lyricPaints[0].height + LINE_SPACE)) {
        // 不能大于最大位置
        _offsetY = (totalHeight + lyricPaints[0].height + LINE_SPACE) * -1;
      } else {
        _offsetY = value;
      }
      dragLine = (_offsetY / (lyricPaints[0].height + LINE_SPACE)).abs().round() - 1;
    } else {
      _offsetY = value;
    }
    notifyListeners();
  }

  /// 计算传入行和第一行的偏移量
  double computeScrollY(int curLine) {
    return (lyricPaints[0].height + LINE_SPACE) * (curLine + 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 文字中线位置
    double y = _offsetY + size.height / 2 + lyricPaints[0].height / 2;

    // 遍历歌词，绘制
    for (int i = 0; i < lyrics.length; i++) {
     if (y <= size.height && y >= -lyricPaints[i].height / 2) {
       // 在可见区域内显示
       if (curLine == i) {
         lyricPaints[i].text = TextSpan(
           text: lyrics[i].text,
           style: TextStyle(fontSize: 16, color: Colors.white),
         );
         lyricPaints[i].layout();
       } else if (isDragging && i == dragLine) {
         lyricPaints[i].text = TextSpan(
           text: lyrics[i].text,
           style: TextStyle(fontSize: 16, color: Colors.white70),
         );
         lyricPaints[i].layout();
       } else {
         lyricPaints[i].text = TextSpan(
           text: lyrics[i].text,
           style: TextStyle(fontSize: 16, color: Colors.grey),
         );
         lyricPaints[i].layout();
       }
       // 居中绘制
       lyricPaints[i].paint(
         canvas,
         Offset((size.width - lyricPaints[i].width) / 2, y),
       );
     }

      y += lyricPaints[i].height + LINE_SPACE;
      lyrics[i].offset = y;
    }

    // 拖动的时候，显示时间线
    if (isDragging) {
      // 画icon
      var builder = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontFamily: Icons.arrow_right.fontFamily,
        fontSize: 48
      ));
      builder.pushStyle(ui.TextStyle(color: Colors.white12));
      builder.addText(String.fromCharCode(Icons.arrow_right.codePoint));
      var para = builder.build();
      para.layout(ui.ParagraphConstraints(
        width: 60
      ));
      canvas.drawParagraph(para, Offset(-6, size.height / 2 - 24));
      // 画线
      canvas.drawLine(Offset(36, size.height / 2), Offset(size.width - 56, size.height / 2), linePaint);
      // 画时间文字
      dragLineTime = lyrics[dragLine].startTime.inMilliseconds;
      draggingLineTimePainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: formatDate(DateTime.fromMillisecondsSinceEpoch(dragLineTime), [nn, ':', ss]),
          style: TextStyle(fontSize: 12, color: Colors.white70)
        )
      );
      draggingLineTimePainter.layout();
      draggingLineTimePainter.paint(canvas, Offset(size.width - 40, size.height / 2 - 6));
    }
  }

  @override
  bool shouldRepaint(LyricWidget oldDelegate) {
    return oldDelegate.offsetY != offsetY ||
        oldDelegate.isDragging != isDragging;
  }
}