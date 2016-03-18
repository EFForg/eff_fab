function selectChange() {
	var select = document.getElementById("nav-select");
  select = select.options[select.selectedIndex];
	leetFilter.SelectCategory(select.value);
}
