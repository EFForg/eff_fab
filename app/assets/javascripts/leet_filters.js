var LeetFilter = function() {

  this.filterAllBut = function(element) {
    filterTarget = elementToClassName(element);
    // Toggle UI to show target
    $('.leet-filter-button-selected').removeClass('leet-filter-button-selected');
    $(element).addClass('leet-filter-button-selected');

    // hide all potential targets
    $(".leet-filter-candidate").hide();

    // show filterTarget
    $(".leet-filter-candidate." + filterTarget).show();
  };

  this.toggleFilterFor = function(element) {
    filterTarget = elementToClassName(element);
    console.log('not implemented: not ideal UX');
  };


  this.clearFilters = function() {
    $(".leet-filter-candidate").show();
    $('.leet-filter-button-selected').removeClass('leet-filter-button-selected');
  };

  function elementToClassName(element) {
    filterTarget = element.innerHTML;
    return filterTarget.trim().replace(" ", "-").replace(/[^0-9A-z.\-]/g, "_");
  }

}

window.leetFilter = new LeetFilter();
