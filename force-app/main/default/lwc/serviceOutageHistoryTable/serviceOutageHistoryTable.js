/**
 * @group CSR Console
 * @description It Will display list of Service Outages on click of Outage History button in
 *     Plan Actions section for Troubleshooting Tab in Service Console.
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import pubsub from 'vlocity_cmt/pubsub';

const COLUMNS = [
	{
		fieldName: "serviceAffected",
		label: "Type",
		searchable: "false",
		sortable: true,
		type: "text"
	},
	{
		fieldName: "impact",
		label: "Impact",
		searchable: false,
		sortable: true,
		type: "text"
	},
	{
		fieldName: "status",
		label: "Status",
		searchable: false,
		sortable: true,
		type: "text"
	},
	{
		fieldName: "fiberMarketStartTime",
		label: "Start",
		searchable: false,
		sortable: true,
		type: "text",
	},
	{
		fieldName: "fiberMarketEstimatedEndTime",
		label: "Expected End",
		searchable: false,
		sortable: true,
		type: "text",
	},
	{
		fieldName: "fiberMarketEndTime",
		label: "Actual End",
		searchable: "false",
		sortable: true,
		type: "text",
	},
	{
		fieldName: "ticketId",
		label: "Ticket",
		searchable: false,
		sortable: true,
		type: "text"
	}
];
const SERVICE_OUTAGES_NOT_FOUND = 'There have been no reported service outages in the last 90 days.';
const PREMISE_NOT_FOUND = 'There is no premises found to fetch the service outages.';

export default class ServiceOutageHistoryTable extends OmniscriptBaseMixin(LightningElement) {

	@api consumerAccountData;

	columns = COLUMNS;
	isError = false;
	isSpinnerLoaded = false;
	serviceOutageList = [];
	validationErrorMessage;

	/**
	* @description Method to call register and loadStyles.
	*/
	connectedCallback() {
		this.register();
		this.loadStyles();
	}

	/**
	* @description Register PubSub and handle event to close Modal.
	*/
	register() {
		pubsub.register('onCloseModal', {closeModal:this.handleDataFromChildCmp.bind(this)});
	}

	/**
	* @description This method will get called when PubSub fires from child component
	*     which closes the Modal.
	* @param data Data received from the child component.
	*/
	handleDataFromChildCmp(data) {
		if (data) {
			this.closeModal();
		}
	}

	/**
	* @description On click of Outage History button open the Modal and call
	*     getServiceOutages method.
	*/
	loadOutages() {
		this.isError = false;
		this.openModal();
		if (this.consumerAccountData && Array.isArray(this.consumerAccountData)
				&& this.consumerAccountData[0].hasOwnProperty('id')) {
			this.getServiceOutages();
		} else {
			this.isError = true;
			this.validationErrorMessage = PREMISE_NOT_FOUND;
		}
	}

	/**
	* @description Method to call CON_FetchServiceOutage Integration Procedure to load the
	*     Service Outages and display it in the UI.
	*/
	getServiceOutages() {
		this.isSpinnerLoaded = true;
		this.isError = false;

		let error;
		const params = {
			input: JSON.stringify({'serviceAccountId': this.consumerAccountData[0].id}),
			sClassName: 'vlocity_cmt.IntegrationProcedureService',
			sMethodName: 'CON_FetchServiceOutage',
			options: '{}'
		};

		this.omniRemoteCall(params, true).then(response => {
			if (response.result.IPResult.hasOwnProperty('outages')) {
				const outages = response.result.IPResult.outages;
				if(Array.isArray(outages)) {
					this.serviceOutageList = outages;
				} else if (outages.constructor === Object) {
					this.serviceOutageList.push(outages);
				} else {
					this.isError = true;
					this.validationErrorMessage = SERVICE_OUTAGES_NOT_FOUND;
				}
			} else if (response.result.IPResult.hasOwnProperty('error')) {
				this.isError = true;
				error = response.result.IPResult.error;
				this.validationErrorMessage = error;
			} else {
				this.isError = true;
				this.validationErrorMessage = SERVICE_OUTAGES_NOT_FOUND;
			}
			this.isSpinnerLoaded = false;
		}).catch (error => {
			this.isError = true;
			error = error.message;
			this.validationErrorMessage = error;
			this.isSpinnerLoaded = false;
		});
	}

	/**
	* @description Method to launch vlocity modal.
	*/
	openModal(){
		Promise.resolve().then(() => {
			let modal = this.template.querySelector("vlocity_cmt-modal") ?
					this.template.querySelector("vlocity_cmt-modal") :
			this.template.querySelector("c-modal");
			if (modal) {
				modal.openModal();
			} else {
				console.log("modal is undefined");
			}
		}).catch(error => console.log(error.message));
	}

	/**
	* @description Method to close vlocity modal.
	*/
	closeModal() {
		Promise.resolve().then(() => {
			let modal = this.template.querySelector("vlocity_cmt-modal") ?
					this.template.querySelector("vlocity_cmt-modal") :
			this.template.querySelector("c-modal");
			if (modal) {
				modal.closeModal();
			} else {
				console.log("modal is undefined");
			}
		}).catch(error => console.log(error.message));
	}

	/**
	* @description Method to style button.
	*/
	loadStyles() {
		const style = document.createElement('style');
		style.innerText = `.full-width .slds-button {width: 100%;}`;
		setTimeout(() => {
			this.template.querySelector('lightning-button').appendChild(style);
		}, 100);
	}
}