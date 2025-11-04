class Validator {
  static String? notEmpty(String? v) =>
      (v == null || v.isEmpty) ? 'Cannot be empty' : null;
}
