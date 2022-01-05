/**
 * @group I2msTechnicianControllerTest
 * @description Test class for I2msTechnicianController to improve code coverage
 * and test functionality.
 */
@isTest
public class I2msTechnicianControllerTest {
  public static TestMethod void testExtractJsonData(){
    // Set mock callout
    Test.setMock(HttpCalloutMock.class,
        new MockI2msTechnicianCtrlTest.MockExtractJSON());
    Test.startTest();
      String result = I2msTechnicianController.extractJsonData('sudhamalla', 'PRE_ASSIGNED_SPARE');
    Test.stopTest();
    System.assert(result!='');
  }

  public static TestMethod void testUpdateDeviceOwnership(){
    String inputData ='[{"serialNo":"CP2102SAGM9","gpn": "1063757-01"}]';
    String userLdap = 'sudhamalla';
    // Set mock callout
    Test.setMock(HttpCalloutMock.class,
        new MockI2msTechnicianCtrlTest.MockUpdateDeviceOwnership());
    String result = I2msTechnicianController.updateDeviceOwnership(inputData,userLdap);
    System.assert(result!='');
  }

  public static TestMethod void testConfirmLost(){
    String inputData ='[{"serialNo":"CP2103SAHZC", "gpn":"1063757-01",'+
        '"locationCode":"NITTX01FS"}]';
    String userLdap = 'sudhamalla';
    // Set mock callout
    Test.setMock(HttpCalloutMock.class,
        new MockI2msTechnicianCtrlTest.MockConfirmLost());
    String result = I2msTechnicianController.confirmLost(inputData,userLdap);
    System.assert(result!='');
  }

  public static TestMethod void test_checkIfLdapExists(){
    Test.startTest();
      Boolean resultExists = I2msTechnicianController.checkIfLdapExists('testemail@abc.com');
    Test.stopTest();
  }
}