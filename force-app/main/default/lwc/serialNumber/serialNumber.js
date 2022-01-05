/**
 * @group serialNumber
 * @description for showing serial number based on
 * scanner or user input.
 */
import { api, LightningElement, track} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class serialNumber extends OmniscriptBaseMixin(LightningElement) {
    outputserialNumber='';
    /**
     * pass the serialNumber to OmniScript.
     */
    handleOnBlur(event){
        let selectedValue = event.target.value;
        let serialNumber = '';
        let model = '';
        this.outputserialNumber='';
        if(selectedValue.length > 0){
            if(selectedValue.startsWith('http')){
                serialNumber = selectedValue.split('=')[1].split('&')[0];
                model = selectedValue.split('=')[3].split('&')[0];
            } else if(selectedValue.endsWith('CR')) {
                serialNumber = selectedValue.substring(0, selectedValue.length - 2);
            } else {
                serialNumber = selectedValue.split(',')[0];
            }
            this.outputserialNumber = serialNumber;
            this.omniApplyCallResp({'serialNumber': serialNumber,'model': model});
        }
    }
}