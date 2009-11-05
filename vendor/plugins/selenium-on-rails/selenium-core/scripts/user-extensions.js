// All get* methods on the Selenium prototype result in
// store, assert, assertNot, verify, verifyNot, waitFor, and waitForNot commands.
// Will result in support for storeContextCount, assertContextCount, etc.
Selenium.prototype.getContextCount = function() {
	return this.browserbot.getCurrentWindow().$('.context').size();
};
