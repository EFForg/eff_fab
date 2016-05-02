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
      var button_element = $(button_element);
      if (button_element.hasClass('carouselBusy'))
        return; // we're already waiting for a server response it seems

      var fab_encapsulator = button_element.parent();

      var cycle_options = {
        user_id: fab_encapsulator.attr('data-user-id'),
        fab_id: fab_encapsulator.attr('data-fab-id'),
        fab_period: fab_encapsulator.attr('data-fab-period')
      }

      var direction = forward ? 'forward' : 'backward';


      setCarouselToBusy(button_element);

      // FIXME: OO refactor so the selectors aren't all brain fucks, then enable
      // an initial shake animation via queing
      // Shake the display so user knows what will change
      // fab_encapsulator.children('.back').first().effect( "shake" );
      // fab_encapsulator.children('.forward').first().effect( "shake" );

      requestCycledFab(direction, cycle_options, function(markup) {
        var options = JSON.parse(markup.split(';')[0]);
        var new_fab_id = options.fab_id;
        var new_fab_period = options.fab_period;
        var which_fabs_exist = options.neighbor_presence;

        disablePreviousOrNextBarsIfNeeded(fab_encapsulator, which_fabs_exist);
        markup = markup.split(";").slice(1).join(";");

        populateFabInDisplay(markup, fab_encapsulator, function(oldBackwardAndForward) {

          slideExistingFabAway(direction, fab_encapsulator, function() {

            animateEntry(oldBackwardAndForward[0], direction);
            animateEntry(oldBackwardAndForward[1], direction);

            setCarouselToReady(button_element);
          });

        });


        fab_encapsulator.attr('data-fab-period', new_fab_period);
      });
    }

    function setCarouselToBusy(button_element) {
      var fab_encapsulator = button_element.parent();

      // Disable the buttons
      // Display a loading thing

      fab_encapsulator.children('a').addClass('carouselBusy');
      button_element.addClass('icon-spin5 animate-spin carouselShrink');
      button_element.html('');
    }

    function setCarouselToReady(button_element) {
      var fab_encapsulator = button_element.parent();

      fab_encapsulator.children('a').removeClass('carouselBusy');
      button_element.removeClass('icon-spin5 animate-spin carouselShrink');

      // Restore the original symbols now that the glyphicon is disabled
      if (button_element.hasClass('fab-forward-btn'))
        button_element.html('&gt;');
      else
        button_element.html('&lt;');
    }

    function slideExistingFabAway(direction, fab_encapsulator, cbForShowingNew) {
      var old_backward_notes = fab_encapsulator.children('.back').first();
      var old_forward_notes = fab_encapsulator.children('.forward').first();

      animateDisappearance(old_forward_notes, direction);
      animateDisappearance(old_backward_notes, direction, cbForShowingNew);
    }

    function animateDisappearance(notes, direction, cb) {
      var polarity = direction === "forward" ? -1 : 1;
      var base_dist = 1050;
      if (polarity === -1)
        base_dist -= 320;

      notes.animate({
          left: (base_dist * polarity)
        }, {
          duration: 100,
          easing: "swing",
          complete: function() {
            /* delete the elements */
            notes[0].remove();
            if (typeof cb === "function")
              cb();
          }
        }
      );
    }

    function animateEntry(newColumn, direction) {
      var motionFrom = direction === "forward" ? "right" : "left";

      $(newColumn).show("slide", { direction: motionFrom }, 120);
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
      if (cycle_options.fab_period != undefined)
        query_list.push("fab_period=" + encodeURI(cycle_options.fab_period));

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
    function populateFabInDisplay(markup, fab_encapsulator, cb) {
      var ulElements = parseTheUlElementsFromServerResponse(markup);

      // Apply the new elements to the DOM
      fab_encapsulator.append(ulElements[0]);
      fab_encapsulator.append(ulElements[1]);

      // Get references to them as objects
      var backward_notes = fab_encapsulator.children('.back').last();
      var forward_notes = fab_encapsulator.children('.forward').last();

      // Hide them before the user notices what we're doing

      backward_notes.hide();
      forward_notes.hide();

      cb([backward_notes, forward_notes]);
    }


    // Parse the two <ul> sections out of the html response from the server
    // Those represent the FAB notes of both back and forward
    function parseTheUlElementsFromServerResponse(markup) {
      // Make an element to facilitate DOM manipulation
      var parsingDiv = document.createElement('div');

      parsingDiv.innerHTML = markup;

      var back_markup = parsingDiv.children[0].outerHTML;
      var forward_markup = parsingDiv.children[1].outerHTML;
      return [back_markup, forward_markup];
    }

  };
  window.basicCarousel = new BasicCarousel();

})();
