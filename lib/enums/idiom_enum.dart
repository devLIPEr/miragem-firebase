enum Idiom {
  PT(0),
  EN(1),
  JP(2);

  const Idiom(this.value);
  final num value;

  factory Idiom.fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}
