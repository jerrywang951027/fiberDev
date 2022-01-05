/**
 * @group CSR Console
 * @description Will show the Billing details in a billing Tab on Service Console.
 */
import { api, LightningElement, track} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const INITIAL_MEMO_COUNT = 10;
const MODAL_UNDEFINED_MSG = 'Modal is undefined.';
const MEMO_CANCELLED_SUCCESS_MSG = 'Memo has been cancelled successfully.';
const ERROR_ON_FETCHING_DETAILS_ERROR_MESSAGE = 'Error occured while fetching details.';
const NO_DATA_BILL_SUMMARY_ERROR_MESSAGE = 'No Bill Summary data available.';
const NO_OTT_HISTORY_ERROR_MESSAGE = 'No One Time Transaction History data available.';

export default class BillingInformation extends OmniscriptBaseMixin(LightningElement) {

  @api recordId;
  billingSummaryData;
  externalId;
  isPendingResponse = true;
  isMemo = false;
  isNextButton = false;
  isPrevButton = false;
  isSpinner = false;
  memo;
  memoArr = [];
  memoPaginationCounter = 0;
  memoRecords;
  totalAmount = 0;
  billingSummaryError;
  ottHistoryError;
  errorMessageWhileFetchingData;

  /**
  * @description Call to loadBillingSummary method on Page/Tab load.
  */
  connectedCallback() {
    this.loadBillingSummary();
  };

  /**
  * @description To get the Billing Summary Data from IP.
  */
  loadBillingSummary() {
    this.isSpinner = true;
    const requestObject = {};
    requestObject.accountId = this.recordId;
    const params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_GetBillingSummary',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      this.isSpinner = false;
      if (response.result.IPResult) {
        this.billingSummaryData = response.result.IPResult;
      } else {
        this.errorMessageWhileFetchingData = NO_DATA_BILL_SUMMARY_ERROR_MESSAGE;
      }
    }).catch (error => {
      this.errorMessageWhileFetchingData = ERROR_ON_FETCHING_DETAILS_ERROR_MESSAGE;
      console.log('Error: ' + error.message);
    });
  }

  /**
  * @description To get the Billing Account Status from the billingSummaryData.
  * @return getBillingAccountStatus
  */
  get getBillingAccountStatus() {
    if (this.billingSummaryData &&
        this.billingSummaryData.fetchZuoraAccountDetails &&
        this.billingSummaryData.fetchZuoraAccountDetails.status) {
      return this.billingSummaryData.fetchZuoraAccountDetails.status;
    }
  }
  /**
  * @description To set the Theme based on Account Status.
  * @return getBillingAccountStatusTheme
  */

  get getBillingAccountStatusTheme() {
    if (this.billingSummaryData &&
        this.billingSummaryData.fetchZuoraAccountDetails &&
        this.billingSummaryData.fetchZuoraAccountDetails.status) {
      if (this.billingSummaryData.fetchZuoraAccountDetails.status === 'Active') {
        return 'slds-badge slds-theme_success slds-p-horizontal_medium';
      } else {
        return 'slds-badge slds-theme_warning slds-p-horizontal_medium';
      }
    }
  }

  /**
  * @description To get the Bill Cycle Day from billingSummaryData.
  * @return getBillCycleDay
  */
  get getBillCycleDay() {
    if (this.billingSummaryData &&
        this.billingSummaryData.fetchZuoraAccountDetails &&
        this.billingSummaryData.fetchZuoraAccountDetails.billCycleDay) {
      return this.billingSummaryData.fetchZuoraAccountDetails.billCycleDay;
    }
  }

  /**
  * @description To get the Next Bill Summary details from billingSummaryData.
  * @return getNextBillSummary
  */
  get getNextBillSummary() {
    const nextBillSummaryArr = [];
    // Get the Invoice Items data from invoiceItems node from API.
    if (this.billingSummaryData &&
        this.billingSummaryData.invoiceItems) {
      // Check if invoiceItems node is an Array.
      if (Array.isArray(this.billingSummaryData.invoiceItems) &&
        this.billingSummaryData.invoiceItems.length > 0) {
          this.billingSummaryData.invoiceItems.filter((item) => {
            nextBillSummaryArr.push(this.formatInvoiceItem(item));
          });
      // Check if invoiceItems node is an Object.
      } else if (this.billingSummaryData.invoiceItems.constructor === Object) {
        nextBillSummaryArr.push(this.formatInvoiceItem(this.billingSummaryData.invoiceItems));
      }
    }
    // Get the Credit Memo Data from credit node from SF.
    if (this.billingSummaryData &&
        this.billingSummaryData.fetchCreditAndDebitMemo &&
        this.billingSummaryData.fetchCreditAndDebitMemo.credit) {
      // Check if credit node is an Array.
      if (Array.isArray(this.billingSummaryData.fetchCreditAndDebitMemo.credit) &&
          this.billingSummaryData.fetchCreditAndDebitMemo.credit.length > 0) {
        this.billingSummaryData.fetchCreditAndDebitMemo.credit.filter((item) => {
          nextBillSummaryArr.push(this.formatCreditOrDebitItem(item, true));
        });
      // Check if credit node is an Object.
      } else if (this.billingSummaryData.fetchCreditAndDebitMemo.credit.constructor === Object) {
        nextBillSummaryArr.push(this.formatCreditOrDebitItem(
            this.billingSummaryData.fetchCreditAndDebitMemo.credit, true));
      }
    }
    // Get the Debit Memo Data from debit node from SF.
    if (this.billingSummaryData &&
        this.billingSummaryData.fetchCreditAndDebitMemo &&
        this.billingSummaryData.fetchCreditAndDebitMemo.debit) {
      // Check if debit node is an Array.
      if (Array.isArray(this.billingSummaryData.fetchCreditAndDebitMemo.debit) &&
          this.billingSummaryData.fetchCreditAndDebitMemo.debit.length > 0) {
        this.billingSummaryData.fetchCreditAndDebitMemo.debit.filter((item) => {
          nextBillSummaryArr.push(this.formatCreditOrDebitItem(item, false));
        });
      // Check if debit node is an Object.
      } else if (this.billingSummaryData.fetchCreditAndDebitMemo.debit.constructor === Object) {
        nextBillSummaryArr.push(this.formatCreditOrDebitItem(
            this.billingSummaryData.fetchCreditAndDebitMemo.debit, false));
      }
    }
    // Get the Credit Memo Items Data from creditMemoItems node from API.
    if (this.billingSummaryData &&
        this.billingSummaryData.creditMemoItems) {
      // Check if creditMemoItems node is an Array.
      if (Array.isArray(this.billingSummaryData.creditMemoItems) &&
          this.billingSummaryData.creditMemoItems.length > 0) {
        this.billingSummaryData.creditMemoItems.filter((item) => {
          nextBillSummaryArr.push(this.formatCreditMemoItem(item));
        });
      // Check if creditMemoItems node is an Object.
      } else if (this.billingSummaryData.creditMemoItems.constructor === Object) {
        nextBillSummaryArr.push(this.formatCreditMemoItem(
            this.billingSummaryData.creditMemoItems));
      }
    }
    if (nextBillSummaryArr.length > 0) {
      this.totalAmount = this.getTotal(nextBillSummaryArr);
      this.billingSummaryError = undefined;
    } else {
      this.billingSummaryError = NO_DATA_BILL_SUMMARY_ERROR_MESSAGE;
    }
    return nextBillSummaryArr;
  }

 /**
  * @description To format Invoice items.
  * @param invoiceItem Unformatted invoice item.
  * @return Formatted Invoice item.
  */
  formatInvoiceItem(invoiceItem) {
    let invoiceItemObject = {};
    invoiceItemObject.date = this.formatDateInMMDDYYYY(invoiceItem.serviceStartDate) + ' - ' +
        this.formatDateInMMDDYYYY(invoiceItem.serviceEndDate);
    if (invoiceItem.chargeName) {
      invoiceItemObject.description = invoiceItem.chargeName;
    } else {
      invoiceItemObject.description = '';
    }
    invoiceItemObject.amount = invoiceItem.chargeAmount.toFixed(2);
    invoiceItemObject.isCredit = false;
    return invoiceItemObject;
  }

 /**
  * @description To format Credit or Debit items.
  * @param creditOrDebitItem Unformatted Credit Or Debit item.
  * @param isCredit True if it is Credit item. And false if it is Debit item.
  * @return Formatted Credit or Debit item.
  */
  formatCreditOrDebitItem(creditOrDebitItem, isCredit) {
    let creditOrDebitItemObject = {};
    creditOrDebitItemObject.date = this.formatDateInMMDDYYYY(creditOrDebitItem.memoDate);
    if (creditOrDebitItem.reasonCode) {
      creditOrDebitItemObject.description = creditOrDebitItem.reasonCode;
    } else {
      creditOrDebitItemObject.description = '';
    }
    creditOrDebitItemObject.amount = creditOrDebitItem.totalAmount.toFixed(2);
    creditOrDebitItemObject.isCredit = isCredit;
    return creditOrDebitItemObject;
  }

 /**
  * @description To format Credit Memo items.
  * @param creditMemoItem Unformatted Credit Memo item.
  * @return Formatted Credit Memo items.
  */
  formatCreditMemoItem(creditMemoItem) {
    let creditMemoItemObj = {};
    creditMemoItemObj.date = this.formatDateInMMDDYYYY(creditMemoItem.serviceStartDate) + ' - ' +
        this.formatDateInMMDDYYYY(creditMemoItem.serviceEndDate);
    if (creditMemoItem.skuName) {
      creditMemoItemObj.description = creditMemoItem.skuName;
    } else {
      creditMemoItemObj.description = '';
    }
    creditMemoItemObj.amount = creditMemoItem.amount.toFixed(2);
    return creditMemoItemObj;
  }
 /**
  * @description To get Total Amount for Next Bill Cycle from the nextBillSummaryArr.
  * @param data Data to calculate Total Amount from.
  * @return Total amount of bill summary with 2 decimal places. The ammount is added if it is
  *     the item type is debit. And the amount is substrated if item type is credit.
  *     The returned total amount is 0 if the total amount is negative.
  */
  getTotal(data) {
    let totalAmount = 0;
    data.forEach((item) => {
      if (item.isCredit) {
        totalAmount -= parseFloat(item.amount);
      } else {
        totalAmount += parseFloat(item.amount);
      }
    });
    if (totalAmount < 0) {
      totalAmount = 0;
    }
    return totalAmount.toFixed(2);
  }
  /**
  * @description Method to call loadBillingSummary method on click of refresh icon button.
  */
  reloadNextBillSummary() {
    this.loadBillingSummary();
  }
  /**
  * @description To get One Time Transaction(OTT) History details from the billingSummaryData.
  * @return getOTTHistory
  */
  get getOTTHistory() {
    let getOTTHistoryArr = [];
    // Get the One Time Transaction History for Debit and Credit Memo.
    if (this.billingSummaryData &&
        this.billingSummaryData.billingDetails &&
        this.billingSummaryData.billingDetails.constructor === Object) {
      // Check if debitMemo node is an Array.
      if (this.billingSummaryData.billingDetails.debitMemo &&
          Array.isArray(this.billingSummaryData.billingDetails.debitMemo) &&
          this.billingSummaryData.billingDetails.debitMemo.length > 0) {
        this.billingSummaryData.billingDetails.debitMemo.filter((item) => {
          getOTTHistoryArr.push(this.formatOTTHistoryCreditOrDebitMemoItem(item, false));
        });
      // Check if debitMemo node is an Object.
      } else if (this.billingSummaryData.billingDetails.debitMemo &&
        this.billingSummaryData.billingDetails.debitMemo.constructor === Object) {
        getOTTHistoryArr.push(this.formatOTTHistoryCreditOrDebitMemoItem(
            this.billingSummaryData.billingDetails.debitMemo, false));
      }
      // Check if creditMemo node is an Array.
      if (this.billingSummaryData.billingDetails.creditMemo &&
          Array.isArray(this.billingSummaryData.billingDetails.creditMemo) &&
          this.billingSummaryData.billingDetails.creditMemo.length > 0) {
        this.billingSummaryData.billingDetails.creditMemo.filter((item) => {
          getOTTHistoryArr.push(this.formatOTTHistoryCreditOrDebitMemoItem(item, true));
        });
      // Check if creditMemo node is an Object.
      } else if (this.billingSummaryData.billingDetails.creditMemo &&
          this.billingSummaryData.billingDetails.creditMemo.constructor === Object) {
        getOTTHistoryArr.push(this.formatOTTHistoryCreditOrDebitMemoItem(
            this.billingSummaryData.billingDetails.creditMemo, true));
      }
      // Sort the getOTTHistoryArr based on Memo Date.
      getOTTHistoryArr = this.sortArray(getOTTHistoryArr);
      // Pagination logic on Page Load and Page Refresh.
      if (this.isPendingResponse) {
        this.memoArr = getOTTHistoryArr;
        if (this.memoArr && this.memoArr.length > 0) {
          this.memoPaginationCounter=0;
          this.memoPaginationCounter += INITIAL_MEMO_COUNT;
          this.memoRecords = this.memoArr.slice(0, this.memoPaginationCounter);
          if (this.memoArr.length <= INITIAL_MEMO_COUNT) {
            this.isNextButton = false;
          } else {
            this.isNextButton = true;
          }
        }
      }
    }
    if (this.memoRecords && this.memoRecords.length > 0) {
      this.ottHistoryError = undefined;
    } else {
      this.ottHistoryError = NO_OTT_HISTORY_ERROR_MESSAGE;
    }
    return this.memoRecords;
  }

 /**
  * @description To format Credit Or Debit OTT History items.
  * @param creditOrDebitMemoItem Unformatted Credit Or Debit OTT History item.
  * @return Formatted Credit Or Debit OTT History item.
  */
  formatOTTHistoryCreditOrDebitMemoItem(creditOrDebitMemoItem, isCredit) {
    const todaysDate = new Date().toISOString().split('T')[0];
    let creditOrDebitMemoItemObj = {};
    creditOrDebitMemoItemObj.id = creditOrDebitMemoItem.id;
    creditOrDebitMemoItemObj.requesterLDAP = creditOrDebitMemoItem.requesterLDAP;
    creditOrDebitMemoItemObj.bugafiberId = creditOrDebitMemoItem.bugafiberId;
    if (creditOrDebitMemoItem.memoDate) {
      creditOrDebitMemoItemObj.memoDate =
          this.formatDateInMMDDYYYY(creditOrDebitMemoItem.memoDate);
    } else {
      creditOrDebitMemoItemObj.memoDate = '';
    }
    creditOrDebitMemoItemObj.reasonCode = creditOrDebitMemoItem.reasonCode;
    creditOrDebitMemoItemObj.totalAmount = creditOrDebitMemoItem.totalAmount.toFixed(2);
    creditOrDebitMemoItemObj.memo = isCredit ? 'Credit' : 'Debit';
    creditOrDebitMemoItemObj.isDebit = !isCredit;
    creditOrDebitMemoItemObj.isCredit = isCredit;
    creditOrDebitMemoItemObj.externalId = creditOrDebitMemoItem.externalId;
    creditOrDebitMemoItemObj.createdDate = creditOrDebitMemoItem.createdDate;
    if (creditOrDebitMemoItem.createdDate) {
      let createdDate = creditOrDebitMemoItem.createdDate.split('T')[0];
      if (createdDate === todaysDate) {
        creditOrDebitMemoItemObj.isCancelMemoBtnDisabled = false;
      } else {
        creditOrDebitMemoItemObj.isCancelMemoBtnDisabled = true;
      }
    }
    return creditOrDebitMemoItemObj;
  }

  /**
  * @description To sort the OTTHistory data based on Memo Date.
  * @param data Data to be sorted.
  * @return sortArray
  */
  sortArray(data) {
    return data.sort(function(a, b) {
      var keyA = new Date(a.createdDate),
        keyB = new Date(b.createdDate);
      // Compare the 2 dates
      if (keyA > keyB) return -1;
      if (keyA < keyB) return 1;
      return 0;
    });
  }

  /**
  * @description To set the data in desired format (MM/DD/YYYY).
  * @param date Date to be formatted.
  * @return formatDateInMMDDYYYY
  */
  formatDateInMMDDYYYY(date) {
    const dateArr = date.split('-');
    return `${dateArr[1]}/${dateArr[2]}/${dateArr[0]}`;
  }

  /**
  * @description To get the next 10 Debit and Credit Memos.
  */
  loadNextMemo() {
    if (this.memoPaginationCounter < this.memoArr.length) {
      this.memoPaginationCounter += INITIAL_MEMO_COUNT;
      this.memoRecords = this.memoArr.slice(0, this.memoPaginationCounter);
      this.isPrevButton = true;
      this.isPendingResponse = false;
      if (this.memoPaginationCounter >= this.memoArr.length) {
        this.isNextButton = false;
      }
    }
  }

  /**
  * @description To get the previous 10 Debit and Credit Memos.
  */
  loadPreviousMemo() {
    if (this.memoPaginationCounter !== INITIAL_MEMO_COUNT) {
      this.memoPaginationCounter -= INITIAL_MEMO_COUNT;
      this.memoRecords = this.memoArr.slice(0, this.memoPaginationCounter);
      this.isNextButton = true;
      if (this.memoPaginationCounter === INITIAL_MEMO_COUNT) {
        this.isPrevButton = false;
      }
    }
  }

  /**
  * @description Method to get Confirmation when clicked on cancel and call the openModal method.
  * @param event onclick event.
  */
  cancellationConfirmation(event) {
    this.externalId = event.target.name;
    this.memo = event.currentTarget.dataset.memo;
    this.openModal();
  }

  /**
  * @description Method to cancel the Credit or Debit Memo using an IP when clicked on cancel.
  */
  callToCancelMemo() {
    this.closeModal();
    this.isSpinner = true;
    const requestObject = {};
    requestObject.externalId = this.externalId;
    requestObject.memo = this.memo;
    const params = {
      input: JSON.stringify(requestObject),
      sClassName: 'vlocity_cmt.IntegrationProcedureService',
      sMethodName: 'CON_CancelCreditOrDebitMemo',
      options: '{}'
    };
    this.omniRemoteCall(params, true).then(response => {
      this.isSpinner = false;
      this.isPendingResponse = true;
      if (response.result.IPResult.status) {
        this.showNotification('Success', this.memo + MEMO_CANCELLED_SUCCESS_MSG, 'success');
        let _this = this;
        setTimeout(function() {
          _this.loadBillingSummary();
        }, 1000);
      } else {
        this.showNotification('Error', response.result.IPResult.reasons[0].message, 'error');
      }
    }).catch (error => {
      console.log('Error: ' + error.message);
    });
  }

  /**
  * @description Method to open Modal.
  */
  openModal() {
    Promise.resolve().then(() => {
      let modal = this.template.querySelector('vlocity_cmt-modal') ?
          this.template.querySelector('vlocity_cmt-modal') :
          this.template.querySelector('c-modal');
      if (modal) {
        modal.openModal();
      } else {
        console.log('Error: ' + MODAL_UNDEFINED_MSG);
      }
    }).catch (error => console.log(error.message));
  }

  /**
  * @description Method to close Modal.
  */
  closeModal() {
    Promise.resolve().then(() => {
      let modal = this.template.querySelector('vlocity_cmt-modal') ?
          this.template.querySelector('vlocity_cmt-modal') :
          this.template.querySelector('c-modal');
      if (modal) {
        modal.closeModal();
      } else {
        console.log('Error: ' + MODAL_UNDEFINED_MSG);
      }
    }).catch (error => console.log(error.message));
  }

  /**
  * @description Method to show the Notification after cancelling the Credit or Debit Memo.
  * @param title Title of the Notification.
  * @param message Message to be displayed in the Notification.
  * @param variant Variant of Notification (success/error).
  */
  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}