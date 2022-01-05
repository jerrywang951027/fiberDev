/**
 * @group Knowledge Article
 * @description get knowledge articles related to each tab in CSR console.
 */
public with sharing class KnowledgeArticleController {
  /**
   * @description Display Knowledge Article on console based on tab
   * @param tabName
   * @return knowledge article from metadata
   */
  @AuraEnabled
  public static List<Knowledge_Article__mdt> getKnowledgeArticle(String tabName) {
    List<Knowledge_Article__mdt> knowledgeArticles = new List<Knowledge_Article__mdt>();
    if (!String.isBlank(tabName)) {
      knowledgeArticles = [SELECT Id, Article__c
          FROM Knowledge_Article__mdt
          WHERE Related_Tab__c = :tabName];
    }
    return knowledgeArticles;
  }
}