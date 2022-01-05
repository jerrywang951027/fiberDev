/**
 * @group TestClass ServiceVisitFormatDateTest
 * @description Test Class for ServiceVisitFormatDate to improve code coverage
 * and test functionality.
 */
@isTest
public with sharing class ServiceVisitFormatDateTest {
 /**
  * @description This is a test method to test invokeMethod of ServiceVisitFormatDate
  * overriden from vlocity_cmt.VlocityOpenInterface2.
  */
  @isTest
  static void startTimeFromTicketObjectShouldBeConvertedToParticularTimeZone() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Map<String, Object> ticketMap = new Map<String, Object>();
    String methodName = 'convertDateToTimeZone';
    String timeZone = 'America/Chicago';
    ticketMap.put('ticketId', (Object)'188358277');
    ticketMap.put('appointmentType', (Object)'Install');
    ticketMap.put('vendor', (Object)'One Path');
    ticketMap.put('appointmentTime', (Object)'06:00 PM GMT');
    ticketMap.put('appointmentDate', (Object)'May 17, 2021');
    ticketMap.put('startTime', (Object)'2021-05-17T18:00:00Z');
    inputMap.put('tickets',(object)ticketMap);
    inputMap.put('timeZone',timeZone);
    Test.startTest();
      ServiceVisitFormatDate objectService = new ServiceVisitFormatDate();
      Boolean result = objectService.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();
    System.assert(result);
  }

 /**
  * @description This is a test method to test invokeMethod of ServiceVisitFormatDate
  * overriden from vlocity_cmt.VlocityOpenInterface2.
  */
  @isTest
  static void startTimeFromTicketListShouldBeConvertedToParticularTimeZone() {
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Map<String, Object> ticketMap = new Map<String, Object>();
    List<Object> ticketMapList = new List<Object>();
    String methodName = 'convertDateToTimeZone';
    String timeZone = 'America/Chicago';
    ticketMap.put('ticketId', (Object)'188358277');
    ticketMap.put('appointmentType', (Object)'Install');
    ticketMap.put('vendor', (Object)'One Path');
    ticketMap.put('appointmentTime', (Object)'06:00 PM GMT');
    ticketMap.put('appointmentDate', (Object)'May 17, 2021');
    ticketMap.put('startTime', (Object)'2021-05-17T18:00:00Z');
    ticketMapList.add((Object)ticketMap);
    inputMap.put('tickets',ticketMapList);
    inputMap.put('timeZone',timeZone);
    Test.startTest();
      ServiceVisitFormatDate objectService = new ServiceVisitFormatDate();
      Boolean result = objectService.invokeMethod(methodName, inputMap, outMap, options);
    Test.stopTest();
    List<Map<String, Object>> tickets = (List<Map<String, Object>>)outMap.get('ticketObjects');
    System.assert(tickets[0].get('ticketId') == '188358277');
    System.assert(tickets[0].get('vendor') == 'One Path');
  }
}