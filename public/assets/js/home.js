/* Marketing home: scroll reveals and the phone demo loop.
   No framework. Everything here degrades to "content is simply visible" if
   JS never runs, because the CSS only hides things once this file has marked
   the document as ready. */
(function () {
  "use strict";

  var reduced = window.matchMedia("(prefers-reduced-motion: reduce)");

  /* The phone timer is the one piece of state that has to outlive a single
     setup pass: Turbo keeps the tab alive across visits, so a timer left
     running would drive a node that is no longer in the document. */
  var timer = null;
  function stop() { clearTimeout(timer); timer = null; }

  /* Turbo Drive swaps the body without a fresh document, so DOMContentLoaded
     fires only on the first full load. turbo:load fires on every visit,
     and setup below is written to be safe on each one. */
  function onReady(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
    document.addEventListener("turbo:load", fn);
  }

  /* Before Turbo caches this page it will be detached; drop the timer so a
     return visit starts one loop rather than two. */
  document.addEventListener("turbo:before-cache", stop);

  onReady(function () {
    /* Re-checked per visit rather than once per tab: the preference can
       change mid-session, and this is the cheapest place to honour it.
       Leave the document unmarked so the CSS never hides anything, and
       never start the phone loop. Reduced motion is not "the same
       animation, faster". */
    if (reduced.matches) { stop(); return; }

    /* Marking the root is what lets the CSS hide reveal targets. Without JS
       the class is absent, the hiding rules never match, and the page reads
       fine. */
    document.documentElement.classList.add("js-reveal");

    /* ---- scroll reveals ---- */
    var targets = document.querySelectorAll("[data-reveal]");

    if (!("IntersectionObserver" in window)) {
      /* Old browser: show everything rather than leave it hidden forever. */
      for (var i = 0; i < targets.length; i++) targets[i].classList.add("is-in");
      return;
    }

    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var el = entry.target;
        /* Stagger children of a revealed group by their index, so a grid
           cascades instead of snapping in as one block. */
        var delay = parseInt(el.getAttribute("data-reveal-delay") || "0", 10);
        if (delay) el.style.transitionDelay = delay + "ms";
        el.classList.add("is-in");
        /* Once shown, stop watching. A reveal that replays on scroll-up is
           motion the reader did not ask for twice. */
        io.unobserve(el);
      });
    }, {
      /* Fire slightly before the element reaches the fold, so the motion has
         finished by the time it is properly in view. */
      rootMargin: "0px 0px -12% 0px",
      threshold: 0.01
    });

    for (var j = 0; j < targets.length; j++) io.observe(targets[j]);

    /* ---- the phone demo ---- */
    /* Three states: browsing, a locked item, the same item unlocked. It is
       the product's core loop, so the hero shows it happening rather than
       describing it. */
    var phone = document.querySelector("[data-phone]");
    if (!phone) return;

    var states = ["browse", "locked", "unlocked"];
    var at = 0;

    function paint() {
      phone.setAttribute("data-phone-state", states[at]);
    }

    function advance() {
      at = (at + 1) % states.length;
      paint();
      /* Hold the unlocked state longest: it is the payoff, and the reason a
         creator would sign up. */
      schedule(states[at] === "unlocked" ? 3200 : 2300);
    }

    function schedule(ms) {
      clearTimeout(timer);
      timer = setTimeout(advance, ms);
    }

    function start() { paint(); schedule(2300); }

    /* Do not animate a phone nobody is looking at: it burns battery on the
       device this product is designed for. */
    if (phone.dataset.phoneBound) { start(); return; }
    phone.dataset.phoneBound = "1";

    if ("IntersectionObserver" in window) {
      new IntersectionObserver(function (entries) {
        entries.forEach(function (e) {
          if (e.isIntersecting) { if (!timer) start(); }
          else stop();
        });
      }, { threshold: 0.25 }).observe(phone);
    } else {
      start();
    }

    /* Same reason, for a backgrounded tab. document and the media query both
       outlive a body swap, so these bind once for the life of the tab. */
    if (!window.__homeTabHooks) {
      window.__homeTabHooks = true;

      document.addEventListener("visibilitychange", function () {
        /* Only drive a phone that is actually on the current page. */
        if (!document.querySelector("[data-phone]")) return;
        if (document.hidden) stop();
        else if (!timer) start();
      });

      /* If the person turns on reduced motion mid-visit, stop immediately. */
      var onPrefChange = function (e) {
        if (!e.matches) return;
        stop();
        var p = document.querySelector("[data-phone]");
        if (p) p.setAttribute("data-phone-state", "unlocked");
      };
      if (reduced.addEventListener) reduced.addEventListener("change", onPrefChange);
      else if (reduced.addListener) reduced.addListener(onPrefChange);
    }
  });
})();
