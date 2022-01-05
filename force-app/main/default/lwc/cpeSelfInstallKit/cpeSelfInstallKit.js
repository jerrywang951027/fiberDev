import { api, LightningElement, track} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { cloneDeep } from "vlocity_cmt/lodash";

export default class CpeSelfInstallKit extends OmniscriptBaseMixin(LightningElement) {
    _omniJsonData;
    @track _orderedEquipment;
    
    @api
    set omniJsonData(omniData) {
        if (omniData) {
        this._omniJsonData = omniData;
            if(this._omniJsonData.hasOwnProperty('selfInstallKit') && 
                this._omniJsonData.selfInstallKit.hasOwnProperty('orderedEquipment')){
                this._orderedEquipment = cloneDeep(this._omniJsonData.selfInstallKit.orderedEquipment);
            }
        }
    }
    
    get omniJsonData() {
        return this._omniJsonData;
    }
    /*connectedCallback(){
        console.log('Data Extract for Self Install');
        console.log(JSON.stringify(this._omniJsonData));
        //this.omniApplyCallResp({'Data-Extract-CPE-123':this._omniJsonData});
    }*/
    /**
     * pass the serialNumber to OmniScript.
     */
     handleOnBlur(event){
        let selectedValue = event.target.value;
        let orderId = event.target.getAttribute('data-orderid');   
        let serialNumber = '';
        let model = '';
        console.log('Selected Value ',selectedValue);
        console.log('orderId Value ',orderId);
        if(selectedValue.length > 0){
            if(selectedValue.startsWith('http')){
                serialNumber = selectedValue.split('=')[1].split('&')[0];
                model = selectedValue.split('=')[3].split('&')[0];
            } else if(selectedValue.endsWith('CR')) {
                serialNumber = selectedValue.substring(0, selectedValue.length - 2);
            } else {
                serialNumber = selectedValue.split(',')[0];
            }
            console.log('serialNumber ',serialNumber);
            for (var i = 0; i < this._orderedEquipment.length; i++) {
                console.log('Order Item Id'+this._orderedEquipment[i].orderItemId);
                if(orderId === this._orderedEquipment[i].orderItemId){
                    this._orderedEquipment[i]['serialNumber'] = serialNumber;
                    this._orderedEquipment[i]['model'] = model;
                }
            }
            let outputData = {
                "selfInstallKit":{
                    "orderedEquipment": this._orderedEquipment
                }
            }
            console.log(JSON.stringify(this._orderedEquipment));
            this.omniApplyCallResp(outputData);
        }
    }
}