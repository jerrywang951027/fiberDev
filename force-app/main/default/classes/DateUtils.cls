/**
 * This class provides some useful functions that can be used within Vlocity DataRaptor
 * formulas to manipulate Date fields.
 * Note, each function must be registered with Vlocity's custom metadata:
 * (Setup -> Custom Metadata Types -> Function Definition -> Manage Function Definitions -> New)
 * Initial Version with DAY() function
 */
global class DateUtils implements vlocity_cmt.VlocityOpenInterface {

  public static final String Class_Name = 'DateUtils';
  private Pattern SIMPLE_DATE = Pattern.compile('\\d{4}-\\d{2}-(\\d{2})');    // YYYY-MM-DD
  public static final String HILBERT_ACTIVATION_METHOD_NAME = 'convertActivationDate';

  /**
   * Top level call by a Vlocity DataRaptor
   * @param inputMap The input provided by the function call
   * (i.e. contains a single entry called 'arguments')
   * @param outputMap Any output to be provided back to the DataRaptor
   * (must contain a single entry called 'result')
   * @param options Any options to aid in the execution of the method although
   * DR doesn't provide any when calling this function
   * @returns true if the method completes successfully, false otherwise
   */
  global Boolean invokeMethod(
      String methodName,
      Map<String, Object> inputMap,
      Map<String, Object> outputMap,
      Map<String, Object> options) {

    try {
      if (methodName.equalsIgnoreCase('day')) {
        outputMap.put('result', getDay((List<Object>)inputMap.get('arguments')));
      }

      if (HILBERT_ACTIVATION_METHOD_NAME.equalsIgnoreCase(methodName)) {
        convertActivationDate(inputMap,outputMap,options);
      }
      return true;
    }
    // Exception occured. Throw exception.
    catch (Exception ex) {
      LoggingUtility.insertExceptionLog(Class_Name, methodName, ex.getMessage());
      throw ex;
    }
  }
  /**
   * This method determines the day field from a date
   * The method is called by DataRaptor/Forumals as follows:
   * DAY(<date>)
   * where,
   * <date> the date using the syntax YYYY-MM-DD
   * For example:
   * DAY('1999-01-23') should return 23
   * @param args The list of input provided to the function
   * @returns The day
   */
  private Integer getDay(List<Object> args) {
    List<Object> theList = new List<Object>();
    // Handle DAY(<date>)
    if (args.size() == 1) {
        String d = String.valueOf(args.get(0));
      // YYYY-MM-DD
      Matcher m = SIMPLE_DATE.matcher(d);
        if (m.matches()) {
          return Integer.valueOf(m.group(1));
        }
      // If we make it here, we did not understand the date string
      InvalidParameterValueException e = new InvalidParameterValueException(
          'DAY', 'The function does not support the date format "' + d + '"');
      throw e;
    }
    else {
      // If we make it here, an incorrect number of arguments were provided
      InvalidParameterValueException e = new InvalidParameterValueException(
          'DAY', 'The function must be called with a single <date> argument');
      throw e;
    }
  }

  /**
   * @description This method is to format the Activation Date
   * (yyyy-MM-ddTHH:mm:ss.SSSXXX) to DateTime format.
   */
  public static void convertActivationDate(Map<String, Object> inputMap,
      Map<String, Object> outputMap,
      Map<String, Object> options)
  {
    String activationDateDetails = (String)inputMap.get('activationDate');
    Datetime activationDate = (DateTime)JSON.deserialize('"' + activationDateDetails + '"', DateTime.class);
    outputMap.put('activationDate',activationDate);
  }
}