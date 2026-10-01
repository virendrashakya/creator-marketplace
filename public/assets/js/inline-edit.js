/* Owner-only editing affordances on a creator's own public page.

   Shipped only to the signed-in owner (the view guards the script tag) and
   written as pure enhancement. With this file absent:
     - each photo zone is still a file input plus an Upload button
     - every Manage control is still a plain link
   Nothing here is required to edit the page. What it adds is drag-and-drop,
   submit-on-choose, and the "uploading" state.

   No framework, matching home.js. */
(function () {
  "use strict";

  /* Turbo Drive swaps the body without a fresh document, so DOMContentLoaded
     fires only on the first full load. turbo:load fires on every visit,
     including that first one, so setup must be safe to run more than once:
     every binding below is guarded against a second pass. */
  function onReady(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
    document.addEventListener("turbo:load", fn);
  }

  /* Only the first file matters: banner and profile_picture are both
     has_one_attached, so a multi-file drop would silently discard the rest.
     Taking [0] and saying so is better than pretending to accept ten. */
  function firstImage(list) {
    for (var i = 0; i < list.length; i++) {
      if (list[i].type && list[i].type.indexOf("image/") === 0) return list[i];
    }
    return null;
  }

  onReady(function () {
    var root = document.querySelector("[data-ie-root]");
    if (!root) return;

    /* Marking the root is what hides the no-JS Upload buttons. They stay in
       the markup so a failed script load leaves a working page. */
    root.classList.add("ie-js");

    var forms = document.querySelectorAll("[data-ie-drop]");

    for (var i = 0; i < forms.length; i++) {
      wire(forms[i]);
    }

    function wire(form) {
      var input = form.querySelector("[data-ie-drop-input]");
      if (!input) return;

      /* A Turbo visit back to this page re-runs setup over nodes that may be
         the very same elements, so binding twice would upload twice. */
      if (form.dataset.ieBound) return;
      form.dataset.ieBound = "1";

      /* The zone that lights up is the photo itself, not just the overlay,
         so dragging anywhere over the cover reads as a target. */
      var zone = form.closest("[data-ie-zone]") || form;

      function send() {
        form.classList.add("is-busy");
        var title = form.querySelector(".ie-drop-title");
        if (title) title.textContent = "Uploading…";
        form.submit();
      }

      /* Choosing a file through the picker uploads straight away rather than
         leaving a second button to find. */
      input.addEventListener("change", function () {
        if (input.files && input.files.length) send();
      });

      /* Drag and drop. dragover must be cancelled or the browser navigates
         to the dropped file instead of giving it to us. A counter rather
         than a boolean, because dragleave fires when crossing between the
         zone's own children. */
      var depth = 0;

      zone.addEventListener("dragenter", function (e) {
        e.preventDefault();
        depth++;
        zone.classList.add("is-dragging");
      });

      zone.addEventListener("dragover", function (e) {
        e.preventDefault();
        if (e.dataTransfer) e.dataTransfer.dropEffect = "copy";
      });

      zone.addEventListener("dragleave", function () {
        depth = Math.max(0, depth - 1);
        if (depth === 0) zone.classList.remove("is-dragging");
      });

      zone.addEventListener("drop", function (e) {
        e.preventDefault();
        depth = 0;
        zone.classList.remove("is-dragging");

        if (!e.dataTransfer || !e.dataTransfer.files) return;
        var file = firstImage(e.dataTransfer.files);
        if (!file) {
          /* Dropping a PDF on a cover photo is a mistake worth naming,
             quietly and in place. */
          var hint = form.querySelector(".ie-drop-hint");
          if (hint) hint.textContent = "That is not an image file";
          return;
        }

        /* DataTransfer is assignable to a file input in every browser that
           supports the drop event, which is how the dropped file reaches the
           form without a fetch and without reimplementing the upload. */
        try {
          var dt = new DataTransfer();
          dt.items.add(file);
          input.files = dt.files;
        } catch (err) {
          /* Very old browser: fall back to opening the picker so the drop
             is not a dead end. */
          input.click();
          return;
        }
        send();
      });
    }

    /* A page-wide guard: a file dropped just outside a zone would otherwise
       navigate away from the page and lose whatever the creator was doing.

       window outlives a Turbo body swap, so these two bind once for the life
       of the tab rather than once per visit. */
    if (!window.__ieDragGuard) {
      window.__ieDragGuard = true;
      window.addEventListener("dragover", function (e) { e.preventDefault(); });
      window.addEventListener("drop", function (e) {
        if (!e.target.closest || !e.target.closest("[data-ie-zone]")) e.preventDefault();
      });
    }
  });
})();
