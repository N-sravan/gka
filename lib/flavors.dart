enum Flavor {
  spanish,
  english,
  hindi
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.spanish:
        return 'Gka spanish';
      case Flavor.english:
        return 'Gka english';
      case Flavor.hindi:
        return 'Gka hindi';
      default:
        return 'title';
    }
  }

}
