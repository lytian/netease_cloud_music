class Lyric{
  String text;
  Duration startTime;
  Duration endTime;
  double offset;

  Lyric({this.text,this.startTime, this.endTime, this.offset});

  @override
  String toString() {
    return 'Lyric{lyric: $text, startTime: $startTime, endTime: $endTime}';
  }
}