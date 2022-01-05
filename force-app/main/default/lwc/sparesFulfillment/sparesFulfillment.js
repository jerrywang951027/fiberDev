/**
 * @group SparesFulfillment
 * @description To call Sparefulfillment components operations.
 */
import { api, LightningElement, track, wire} from 'lwc';
import searchSpareparts from '@salesforce/apex/SparesFulfillmentController.searchSpareparts';
import searchSparepartsForUser from
    '@salesforce/apex/SparesFulfillmentController.searchSparepartsForUser';
import assignSerialsToUser from '@salesforce/apex/SparesFulfillmentController.assignSerialsToUser';
import checkIfLdapExist from '@salesforce/apex/SparesFulfillmentController.checkIfLdapExists';

export default class SparesFulfillment extends LightningElement {
    @api warehouse;
    @track doShowAssignSerials = false;
    @track deviceList;
    @track error;
    @track isUserNameEmpty = false;
    @track serialNumber1;
    @track serialNumber2;
    @track serialNumber3;
    @track serialNumber4;
    @track serialNumber5;
    @track showUserMessage;
    @track showError=false;
    @track showDevices = false;
    @track totalNumberOfDevices;
    @track userName;
    @track userMessage;
    
    /**
     * @description Method for checking the user name in the group
     * @param userName to be use for Technician name
     *
     */
    checkLdap(userName){
        checkIfLdapExist({userEmail :userName+'@google.com'})
        .then (result=>{
            if (result){
                this.showError=false;
            }  else {
                this.showError=true;
            }
        });
    }

    /**
     * @description Method for searching technician
     */
    handleTechSearch(event){
        this.userName = event.target.value;
    }

    /**
     *@description Method for handling search for Technician and listing the result.
     */
    handleSearch(event){
        this.checkIfUsernameEmpty();
        if (this.isUserNameEmpty == false){
            checkIfLdapExist({userEmail :this.userName+'@google.com'})
            .then(result=>{
                if (result){
                    this.showError=false;
                    searchSparepartsForUser({argUserName: this.userName})
                    .then (result=>{
                        this.deviceList = JSON.parse(result);
                        this.userMessage = '';
                        this.showUserMessage = false;
                        this.totalNumberOfDevices = this.deviceList.length;
                        this.showDevices = true;
                    })
                    .catch (error=>{
                        this.error = error;
                        this.showDevices = false;
                    })
                } else {
                    this.showError=true;
                    this.deviceList = [];
                    this.userMessage = '';
                    this.showUserMessage = false;
                    this.showDevices = false;
                }
            });
        }
    }

    saveSerialNumber1(event){
        this.serialNumber1 = event.target.value;
    }

    saveSerialNumber2(event){
        this.serialNumber2 = event.target.value;
    }

    saveSerialNumber3(event){
        this.serialNumber3 = event.target.value;
    }

    saveSerialNumber4(event){
        this.serialNumber4 = event.target.value;
    }

    saveSerialNumber5(event){
        this.serialNumber5 = event.target.value;
    }
    //Method for Assigning Device
    assignSerials(event){
        assignSerialsToUser({argUserName: this.userName
            , argSerialNumber1: this.serialNumber1
            , argSerialNumber2: this.serialNumber2
            , argSerialNumber3: this.serialNumber3
            , argSerialNumber4: this.serialNumber4
            , argSerialNumber5: this.serialNumber5
            , argWarehouse: this.warehouse})
        .then (result=>{
            let resultLocal = JSON.parse(result);
            if (null != resultLocal.userMessage){
                this.userMessage = resultLocal.userMessage;
                this.showUserMessage = true;
            }
            else {
                Array.prototype.push.apply(this.deviceList, JSON.parse(result));
                this.userMessage = '';
                this.showUserMessage = false;
                this.totalNumberOfDevices = this.deviceList.length;
                this.showDevices = true;
            }
            this.serialNumber1 = '';
            this.serialNumber2 = '';
            this.serialNumber3 = '';
            this.serialNumber4 = '';
            this.serialNumber5 = '';
        })
        .catch (error=>{
            this.error = error;
        })
    }

    /**
     * @description Method for checking if there is user name is entered or not.
     */
    checkIfUsernameEmpty(){
        if (this.userName=='' || this.userName == undefined){
            this.isUserNameEmpty = true;
        } else{
            this.isUserNameEmpty = false;
        }
    }
}