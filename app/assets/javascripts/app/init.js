window.APP = {};
window.APP.pages = {};

// Call this from the layouts/application.html.erb to fire page specific
// javascript when using turbolinks!
function invokePageSpecificJavascript() {
	window.pageIdentifier = document.body.getAttribute("id");

	if (APP.pages && APP.pages[pageIdentifier]) {
		APP.currentPage = new APP.pages[pageIdentifier]();
	}
}
