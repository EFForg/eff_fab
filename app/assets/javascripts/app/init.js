window.APP = {};
window.APP.pages = {};

// Code right here is run 1 time... ever... it happens on w/e page you hit, but
// further navigating will not run this code again (it's in the HEAD)


// Call this from the layouts/application.html.erb to fire page specific
// javascript when using turbolinks!
// This code is run on every load of every page (but not forward/ back button presses)
// eg be careful when setting up hooks on the entire document
function invokePageSpecificJavascript() {
	instantiateOrResetParalax();

	window.pageIdentifier = document.body.getAttribute("id");

	if (APP.pages && APP.pages[pageIdentifier]) {
		APP.currentPage = new APP.pages[pageIdentifier]();
	}
}

// Unfortunate code for sorting out when to fire tribbalax code in a turbolinks
// environment...  Use it in step with wherever page specific js is called
function instantiateOrResetParalax() {
	if (window.tribbalax === undefined) {
		// this code will only be run once, the first page load on the site

		// Tribbalax must not be instantiated until the '<nav>' element exists...
		// so down the page somehow....
		window.tribbalax = new Tribbalax();

		// Registers the paralax code to run when hitting the back/ forward buttons
		// which are loaded from cache...
		$(document).on('page:restore', tribbalax.reInitializeParalax);
	}
	else {
		// This code will be run when the above code isn't run, so clicking any
		// turbolink anchors...
		tribbalax.reInitializeParalax();
	}
}
