enum Difficulty {
  easy('easy', 'Dễ'),
  medium('medium', 'Trung bình'),
  hard('hard', 'Khó'),
  expert('expert', 'Chuyên gia'),
  evil('evil', 'Cực khó');

  final String value;
  final String displayName;

  const Difficulty(this.value, this.displayName);

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (d) => d.value == value,
      orElse: () => Difficulty.easy,
    );
  }
}
