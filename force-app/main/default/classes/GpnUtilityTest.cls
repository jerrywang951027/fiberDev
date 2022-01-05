/**
* @group TestClass-GpnUtility
* @description Test class for GpnUtility to improve code coverage
* and test functionality.
*/
@isTest
public class GpnUtilityTest {

  // Initialize class constants.
  public static final String CHILD_GPN = '72004270-08';
  public static final String MODEL_NAME = 'GFRG200';
  public static final String CPE_TYPE = 'Google Wifi';
  public static final String SUB_TYPE = 'Router';
  public static final String SERIAL_NUMBER = '4704HT004LC';
  public static final String ORDER_TYPE = 'Equipment';

  /**
   * @description This method covers the merging of the name from
   * gpnsAssetModels into GPNDetails json.
   * @return null
   */
  @isTest
  static void passingGpnAssetModelShouldUpdateModel(){
    String actualModelName = null;
    Map<String, Object> modelDetails = new Map<String, Object>{
      GpnUtility.INPUT_MAP_NAME_KEY => MODEL_NAME,
      'displayName' => MODEL_NAME
    };
    Map<String, Object> gpnsAssetModel = new Map<String, Object>{
      CHILD_GPN => modelDetails
    };
    Map<String, Object> childSerial = new Map<String, Object>{
      'SerialNumber' => '4704HT004LC',
      GpnUtility.INPUT_MAP_GPN_KEY => CHILD_GPN
    };
    Map<String, Object> gpnDetail = new Map<String, Object>{
      GpnUtility.INPUT_MAP_CHILD_SERIAL_NUMBERS_KEY
          => new List<Object>{childSerial}
    };
    Map<String, Object> inputMap = new Map<String, Object>{
      GpnUtility.INPUT_MAP_GPN_DETAILS_KEY
          => new List<Object>{gpnDetail},
      GpnUtility.INPUT_MAP_GPNS_ASSET_MODELS_KEY
          => gpnsAssetModel
    };
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Test.startTest();
      GpnUtility.mergeModelName(inputMap,
          outMap, options);
    Test.stopTest();
    List<Object> actualGpnDetails = (List<Object>)outMap.get(
        GpnUtility.INPUT_MAP_GPN_DETAILS_KEY);
    Map<String, Object> actualGpnDetail =
        (Map<String, Object>)actualGpnDetails[0];
    List<Object> actualChildSerials = (List<Object>)actualGpnDetail
        .get(GpnUtility.INPUT_MAP_CHILD_SERIAL_NUMBERS_KEY);
    Map<String, Object> actualChildSerial =
        (Map<String, Object>)actualChildSerials[0];
    System.assertEquals(MODEL_NAME,
         actualChildSerial.get(GpnUtility.OUTPUT_MAP_MODEL_KEY),
        'Model name did not matched.');
  }

  /**
   * @description This method covers the merging of the serial number from
   * childSerialNodes into orderedEquipments json if condition matched.
   * @return null
   */
  @isTest
  static void passingChildSerialShouldUpdateSerialNumber(){
    Map<String, Object> childSerial = new Map<String, Object>{
      'SerialNumber' => SERIAL_NUMBER,
      'Model' => MODEL_NAME,
      'cpeType' => CPE_TYPE,
      'subType' => SUB_TYPE
    };
    Map<String, Object> orderEquipment = new Map<String, Object>{
      'cpeType' => CPE_TYPE,
      'subType' => SUB_TYPE,
      'type' => ORDER_TYPE
    };
    Map<String, Object> inputMap = new Map<String, Object>{
      'childSerialNodes' => new List<Object>{childSerial},
      'orderedEquipment' => new List<Object>{orderEquipment}
    };
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Test.startTest();
      GpnUtility.mergeSerialNumber(inputMap,
          outMap, options);
    Test.stopTest();
    List<Object> actualOrderedEquipments = (List<Object>)outMap.get(
        'orderedEquipment');
    Map<String, Object> actualOrderedEquipment =
        (Map<String, Object>)actualOrderedEquipments[0];
    System.assertEquals(SERIAL_NUMBER, actualOrderedEquipment.get('SerialNumber'),
        'Serial number should be added.');
  }

  /**
   * @description This method covers the not merging of the serial number from
   * childSerialNodes into orderedEquipments json if condition not matched.
   * @return null
   */
  @isTest
  static void passingChildSerialShouldNotUpdateSerialNumber(){
    Map<String, Object> childSerial = new Map<String, Object>{
      'SerialNumber' => SERIAL_NUMBER,
      'Model' => MODEL_NAME,
      'subType' => SUB_TYPE
    };
    Map<String, Object> orderEquipment = new Map<String, Object>{
      'cpeType' => CPE_TYPE,
      'subType' => SUB_TYPE,
      'type' => ORDER_TYPE
    };
    Map<String, Object> inputMap = new Map<String, Object>{
      'childSerialNodes' => new List<Object>{childSerial},
      'orderedEquipment' => new List<Object>{orderEquipment}
    };
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();
    Test.startTest();
      GpnUtility.mergeSerialNumber(inputMap,
          outMap, options);
    Test.stopTest();
    List<Object> actualOrderedEquipments = (List<Object>)outMap.get(
        'orderedEquipment');
    Map<String, Object> actualOrderedEquipment =
        (Map<String, Object>)actualOrderedEquipments[0];
    System.assertEquals(null, actualOrderedEquipment.get('SerialNumber'),
        'Serial number should not be added.');
  }

}