class RatingFormatter {
  const RatingFormatter._();

  static String display(num rating) => rating.toStringAsFixed(1);
}
