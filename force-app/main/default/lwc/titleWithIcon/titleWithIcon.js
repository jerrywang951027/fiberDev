import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class TitleWithIcon extends OmniscriptBaseMixin(LightningElement) {
  _icon;
  _title;
  _alternativeText;

  /**
   * @description Getter to return decorator _omniJsonData
   * @return _omniJsonData
   */
  @api
  get icon() {
    return this._icon;
  }

  set icon(data) {
    if (data) {
      this._icon = data;
    }
  }

  /**
   * @description Getter to return decorator _omniJsonData
   * @return _omniJsonData
   */
  @api
  get title() {
    return this._title;
  }

  set title(data) {
    if (data) {
      this._title = data;
    }
  }

  /**
   * @description Getter to return decorator _omniJsonData
   * @return _omniJsonData
   */
  @api
  get alternativeText() {
    return this._alternativeText;
  }

  set alternativeText(data) {
    if (data) {
      this._alternativeText = data;
    }
  }
}