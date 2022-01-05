import { api, LightningElement, track } from "lwc";
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import pubsub from "vlocity_cmt/pubsub";
export default class geopointeLWC extends OmniscriptBaseMixin(LightningElement) {

  @api actionName;
  @api recordId;

  @track isDisqualifiedFlow;
  @track isInProgressFlow;
  @track isSignUpFlow;
  @track omniscriptParameters;

  /**
   * @description Will be fired when a component is inserted into the DOM.
   * This method decides which Geopointe flow to execute.
   */
  connectedCallback() {
    this.omniscriptParameters = {
      ContextId: this.recordId,
      actionName: this.actionName
    };

    if (this.actionName == "SignUp") {
      this.isSignUpFlow = true;
    } else if (this.actionName == "InProgress") {
      this.isInProgressFlow = true;
    } else if (this.actionName == "Disqualified") {
      this.isDisqualifiedFlow = true;
    }
    this.registerPubSub();
  }

  /**
   * @description Method to register the pubsub.
   * This method listens to the event published by OmniScript
   */
  registerPubSub() {
    pubsub.register("omniscript_action", {
      data: this.handleOmniAction.bind(this)
    });
  }

  /**
   * @description Method to fire custom event from this LWC.
   * and bubble it to VisualForce page to close the VisualForce page.
   */
  handleOmniAction(data) {
    if (data && typeof data.status !== undefined && data.status) {
      const submitInfo = {
        status: data.status
      };
      this.dispatchEvent(
        new CustomEvent("onSubmit", {
          detail: {
            data: submitInfo
          },
          bubbles: true,
          composed: true
        })
      );
    }
  }
}