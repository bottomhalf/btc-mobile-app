import 'dart:math';

class UuidUtils {
  static String generateUUID() {
    final random = Random.secure();
    final chars = '0123456789abcdef';
    
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 36; i++) {
      if (i == 8 || i == 13 || i == 18 || i == 23) {
        buffer.write('-');
      } else if (i == 14) {
        buffer.write('4'); // UUID version 4
      } else if (i == 19) {
        // variant 10xxxxxx
        final randVal = random.nextInt(4) + 8;
        buffer.write(chars[randVal]);
      } else {
        buffer.write(chars[random.nextInt(16)]);
      }
    }
    return buffer.toString();
  }
}
