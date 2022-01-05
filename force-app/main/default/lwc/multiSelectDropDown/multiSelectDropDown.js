/**
 * @description this component is cloned from
 * https://www.sfdcpanther.com/how-to-create-a-multi-select-picklist-using-lwc/
 */
import {api, LightningElement, track} from 'lwc';

export default class MultiSelectPicklistLwc extends LightningElement {
  @api
  label = 'Default label';
  @track
  inputOptions;
  @track
  inputValue = 'All';
  comboboxIsRendered;
  _disabled = false;
  dropDownInFocus = false;
  hasRendered;
  value = [];

  @api
  get disabled() {
    return this._disabled;
  }

  set disabled(value) {
    this._disabled = value;
    this.handleDisabled();
  }

  @api
  get options() {
    return this.inputOptions.filter(option => option.value !== 'All');
  }

  set options(value) {
    let options = [{value: 'All', label: 'All'}];
    this.inputOptions = options.concat(value);
  }

  @api
  clear() {
    this.handleAllOption();
  }

  renderedCallback() {
    if (!this.hasRendered) {
      //  we coll the logic once, when page rendered first time
      this.handleDisabled();
    }
    this.hasRendered = true;
  }

  handleDisabled() {
    let input = this.template.querySelector('input');
    if (input) {
      input.disabled = this.disabled;
    }
  }

  handleClick() {
    let sldsCombobox = this.template.querySelector('.slds-combobox');
    sldsCombobox.classList.toggle('slds-is-open');
    if (!this.comboboxIsRendered) {
      let allOption = this.template.querySelector('[data-id="All"]');
      allOption.firstChild.classList.add('slds-is-selected');
      this.comboboxIsRendered = true;
    }
  }

  handleSelection(event) {
    let value = event.currentTarget.dataset.value;
    if (value === 'All') {
      this.handleAllOption();
      // this.value = this.options;
    } else {
      this.handleOption(event, value);
    }
    let input = this.template.querySelector('input');
    input.focus();
    this.sendValues('valuechange');
  }

  sendValues(event) {
    let values = [];
    for (const valueObject of this.value) {
      values.push(valueObject.value);
    }
    this.dispatchEvent(new CustomEvent(event, {detail: values}));
  }

  handleAllOption() {
    this.value = [];
    this.inputValue = 'All';
    let listBoxOptions = this.template.querySelectorAll('.slds-is-selected');
    for (let option of listBoxOptions) {
      option.classList.remove('slds-is-selected');
    }
    let allOption = this.template.querySelector('[data-id="All"]');
    allOption.firstChild.classList.add('slds-is-selected');
    this.closeDropbox();
  }

  handleOption(event, value) {
    let listBoxOption = event.currentTarget.firstChild;
    if (listBoxOption.classList.contains('slds-is-selected')) {
      this.value = this.value.filter(option => option.value !== value);
    } else {
      let allOption = this.template.querySelector('[data-id="All"]');
      allOption.firstChild.classList.remove('slds-is-selected');
      let option = this.options.find(option => option.value === value);
      this.value.push(option);
    }
    if (this.value.length > 1) {
      this.inputValue = this.value.length + ' options selected';
    } else if (this.value.length === 1) {
      this.inputValue = this.value[0].label;
    } else {
      this.inputValue = 'All';
    }
    listBoxOption.classList.toggle('slds-is-selected');
  }

  handleBlur() {
    if (!this.dropDownInFocus) {
      this.closeDropbox();
      this.sendValues('clickedoutside');
    }
  }

  handleMouseleave() {
    this.dropDownInFocus = false;
  }

  handleMouseEnter() {
    this.dropDownInFocus = true;
  }

  closeDropbox() {
    let sldsCombobox = this.template.querySelector('.slds-combobox');
    sldsCombobox.classList.remove('slds-is-open');
  }
}