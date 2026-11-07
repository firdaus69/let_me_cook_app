class Country {
  const Country(this.code, this.name);

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(json['code'] as String, json['name'] as String);

  final String code;
  final String name;

  @override
  bool operator ==(Object other) => other is Country && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
