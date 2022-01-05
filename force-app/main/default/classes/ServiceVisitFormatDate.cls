/**
  * @group CSR Console
  * @description class to convert the appointment start time of ticket to a particular time zone.
  */
global with sharing class ServiceVisitFormatDate implements vlocity_cmt.VlocityOpenInterface2 {

  /**
   * @description The VlocityOpenInterface2 method override to dynamically call
   * convertDateToTimeZone method.
   * @param inputMap The inputs of the method
   * @param methodName The name of the method that will be invoked
   * @param outMap A map to store output information in
   * @param options Any optional parameters
   * @return It returns true if no exception else returns false
   */
  global Boolean invokeMethod(String methodName, Map<String, Object> inputMap,
      Map<String, Object> outMap, Map<String, Object> options) {
    Boolean result = true;
    try {
      if ('convertDateToTimeZone'.equalsIgnoreCase(methodName)) {
        convertDateToTimeZone(inputMap, outMap, options);
      }
    }
    catch (Exception e) {
      result = false;
      LoggingUtility.insertExceptionLog('ServiceVisitFormatDate', 'invokeMethod', e);
    }
    return result;
  }

  /**
   * @description This method is to convert the time zone of ticket's appointment start time
   * into given time zone mentioned in Premises.
   * @param inputMap This will have tickets and time zone of Premises.
   * @param outMap This will return the tickets with converted time in given time zone.
   * @param options Any optional parameters
   * @return null
   */
  public void convertDateToTimeZone(Map<String, Object> inputMap,
      Map<String, Object> outMap, Map<String, Object> options) {
    String timeZone = String.valueOf(inputMap.get('timeZone'));
    Map<String, Object> ticketObject;
    List<Object> ticketObjects;
    List<Map<String, Object>> ticketsWithConvertedDate = new List<Map<String, Object>>();
    try {
      ticketObject = (Map<String, Object>)inputMap.get('tickets');
    }
    catch(TypeException typeException) {
      if (typeException.getMessage().contains('Invalid conversion')) {
        ticketObjects = (List<Object>)inputMap.get('tickets');
      }
    }
    if (ticketObject != null) {
      Map<String, Object> fieldValueByField =
          updateStartTimeWithConvertedTime(ticketObject, timeZone);
      ticketsWithConvertedDate.add(fieldValueByField);
    } else if (ticketObjects != null) {
      for (Object ticket : ticketObjects) {
        Map<String, Object> fieldValueByField =
            updateStartTimeWithConvertedTime((Map<String, Object>)ticket, timeZone);
        ticketsWithConvertedDate.add(fieldValueByField);
      }
    }
    outMap.put('ticketObjects', ticketsWithConvertedDate);
  }

  /**
   * @description This method is to convert the time zone of ticket's appointment start time
   * into given time zone mentioned in Premises.
   * @param startTime Time to be converted.
   * @param timeZone Time zone to be converted.
   * @return String
   */
  public static String convertTimeZone(String startTime, String timeZone) {
    DateTime dt = DateTime.valueOfGMT(startTime.replace('T',' '));
    String convertedDate = dt.format('MMMM dd, YYYY hh:mm a', timeZone);
    return convertedDate;
  }

  /**
   * @description Formats ticket details to be returned to CON_ServiceVisits Integration Procedure.
   * @param ticketMap Ticket object map with ticket details.
   * @param timeZone Time zone to be converted.
   * @return Map<String, Object>
   */
  public static Map<String, Object> updateStartTimeWithConvertedTime(Map<String, Object> ticketMap,
      String timeZone) {
    final String startTime = 'startTime';
    String convertedDate = convertTimeZone(String.valueOf(ticketMap.get(startTime)), timeZone);
    ticketMap.put(startTime, (Object)convertedDate);
    return ticketMap;
  }
}