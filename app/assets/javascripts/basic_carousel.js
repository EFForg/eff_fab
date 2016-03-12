(function() {

  var BasicCarousel = function() {

    // apply this to a selector that will get divs...
    // the divs must have a data-user-id and a data-fab-id
    // The divs must also contain navigation buttons:
    // .fab-backward-btn and .fab-forward-btn
    this.register = function(selector) {

      $(selector).each(function() {

        // Make it so when you click the child nav button, they look for the
        // parent's data and conduct the appropriate ajax/ view change action
        $(this).children('.fab-backward-btn').first().click(function() {
          cycleFab_click(this, false);
        });

        $(this).children('.fab-forward-btn').first().click(function() {
          cycleFab_click(this, true);
        });

      });

    };

    function cycleFab_click(button_element, forward) {
      var fab_encapsulator = $(button_element).parent();

      var cycle_options = {
        user_id: fab_encapsulator.attr('data-user-id'),
        fab_id: fab_encapsulator.attr('data-fab-id'),
        fab_period: fab_encapsulator.attr('data-fab-period')
      }

      var direction = forward ? 'forward' : 'backward';

      requestCycledFab(direction, cycle_options, function(markup) {
        var new_fab_id = markup.split('\n')[0];
        var which_fabs_exist = JSON.parse(markup.split('\n')[1]);

        disablePreviousOrNextBarsIfNeeded(fab_encapsulator, which_fabs_exist);
        markup = markup.split("\n").slice(2).join("\n");
        populateFabInDisplay(markup, fab_encapsulator);
        fab_encapsulator.attr('data-fab-id', new_fab_id);
      });
    }

    function disablePreviousOrNextBarsIfNeeded(fab_element, which_fabs_exist) {
      var previous_fab_exists = which_fabs_exist[0];
      var next_fab_exists = which_fabs_exist[1];

      enableAndDisableButtonsAsAppropriate();

      function enableAndDisableButtonsAsAppropriate() {
        if (previous_fab_exists)
          fab_element.children('.fab-backward-btn').first().removeClass('disabled');
        else
          fab_element.children('.fab-backward-btn').first().addClass('disabled');

        if (next_fab_exists)
          fab_element.children('.fab-forward-btn').first().removeClass('disabled');
        else
          fab_element.children('.fab-forward-btn').first().addClass('disabled');
      }

    }

    function requestCycledFab(direction, cycle_options, cb) {
      var action = (direction == "forward") ? "/tools/next_fab?" : "/tools/previous_fab?"
      var query_list = [];
      query_list.push("user_id=" + cycle_options.user_id);
      if (cycle_options.fab_id != undefined)
        query_list.push("fab_id=" + cycle_options.fab_id);
      if (cycle_options.fab_period != undefined)
        query_list.push("fab_period=" + cycle_options.fab_period);

      var url = action + query_list.join("&");
      return ajaxRequest(url, function(data) {
        cb(data);
      });
    }

    function ajaxRequest(url, cb) {
      $.ajax({
        url: url,
        success: function(data){
          if (data != "no such fab")
            cb(data);
        },
        error: function(e){
          console.log("ajaxRequest failed for " + url);
        }
      });
    }

    // removes the old forward notes, and overwrites the backward notes with
    // the backward AND forward... kinda odd... javascript...
    function populateFabInDisplay(markup, fab_element) {
      var backward_notes = fab_element.children('.forward-back').first();
      var forward_notes = fab_element.children('.forward-back').last();

      forward_notes.remove();
      // TODO:  research how to do this with Tribby's templates and json?
      backward_notes[0].outerHTML = markup;

    }

  };
  window.basicCarousel = new BasicCarousel();

})();
