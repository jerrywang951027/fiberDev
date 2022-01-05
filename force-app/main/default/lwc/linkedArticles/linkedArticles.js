/**
 * @group CSR Console
 * @description Will display linked articles for each tab in the Service Console.
 */
import { LightningElement } from 'lwc';
import { getDataHandler } from 'vlocity_cmt/utility';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import pubsub from 'vlocity_cmt/pubsub';

const NO_RECORDS_FOUND_MESSAGE = 'There is no linked article associated with the tab found.';

export default class LinkedArticles extends OmniscriptBaseMixin(LightningElement) {

  data;
  error;
  isData = false;
  isSpinnerLoaded = false;
  noRecordsFoundMessage = NO_RECORDS_FOUND_MESSAGE;
  tabName = 'Overview';

  /**
   * @description connectedCallback method to load the spinner and to call handleLoad method to
   * get knowledge articles
   */
  connectedCallback() {
    pubsub.register('tabLabelChannel', { publish_tab_label: this.getTabLabel.bind(this) });
    let data = JSON.stringify({ tabName: this.tabName });
    this.invokeDR(data);
  }

  /**
   * @description getTabLabel method is to get the custom tab label from PubSub
   */
  getTabLabel(message) {
    this.tabName = message.tabLabel;
    let data = JSON.stringify({ tabName: this.tabName });
    this.invokeDR(data);
  }

  /**
   * @description invokeDR method to call the DR FetchKnowledgeArticle to get the
   * knowledge articles associated with the Tab in Service Console by passing the name of the
   * Tab as parameter
   */
  async invokeDR(data) {
    this.isSpinnerLoaded = true;
    let requestData = {};
    requestData.value = {};
    requestData.type = 'dataraptor';
    requestData.value.inputMap = data;
    requestData.value.bundleName = 'CON_ExtractKnowledgeArticle';
    await getDataHandler(JSON.stringify(requestData)).then(result => {
      let parsedResult = JSON.parse(result);
      if (Array.isArray(parsedResult) && parsedResult.length > 0) {
        this.isSpinnerLoaded = false;
        let articles = parsedResult[0].knowledgeArticle;
        if (!Array.isArray(articles)) {
          let dataArr = [];
          dataArr[0] = articles;
          this.data = dataArr;
          this.isData = true;
          this.error = undefined;
        } else {
          if (articles.length > 0) {
            this.data = articles;
            this.isData = true;
            this.error = undefined;
          } else {
            this.data = undefined;
            this.isData = false;
          }
        }
      } else {
        this.isSpinnerLoaded = false;
        this.data = undefined;
        this.isData = false;
      }
    }).catch(error => {
      this.isSpinnerLoaded = false;
      this.isData = false;
      this.noRecordsFoundMessage = undefined;
      this.error = error;
    });
  }
}