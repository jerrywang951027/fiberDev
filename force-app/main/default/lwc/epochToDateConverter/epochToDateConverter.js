/**
 * @group CSR Console.
 * @description Converts epoch date to date in MM/DD/YYYY.
 */
import { api, LightningElement } from 'lwc';

export default class EpochToDateConverter extends LightningElement {
  @api epochDate;

  /**
   * @description Method to handle the date conversion.
   */
  get localeDate(){
    return new Date(this.epochDate * 1000);
  }
}