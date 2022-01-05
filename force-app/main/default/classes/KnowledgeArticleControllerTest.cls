/**
 * @group TestClass-Knowledge Article
 * @description Test class for Knowledge Article to test functionality.
 */
@isTest
public with sharing class KnowledgeArticleControllerTest {
 /**
   * @description test method to get Knowledge Article
   */
  @isTest
  static void getKnowledgeArticleTest() {
    Test.startTest();
    List<Knowledge_Article__mdt> overviewArticle =
        KnowledgeArticleController.getKnowledgeArticle(Constants.knowledge.ARTICLE.OVERVIEW);
    List<Knowledge_Article__mdt> unknownArticle =
        KnowledgeArticleController.getKnowledgeArticle('');
    Test.stopTest();
    System.assert(overviewArticle.size() > 1);
  }
}