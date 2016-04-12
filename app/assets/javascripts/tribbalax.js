// Tribbalax is Jeremy Tribby's amazing paralax code for making that designy
// paralax effect take place in the top banner as you scroll down
// It also sets up the 'hamburger' thing when the menu is small, whouch should
// be refactored into Tribburber.js or something (such a sweet name
// for having libraries named after you, Tribby!)
var Tribbalax = function() {

  var setTribbysGlobals = function() {
    window.ticking = false;

    window.speedDivider = 2;
    window.bgElm = document.getElementById('hero-bg');
    window.frontElm = document.getElementById('front');
    window.scrollTop = window.pageYOffset;
    window.translateValue = 0;

    window.nav = document.getElementsByTagName('nav')[0];

    window.navStyle = window.getComputedStyle(nav);
    window.navPosition = navStyle.getPropertyValue('position');
    window.navOffset = nav.getBoundingClientRect().top + scrollTop;
    window.navDistance = navOffset - scrollTop;
    window.navHeight = nav.offsetHeight;
    window.afterNav = document.getElementById("container");
    window.navMargin = parseInt(window.getComputedStyle(afterNav,null).getPropertyValue('margin-top'));
    window.screenWidth = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);

    window.hamburger = document.getElementById('hamburger');
  };

  setTribbysGlobals();

  if (typeof hamberger !== "undefined")
    hamburger.addEventListener('click',openMenu,false);


  function openMenu() {
    document.body.classList.toggle('active');
  }


  document.addEventListener("DOMContentLoaded", function(event) {
    window.onscroll = doScroll;
  });


  window.addEventListener("resize", function(event) {
    window.onresize = doResize;
  });


  var translateY = function(elm, value) {
    elm.style.transform = 'translate3d(0px,' + value + 'px, 0px)';
  };

  var dim = function(elm, value) {
    elm.style.opacity = 1 - (value / 210);
  }

  var doScroll = function() {

    lastScrollY = window.pageYOffset;
    currentPosition = navStyle.getPropertyValue('position');
    requestTick();
  };

  var doResize = function() {
    screenWidth = Math.max(document.documentElement.clientWidth, window.innerWidth || 0),
    scrollTop = window.pageYOffset,
    navStyle = window.getComputedStyle(nav),
    navPosition = navStyle.getPropertyValue('position'),
    navDistance = navOffset - scrollTop,
    currentPosition = navStyle.getPropertyValue('position');


    // console.log('resize');
    // console.log('currentPosition, navOffset, navDistance, scrollTop' + currentPosition + ' ' + navOffset
    // + ' ' + navDistance + ' ' + scrollTop);

    // if(screenWidth < 768) {
    //   nav.style.position = 'fixed';
    //   afterNav.style.marginTop = navMargin + 'px';
    // } else {
    //   if(navDistance <= 0) {
    //     console.log(navDistance);
    //     if(navPosition != 'fixed' && navDistance <= 0) {
    //       nav.style.position = 'fixed';
    //       afterNav.style.marginTop = navMargin + navHeight + 'px';
    //     } else if (navPosition == 'fixed' && navDistance <= 0) {
    //       nav.style.position = 'relative';
    //       afterNav.style.marginTop = navMargin + 'px';
    //     }
    //   } else if (navDistance < 0 && navPosition == 'fixed') {
    //     nav.style.position = 'relative';
    //     afterNav.style.marginTop = navMargin + 'px';
    //   }
    // }

    if(screenWidth >= 768) {
      if(navDistance <= 0) {
        if(navPosition != 'fixed' && navDistance <= 0) {
          nav.style.position = 'fixed';
          afterNav.style.marginTop = navHeight + navMargin + 'px';
        }
      } else if (navDistance > 0 && navPosition == 'fixed') {
        nav.style.position = 'relative';
        afterNav.style.marginTop = navMargin + 'px';
      }
    } else {
      nav.style.position = 'fixed';
    }

    requestTick();
  };


  var requestTick = function() {
    if (!ticking) {
      window.requestAnimationFrame(updatePosition);
      window.requestAnimationFrame(menuCheck);
      ticking = true;
    }
  };

  var menuCheck = function() {
    screenWidth = Math.max(document.documentElement.clientWidth, window.innerWidth || 0),
    scrollTop = window.pageYOffset,
    navStyle = window.getComputedStyle(nav),
    navPosition = navStyle.getPropertyValue('position'),
    navDistance = navOffset - scrollTop;



      // console.log('currentPosition, navOffset, navDistance, scrollTop' + currentPosition + ' ' + navOffset
      // + ' ' + navDistance + ' ' + scrollTop);

    if(screenWidth >= 768) {
      if(navDistance <= 0) {
        if(navPosition != 'fixed' && navDistance <= 0) {
          nav.style.position = 'fixed';
          afterNav.style.marginTop = navHeight + navMargin + 'px';
        }
      } else if (navDistance > 0 && navPosition == 'fixed') {
        nav.style.position = 'relative';
        afterNav.style.marginTop = navMargin + 'px';
      }
    } else {
      nav.style.position = 'fixed';
    }
    // } else {
    //   console.log("fixed x");
    //   nav.style.position = 'fixed';
    // }


    // } else {
    //   nav.style.position = 'fixed';
    // }

    ticking = false;
  };

  var updatePosition = function() {
    translateValue = lastScrollY / speedDivider;
    translateY(frontElm, (translateValue * 0.8));
    translateY(bgElm, translateValue);
    dim(frontElm, translateValue);
    ticking = false;
  };

  this.reInitializeParalax = function() {
    setTribbysGlobals();
    doScroll(); // fixes paralax
    // doResize(); // fixes hamburger
  };

};
