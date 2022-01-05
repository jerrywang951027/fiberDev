public class CustomMetadataUtil {
  private static Map<String, MXU_Market__mdt> emailsByMxuMarket =
      new Map<String, MXU_Market__mdt>();

  public static String getSalesEmailByMxUMarket(String marketName) {
    if (emailsByMxuMarket.isEmpty()) {
      retrieveMxuMarketMetadata();
    }

    if (emailsByMxuMarket.containsKey(marketName)) {
      return emailsByMxuMarket.get(marketName).Sales_Email__c;
    }

    return null;
  }

  public static String getTechOpsEmailByMxUMarket(String marketName) {
    if (emailsByMxuMarket.isEmpty()) {
      retrieveMxuMarketMetadata();
    }

    if (emailsByMxuMarket.containsKey(marketName)) {
      return emailsByMxuMarket.get(marketName).Email__c;
    }

    return null;
  }

  public static String getStageOneInactivityDurationByMxUMarket(
      String marketName) {
    if (emailsByMxuMarket.isEmpty()) {
      retrieveMxuMarketMetadata();
    }
    if (emailsByMxuMarket.containsKey(marketName)) {
      return emailsByMxuMarket.get(marketName).Stage_1_Inactivity_Duration__c;
    }
    return null;
  }

  public static String getStageThreeInactivityDurationByMxUMarket(
      String marketName) {
    if (emailsByMxuMarket.isEmpty()) {
      retrieveMxuMarketMetadata();
    }
    if (emailsByMxuMarket.containsKey(marketName)) {
      return emailsByMxuMarket.get(marketName).Stage_3_Inactivity_Duration__c;
    }
    return null;
  }

  private static void retrieveMxuMarketMetadata() {
    List<MXU_Market__mdt> markets = [
      SELECT
        MasterLabel,
        Email__c,
        Sales_Email__c,
        Stage_1_Inactivity_Duration__c,
        Stage_3_Inactivity_Duration__c
      FROM
        MXU_Market__mdt
    ];

    for (MXU_Market__mdt mdt : markets) {
      emailsByMxuMarket.put(mdt.MasterLabel, mdt);
    }
  }
}