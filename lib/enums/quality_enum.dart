enum Quality {
  M(0),
  NM(1),
  SP(2),
  MP(3),
  HP(4),
  D(5);

  const Quality(this.value);
  final num value;

  factory Quality.fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}
