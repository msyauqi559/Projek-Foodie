class PriceFormatter {
  const PriceFormatter._();

  static String toRupiah(double value) {
    final String digits = value.toStringAsFixed(0);
    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      final int reverseIndex = digits.length - index;
      buffer.write(digits[index]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp. $buffer';
  }
}
