import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class AddressNotFoundErrorMessage extends OmniscriptBaseMixin(
  LightningElement) {

  _omniJsonData;

  /**
   * @description Getting OmniScript JSON data in LWC and setting it to the decorator _omniJsonData
   * @param omniData value to be set in the decorator _omniJsonData
   */
   @api
   set omniJsonData(omniData) {
     if (omniData) {
       this._omniJsonData = omniData;
       //this.addressDetails();
       console.log("this._omniJsonData1",JSON.stringify(this._omniJsonData));
     }
   }

   /**
   * @description Getter to return decorator _omniJsonData
   * @return _omniJsonData
   */
  get omniJsonData() {
    return this._omniJsonData;
  }
  renderedCallback(){
    this.addressDetails();
  }
  addressDetails(){
    let globalAddress;
    alert(1);
    console.log("globalAddress:",JSON.stringify(this._omniJsonData));
    let dataString = JSON.stringify(this._omniJsonData);
    dataString = dataString.split('globalAddress-Block').join('globalAddressBlock');
    console.log('dataString = '+dataString);
    // if(this._omniJsonData && this._omniJsonData.moveInOrderDetails && this._omniJsonData.moveInOrderDetails.globalAddress-Block){
    //   console.log("globalAddress details:",this._omniJsonData.moveInOrderDetails.globalAddress-Block.globalAddress);
    //   globalAddress = (this._omniJsonData.moveInOrderDetails.globalAddress-Block.globalAddress).toString();
    //   console.log("length",globalAddress.length);
    //   if(globalAddress.length>1){
    //     let data = JSON.stringify(globalAddress);
    //     this.invokeDR(data);
    //   }
    // }
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
    requestData.value.bundleName = 'CON_ExtractPremisesForMoveServices';
    console.log("data",data);
    await getDataHandler(JSON.stringify(requestData)).then(result => {
      let parsedResult = JSON.parse(result);
      console.log("parsedResult",parsedResult);

    }).catch(error => {
      
    });
  }
}