function selectChange() {
	var select = document.getElementById("nav-select");
  select = select.options[select.selectedIndex];
	fabFilter.selectCategoryByName(select.value);
}

// for select html elements, we need to override their onkeydown and onkeyup
// to run our selectionChanging code to update the display
function preventGlitchySelectness(event) {
	selectChange();
}
