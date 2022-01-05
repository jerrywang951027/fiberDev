import {
	api,
	LightningElement,
	track
} from 'lwc';
import {
	OmniscriptBaseMixin
} from 'vlocity_cmt/omniscriptBaseMixin';
import {
	register,
	unregister,
	fire
} from 'vlocity_cmt/pubsub';
import {
	ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
	CloseActionScreenEvent
} from 'lightning/actions';

export default class SendEmail extends OmniscriptBaseMixin(LightningElement) {
	@track isModalOpen = false;
	@api recordId;
	@track addCommentToTicketIP = false;
	@track folder = '';
	@track record;
	@track error;
	@track subject;
	@track emailBody;
	@track email;
	@track TypeOptions;
	@track flag = false;
	@track isOpenContact = false;
	@track isCloseContact = false;
	@track errorMessage;
	@track showLoading = true;
	@track isError = false;

	connectedCallback() {
		this.getContactTicket(this.recordId);
		this.getFolder();
		this.getTemplates();
		this.getAcccountORLeadEmail(this.recordId);
	}

	emailChange(event) {
		this.email = event.target.value;
	}
	bodyChange(event) {
		this.emailBody = event.target.value;
	}

	/**
	 * calling Apex method
	 */
	getFolder() {
		let result;
		let params = {
			input: '{}',
			sClassName: 'TicketingUtils',
			sMethodName: 'getFolder',
			options: '{}'
		};
		this.omniRemoteCall(params, true).then(response => {
			console.log(JSON.stringify(response.result.label));
			result = response.result.label;
			this.onResponseSuccess(result);
		}).catch(error => {
			this.searchMessage = false;
		});
	}
	onResponseSuccess(result) {
		this.folder = result;
	}

	getTemplates() {
		let result;
		let params = {
			input: '{}',
			sClassName: 'TicketingUtils',
			sMethodName: 'getTemplates',
			options: '{}'
		};
		this.omniRemoteCall(params, true).then(response => {
			console.log(JSON.stringify(response));
			result = (typeof response.result.options === 'string') ?
				JSON.parse(response.result.options) : response.result.options;
			this.onResponseSuccess1(result);
		}).catch(error => {
			this.searchMessage = false;
		});
	}
	onResponseSuccess1(result) {
		let options = [];
		for (var key in result) {
			options.push({
				label: result[key].TemplateLabel,
				value: result[key].Id
			});
		}
		this.TypeOptions = options;
	}
	changeTemplate(event) {
		this.templateDetail(event.target.value);

	}

	templateDetail(templateId) {
		try {
			let params = {
				input: {},
				sClassName: 'TicketingUtils',
				sMethodName: 'getEmailTemplateDetail',
				options: '{}'
			};
			let inputObject = {};
			inputObject.templateId = templateId;
			let inputMap = JSON.stringify(inputObject);
			params.input = inputMap;

			this.omniRemoteCall(params, true).then(response => {
				console.log(JSON.stringify(response));
				this.subject = response.result.subject;
				this.emailBody = response.result.body;
				result = (typeof response.result.options === 'string') ?
					JSON.parse(response.result.options) : response.result.options;
				this.onResponseSuccess1(result);
			}).catch(error => {
				this.searchMessage = false;
			});
		} catch (e) {
			console.log('templateDetails : ' + e);
		}
	}

	getAcccountORLeadEmail(recordId) {
		let result;
		let params = {
			input: '{}',
			sClassName: 'TicketingUtils',
			sMethodName: 'getEmail',
			options: '{}'
		};

		let inputObject = {};
		inputObject.recordId = this.recordId;
		let inputMap = JSON.stringify(inputObject);
		params.input = inputMap;
		this.omniRemoteCall(params, true).then(response => {
			console.log(JSON.stringify(response.result.email));
			result = response.result.email;
			this.email = result;
		}).catch(error => {
			this.searchMessage = false;
		});
	}

	showSuccessToast() {
		const evt = new ShowToastEvent({
			title: 'Success',
			message: 'Email sent to ' + this.email,
			variant: 'success',
			mode: 'dismissable'
		});
	}

	getContactTicket(recordId) {
		let result;
		let params = {
			input: '{}',
			sClassName: 'TicketingUtils',
			sMethodName: 'getContactTicket',
			options: '{}'
		};

		let inputObject = {};
		inputObject.recordId = this.recordId;
		let inputMap = JSON.stringify(inputObject);
		params.input = inputMap;
		this.omniRemoteCall(params, true).then(response => {
			console.log(JSON.stringify(response.result.isContact));
			result = response.result.isContact;
			if (result == true) {
				this.isOpenContact = result;
			}
			if (result == false) {
				this.isCloseContact = true;
			}
		}).catch(error => {
			this.searchMessage = false;
		});
	}

	onSave() {
		if (this.subject == undefined) {
			alert('Please select template option');
		} else {
			this.showLoading = true;
			this.flag = true;
			this.isOpenContact = false;
			let result;
			let params = {
				input: '{}',
				sClassName: 'TicketingUtils',
				sMethodName: 'sendEmailService',
				options: '{}'
			};

			let inputObject = {};
			inputObject.recordId = this.recordId;
			inputObject.subject = this.subject;
			inputObject.emailId = this.email;
			inputObject.body = this.emailBody;
			let inputMap = JSON.stringify(inputObject);
			params.input = inputMap;

			this.omniRemoteCall(params, true).then(response => {
				console.log(JSON.stringify(response.result.error));
				result = response.result.error;
				if (result == "OK") {
					this.showLoading = false;
				} else {
					this.isOpenContact = false;
					this.errorMessage = result;
					this.isError = true;
					this.showLoading = false;
				}
			}).catch(error => {
				this.searchMessage = false;
				this.showLoading = false;
			});
		}

	}
}