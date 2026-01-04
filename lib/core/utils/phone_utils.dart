/// Phone number utilities for Saudi Arabia (+966)
class PhoneUtils {
  PhoneUtils._(); // Private constructor

  /// Normalizes a phone number to the standard format: +966XXXXXXXXX
  ///
  /// Handles various input formats:
  /// - 0512345678 → +966512345678
  /// - 512345678 → +966512345678
  /// - +966512345678 → +966512345678
  /// - 966512345678 → +966512345678
  /// - 00966512345678 → +966512345678
  ///
  /// Returns null if the input is invalid or cannot be normalized.
  static String? normalize(String? phone) {
    if (phone == null || phone.isEmpty) return null;

    // Remove all non-digit characters except leading +
    String cleaned = phone.trim();
    final hasPlus = cleaned.startsWith('+');
    cleaned = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different formats
    if (cleaned.startsWith('00966')) {
      // 00966512345678 → 966512345678
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('966') && cleaned.length >= 12) {
      // Already has 966 prefix
      // 966512345678 → 966512345678
    } else if (cleaned.startsWith('0') && cleaned.length == 10) {
      // Saudi local format: 0512345678 → 966512345678
      cleaned = '966${cleaned.substring(1)}';
    } else if (cleaned.length == 9 &&
        (cleaned.startsWith('5') || cleaned.startsWith('1'))) {
      // Short format without leading 0: 512345678 → 966512345678
      cleaned = '966$cleaned';
    } else if (hasPlus && cleaned.startsWith('966')) {
      // +966 prefix was stripped, keep as is
    } else {
      // Unknown format - try to handle gracefully
      if (cleaned.length == 9) {
        cleaned = '966$cleaned';
      } else if (cleaned.length == 10 && cleaned.startsWith('0')) {
        cleaned = '966${cleaned.substring(1)}';
      }
    }

    // Validate the result
    if (!cleaned.startsWith('966')) {
      return null; // Invalid format
    }

    // Should be 966 + 9 digits = 12 digits total
    if (cleaned.length != 12) {
      return null; // Invalid length
    }

    return '+$cleaned';
  }

  /// Generates all possible phone variations for searching
  /// This helps find customers that may have been stored with different formats
  static List<String> getSearchVariants(String phone) {
    final normalized = normalize(phone);
    if (normalized == null) return [phone];

    // Generate common variants
    return {
      normalized, // +966512345678
      normalized.substring(1), // 966512345678
      '0${normalized.substring(4)}', // 0512345678
      normalized.substring(4), // 512345678
      phone.trim(), // Original input
    }.toList(); // Remove duplicates
  }

  /// Formats a phone number for display (with spaces)
  /// +966512345678 → +966 51 234 5678
  static String formatForDisplay(String? phone) {
    final normalized = normalize(phone);
    if (normalized == null) return phone ?? '';

    // Format: +966 5X XXX XXXX
    final digits = normalized.substring(1); // Remove +
    if (digits.length == 12) {
      return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    }
    return normalized;
  }

  /// Checks if two phone numbers are equivalent
  static bool areEqual(String? phone1, String? phone2) {
    if (phone1 == null || phone2 == null) return false;
    final normalized1 = normalize(phone1);
    final normalized2 = normalize(phone2);
    if (normalized1 == null || normalized2 == null) return false;
    return normalized1 == normalized2;
  }

  /// Validates if the phone number is a valid Saudi mobile number
  static bool isValidSaudiMobile(String? phone) {
    final normalized = normalize(phone);
    if (normalized == null) return false;

    // Saudi mobile numbers start with +9665
    return normalized.startsWith('+9665');
  }
}
