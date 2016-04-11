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

    _choiceWidget.initialize();
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
    var categoryNameClassy = FilterTool.classifyTeamName(categoryName);

    // Clear the filters
    if (categoryNameClassy == clearFiltersName) {
      clearMarksOnFilterButtons();
      $(".leet-filter-candidate").show();
    } else { // apply a filter
      var element = $(".leet-filter-candidate." + categoryNameClassy);

      clearMarksOnFilterButtons();
      markFilterButtonAsSelected(element);

      hideAllFilterCandidates();
      showSelectionTarget(categoryNameClassy);
    }

  };

  this.clearFilters = function() {
    _choiceWidget.setChoiceByName(clearFiltersName);
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

};











// This is the object that you use to interact with w/e UI element allows you
// to filter teams, be it a dropdown select box or a series of buttons.
// This object is responsible for currency management
var ChoiceWidget = function() {
  var selectorForCategorySections = "leet-filter-candidate";
  var clearFiltersName = "All teams";

  var _currentCategory = FilterTool.classifyTeamName(clearFiltersName);
  var filterCategories = [];
  var filterCategoriesDisplayName = [];


  // for instance, a dropbox would set an int here
  function setSelectedCategoryInDomUnitByIndex(val) {
    // Do the input box
    // document.getElementById("nav-select").options.selectedIndex = val;

    // Do the new layout UL thing
    document.getElementById("leetFilterSelectedDisplay").innerHTML = filterCategoriesDisplayName[val];
  }



  this.initialize = function() {
    if (filterCategories.length <= 0){
      filterCategories = this.getChoicesArray();
      filterCategoriesDisplayName = this.getChoicesDisplayname();
    }
  };

  this.getClearFiltersName = function() {
    return FilterTool.classifyTeamName(clearFiltersName);
  };


  this.getChoicesArray = function() {
    var leetFilterCandidates = document.getElementsByClassName(selectorForCategorySections);

    var arrayOfLeetness = [].slice.call(leetFilterCandidates);
    var categories = arrayOfLeetness.map(function(elements) {
      return FilterTool.classifyTeamName(elements.dataset.filterName);
    });

    // Assume the dropdown starts with the clear filters thing selected
    categories.unshift(FilterTool.classifyTeamName(clearFiltersName));

    return categories;
  };

  this.getChoicesDisplayname = function() {
    var leetFilterCandidates = document.getElementsByClassName(selectorForCategorySections);

    var arrayOfLeetness = [].slice.call(leetFilterCandidates);
    var categories = arrayOfLeetness.map(function(elements) {
      return elements.dataset.filterName;
    });

    categories.unshift(clearFiltersName);
    return categories;
  };


  this.setChoiceByName = function(categoryName) {
    _currentCategory = FilterTool.classifyTeamName(categoryName);
    var i = filterCategories.indexOf(_currentCategory);

    setSelectedCategoryInDomUnitByIndex(i);
  };


  this.chooseNextCategory = function() {
    var targetCategoryName = FilterTool.classifyTeamName(getNextCatName(getCurrentIndex()));
    setSelectedCategoryInDomUnitByIndex(getNextIndex());

    _currentCategory = targetCategoryName;
    return _currentCategory;
  };

  this.choosePrevCategory = function() {
    var targetCategoryName = FilterTool.classifyTeamName(getPrevCatName(getCurrentIndex()));
    setSelectedCategoryInDomUnitByIndex(getPrevIndex());

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

}


// Just a DRY spot to put javascript methods into
var FilterTool = {
  // converts "Web Development" to "Web-Development"
  // converts "/" to "-"
  classifyTeamName: function(teamString) {
    return teamString.trim().replace(/\W/g, "-").replace(/[^0-9A-z.\-]/g, "-");
  }
};



window.choiceWidget = new ChoiceWidget();
window.leetFilter = new LeetFilter(choiceWidget);
