class Country {
  final String dailCode;
  final String name;
  final String countryCode;
  final String flag;

  Country(this.dailCode, this.name, this.countryCode, this.flag);

  String get text {
    return '$dailCode $name';
  }
}
