import 'dart:math';

String anyString() => Random().nextInt(1_000_000).toString();
bool anyBool() => Random().nextBool();
DateTime anyDateTime() => DateTime.fromMillisecondsSinceEpoch(Random().nextInt(1_000_000));
