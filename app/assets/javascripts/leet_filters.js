// This class is for making everything filterable and stuff....
var LeetFilter = function(choiceWidget) {
  var _choiceWidget = choiceWidget;
  var clearFiltersName = choiceWidget.getClearFiltersName();

  this.enableKeyboardHooks = function(prevAndNextKeyCodes) {
    var prevKeyCode = prevAndNextKeyCodes[0];
    var nextKeyCode = prevAndNextKeyCodes[1];

    var self = this;

    document.onkeypress = function(e) {
      if(e.keyCode == prevKeyCode)
        self.cyclePrevCategory(self);

      if(e.keyCode == nextKeyCode)
        self.cycleNextCategory(self);
    };

    // initialize the page with the filters cleared... is this good?
    // document.getElementById("nav-select").options.selectedIndex = 0;
  };

  this.selectCategoryByName = function(categoryName) {
    _choiceWidget.setChoiceByName(categoryName);
    this.refreshDisplayedCategory(categoryName);
  }

  this.cyclePrevCategory = function(self) {
    var targetCategoryName = _choiceWidget.choosePrevCategory();
    self.refreshDisplayedCategory(targetCategoryName);
  };

  this.cycleNextCategory = function(self) {
    var targetCategoryName = _choiceWidget.chooseNextCategory();
    self.refreshDisplayedCategory(targetCategoryName);
  };

  // Pass in a category name (the valid css class form)
  // and this function will show that category exclusively, hiding others
  this.refreshDisplayedCategory = function(categoryName) {
    categoryName = classifyTeamName(categoryName);

    // Clear the filters
    if (categoryName == clearFiltersName) {
      clearMarksOnFilterButtons();
      $(".leet-filter-candidate").show();
    } else { // apply a filter
      var element = $(".leet-filter-candidate." + categoryName);

      clearMarksOnFilterButtons();
      markFilterButtonAsSelected(element);

      hideAllFilterCandidates();
      showSelectionTarget(categoryName);
    }

  };

  this.clearFilters = function() {
    $(".leet-filter-candidate").show();
    clearMarksOnFilterButtons();
  };

  // hide all potential targets
  function hideAllFilterCandidates() {
    $(".leet-filter-candidate").hide();
  }

  // show the non filtered thing...
  function showSelectionTarget(categoryName) {
    $(".leet-filter-candidate." + categoryName).show();
  }

  // Supply an element and it will have a selected class added to it for
  // highlighting purposes of buttons
  function markFilterButtonAsSelected(element) {
    $(element).addClass('leet-filter-button-selected');
  }

  // Set any filtering buttons to not be highlighted
  function clearMarksOnFilterButtons() {
    $('.leet-filter-button-selected').removeClass('leet-filter-button-selected');
  }

  // converts "Web Development" to "Web-Development"
  function classifyTeamName(teamString) {
    return teamString.trim().replace(" ", "-").replace(/[^0-9A-z.\-]/g, "_");
  }

};











// This is the object that you use to interact with w/e UI element allows you
// to filter teams, be it a dropdown select box or a series of buttons.
// This object is responsible for currency management
var ChoiceWidget = function() {
  var clearFiltersName = "All-teams";
  var _currentCategory = clearFiltersName;

  var filterCategories = [];

  this.initialize = function() {
    if (filterCategories.length <= 0)
      filterCategories = this.getChoicesArray();
  };

  this.getClearFiltersName = function() {
    return clearFiltersName;
  };


  this.getChoicesArray = function() {
    var leetFilterCandidates = document.getElementsByClassName("leet-filter-candidate");

    var arrayOfLeetness = [].slice.call(leetFilterCandidates);
    var categories = arrayOfLeetness.map(function(elements) {
      return classifyTeamName(elements.dataset.filterName);
    });

    // Assume the dropdown starts with the clear filters thing selected
    categories.unshift(clearFiltersName);

    return categories;
  };


  this.setChoiceByName = function(categoryName) {
    var targetCategoryName = classifyTeamName(categoryName);
    _currentCategory = targetCategoryName;
  };


  this.chooseNextCategory = function() {
    this.initialize();

    var targetCategoryName = classifyTeamName(getNextCatName(getCurrentIndex()));
    document.getElementById("nav-select").options.selectedIndex = getNextIndex();

    _currentCategory = targetCategoryName;
    return _currentCategory;
  };

  this.choosePrevCategory = function() {
    this.initialize();

    var targetCategoryName = classifyTeamName(getPrevCatName(getCurrentIndex()));
    document.getElementById("nav-select").options.selectedIndex = getPrevIndex();

    _currentCategory = targetCategoryName;
    return _currentCategory;
  };


  function getCurrentIndex() {
    return filterCategories.indexOf(_currentCategory);
  }

  function getNextIndex() {
    return stepThroughCategories(1);
  }

  function getPrevIndex() {
    return stepThroughCategories(-1);
  }

  function stepThroughCategories(nSteps) {
    return (filterCategories.length + getCurrentIndex() + nSteps) % filterCategories.length;
  }

  function getNextCatName(currentIndex) {
    return getCatNameByIndex(getNextIndex());
  }

  function getPrevCatName(currentIndex) {
    return getCatNameByIndex(getPrevIndex());
  }

  // move to choiceWidget
  function getCatNameByIndex(index) {
    return filterCategories[index];
  }

  // TODO: Make dry via mixin
  function classifyTeamName(teamString) {
    return teamString.trim().replace(" ", "-").replace(/[^0-9A-z.\-]/g, "_");
  }

}


window.choiceWidget = new ChoiceWidget();
window.leetFilter = new LeetFilter(choiceWidget);
