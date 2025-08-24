/// A collection of string utility methods.
class StringUtils {
  /// Capitalizes the first letter of the input string.
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Capitalizes the first letter of every word in the input string.
  static String capitalizeEachWord(String input) {
    return input
        .split(' ')
        .map((word) => capitalize(word))
        .join(' ');
  }
}