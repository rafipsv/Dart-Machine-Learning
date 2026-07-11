final class LengthViolation {
  const LengthViolation(this.path, this.lines, this.maxLines);

  final String path;
  final int lines;
  final int maxLines;
}

final class LengthResult {
  const LengthResult(this.violations, this.errors);

  final List<LengthViolation> violations;
  final List<String> errors;

  bool get passed => violations.isEmpty && errors.isEmpty;
}
