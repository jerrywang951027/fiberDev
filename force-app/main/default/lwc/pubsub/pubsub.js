/**
  * @description To store all the JS functions for the various LWC.
  * This JavaScript file is used to provide many reusability functionality like pubsub.
  * Reusable Apex Calls to Server, Preparing Dynamic Toasts.
  * V2 of PubSub Component
 */

var callbacks = {};

/**
 * @description Registers a callback for an event.
 * @param {string} eventName - Name of the event to listen for.
 * @param {function} callback - Function to invoke when said event is fired.
 */
const register = (eventName, callback) => {
  if (!callbacks[eventName]) {
    callbacks[eventName] = new Set();
  }
  callbacks[eventName].add(callback);
};

/**
 * @description Unregisters a callback for an event.
 * @param {string} eventName - Name of the event to unregister from.
 * @param {function} callback - Function to unregister.
 */
const unregister = (eventName, callback) => {
  if (callbacks[eventName]) {
    callbacks[eventName].delete(callback);
    // delete the callback from callbacks variable
  }
};

/**
 * @description Deletes all the Components from the callbacks params & removes all the listeners and
 * related Callback functions
 */
const unregisterAll = () => {
  callbacks = {};
};

/**
 * @description Fires an event to listeners.
 * @param {string} eventName - Name of the event to fire.
 * @param {*} payload - Payload of the event to fire.
 */
const fire = (eventName, payload) => {
  if (callbacks[eventName]) {
    callbacks[eventName].forEach(callback => {
      try {
        callback(payload);
      } catch (error) {
        // fail silently
        console.log(error);
      }
    });
  }
};

/**
 * @description Export all the functions so that these are accessible from the other JS Classes
 */
export default {
  register,
  unregister,
  fire,
  unregisterAll
};