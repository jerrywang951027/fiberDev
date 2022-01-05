/**
   * @group UtilityClasses
   * @description KeyGenerator class hold methods to helping generate keys/Id used
   * in the rest of the system
   */
  public class KeyGenerator {
    /*
     * @description used in the generateRandomId method to create a random Id
     */ 
      public static String SEPARATOR = '-';
      /**
       * @description generateRandomId return a random identifier that will
       * be prefixed by the provided string and will be limited by the length
       * provided excluding segment separator ('-')
       * @param prefix The String that will prefix the Id
       * @param length The total length of the id including prefix
       * @param segmentSize The total length for one segment of the Id
       */
      public static String generateRandomId(String prefix, 
        Integer length, 
        Integer segmentSize) {
          List<String> segments = new List<String>();
          Integer remainingCharacters = length - prefix.length();
          // Initialize generatedId with prefix value
          segments.add(prefix);
          while (remainingCharacters > 0) {
            Integer actualSegmentSize =
              (remainingCharacters < segmentSize)? remainingCharacters:segmentSize;
            Integer index =
              Math.mod(Math.abs(Crypto.getRandomInteger()), 10 * actualSegmentSize);
            segments.add(String.valueOf(index).rightPad(actualSegmentSize, '0'));
            remainingCharacters = remainingCharacters - segmentSize;
          }
          return String.join(segments, KeyGenerator.SEPARATOR);
      }
      /**
       * @description generateRandomNumber return a random number of 5 digts
       * using the standard crypto and Math functions
       * @return a random 5 digit integer
       */
      public static string generateRandomNumber() {
        Integer len = 5;
        String randomNumberString = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = randomNumberString.substring(0, len);
        return randomNumber;
      }
    }