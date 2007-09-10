/*
 * By default, Selenium looks for a file called "user-extensions.js", and loads and javascript
 * code found in that file. This file is a sample of what that file could look like.
 *
 * user-extensions.js provides a convenient location for adding extensions to Selenium, like
 * new actions, checks and locator-strategies.
 * By default, this file does not exist. Users can create this file and place their extension code
 * in this common location, removing the need to modify the Selenium sources, and hopefully assisting
 * with the upgrade process.
 *
 * You can find contributed extensions at http://wiki.openqa.org/display/SEL/Contributed%20User-Extensions
 */

// All get* methods on the Selenium prototype result in
// store, assert, assertNot, verify, verifyNot, waitFor, and waitForNot commands.
// E.g. add a getTextLength method that returns the length of the text
// of a specified element.
// Will result in support for storeContextCount, assertContextCount, etc.
Selenium.prototype.getContextCount = function() {
	return this.browserbot.getCurrentWindow().$$('.context').length;
};



