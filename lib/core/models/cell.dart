class Cell {
  final int x;
  final int y;
  int number;
  final bool initial;
  List<int> notes;
  final int solution;

  Cell({
    required this.x,
    required this.y,
    required this.number,
    required this.initial,
    required this.notes,
    required this.solution,
  });

  Cell copyWith({
    int? number,
    List<int>? notes,
  }) {
    return Cell(
      x: x,
      y: y,
      number: number ?? this.number,
      initial: initial,
      notes: notes ?? List.from(this.notes),
      solution: solution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'number': number,
      'initial': initial,
      'notes': notes,
      'solution': solution,
    };
  }

  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
      x: json['x'],
      y: json['y'],
      number: json['number'],
      initial: json['initial'],
      notes: List<int>.from(json['notes']),
      solution: json['solution'],
    );
  }
}
