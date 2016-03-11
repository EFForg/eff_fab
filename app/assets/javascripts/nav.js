function selectChange() {
	var select = document.getElementById("nav-select");
  select = select.options[select.selectedIndex];
  if(select.value == 'All teams') {
    leetFilter.clearFilters();
  } else {
    leetFilter.filterAllBut(select);
  }
}