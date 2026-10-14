/* Small behaviours for the dark redesign. Everything here is enhancement:
   each control is a real link or form first, so a page still works if this
   file never loads.

   Delegated listeners are bound once on document; per-page setup runs on
   turbo:load as well as the first DOMContentLoaded, because Turbo Drive
   fires the latter only once per full load. No framework. */
(function () {
  "use strict";

  function onReady(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
    document.addEventListener("turbo:load", fn);
  }

  function csrf() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.content : "";
  }

  /* ---- copy to clipboard: data-copy="text" ---- */
  document.addEventListener("click", function (e) {
    var btn = e.target.closest("[data-copy]");
    if (!btn) return;
    e.preventDefault();
    var text = btn.getAttribute("data-copy");
    var done = function () {
      var label = btn.getAttribute("data-copied") || "Copied";
      if (btn.dataset.wfOrig == null) btn.dataset.wfOrig = btn.textContent;
      btn.textContent = label;
      setTimeout(function () { btn.textContent = btn.dataset.wfOrig; delete btn.dataset.wfOrig; }, 1600);
    };
    if (navigator.clipboard) navigator.clipboard.writeText(text).then(done).catch(function () {});
  });

  /* ---- show/hide: data-toggle="#id" ---- */
  document.addEventListener("click", function (e) {
    var btn = e.target.closest("[data-toggle]");
    if (!btn) return;
    var target = document.querySelector(btn.getAttribute("data-toggle"));
    if (!target) return;
    e.preventDefault();
    target.hidden = !target.hidden;
    btn.setAttribute("aria-expanded", String(!target.hidden));
  });

  /* ---- booking slots: pick one, the button follows ---- */
  document.addEventListener("click", function (e) {
    var slot = e.target.closest("[data-slot]");
    if (!slot) return;
    e.preventDefault();
    var group = slot.closest("[data-slots]");
    group.querySelectorAll("[data-slot]").forEach(function (s) { s.classList.remove("is-on"); });
    slot.classList.add("is-on");
    var cta = group.parentElement.querySelector("[data-slot-cta]");
    if (cta) {
      cta.href = slot.getAttribute("data-href");
      cta.textContent = "Book " + slot.getAttribute("data-label");
      cta.removeAttribute("aria-disabled");
    }
  });

  /* ---- theme: dark / light / system ----
     Turbo swaps <body> but never <html>, so the attribute the stylesheet
     keys off has to be set here; the cookie is saved in the background and
     the page re-rendered so every switch shows the new state. */
  function applyTheme(pref) {
    var html = document.documentElement;
    var resolved = pref === "system"
      ? (window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark")
      : pref;
    html.setAttribute("data-theme-pref", pref);
    html.setAttribute("data-theme", resolved);
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta && document.body.classList.contains("wf")) meta.content = resolved === "light" ? "#F6F5F2" : "#0E0E10";
  }

  document.addEventListener("submit", function (e) {
    var form = e.target.closest("[data-theme-form]");
    if (!form || !e.submitter) return;
    e.preventDefault();
    var pref = e.submitter.value;
    applyTheme(pref);
    var body = new FormData(form);
    body.set("theme", pref);
    fetch(form.action, {
      method: "POST", credentials: "same-origin", body: body,
      headers: { Accept: "application/json", "X-CSRF-Token": csrf() }
    }).then(function () {
      if (window.Turbo) window.Turbo.visit(window.location.href, { action: "replace" });
    });
  });

  try {
    window.matchMedia("(prefers-color-scheme: light)").addEventListener("change", function () {
      if (document.documentElement.getAttribute("data-theme-pref") === "system") applyTheme("system");
    });
  } catch (err) {}

  /* ---- auto-submit: data-autosubmit on a form control ---- */
  document.addEventListener("change", function (e) {
    var el = e.target.closest("[data-autosubmit]");
    if (el && el.form) el.form.requestSubmit ? el.form.requestSubmit() : el.form.submit();
  });

  onReady(function () {
    setupOtp();
    setupUtr();
    setupPoll();
    setupSortable();
    setupAmounts();
    setupFileLabels();
    setupInstall();
    setupPush();
    setupViewer();
    setupOffline();
  });

  /* ---- OTP: six boxes, one hidden field ---- */
  function setupOtp() {
    document.querySelectorAll("[data-otp]").forEach(function (wrap) {
      if (wrap.dataset.bound) return;
      wrap.dataset.bound = "1";
      var boxes = Array.prototype.slice.call(wrap.querySelectorAll("input[data-otp-box]"));
      var hidden = wrap.querySelector("input[data-otp-value]");
      var form = wrap.closest("form");
      function sync() {
        hidden.value = boxes.map(function (b) { return b.value; }).join("");
        if (hidden.value.length === boxes.length && form) form.requestSubmit ? form.requestSubmit() : form.submit();
      }
      boxes.forEach(function (box, i) {
        box.addEventListener("input", function () {
          var digits = box.value.replace(/\D/g, "");
          if (digits.length > 1) {
            /* A pasted or autofilled code lands in one box: spread it. */
            digits.split("").slice(0, boxes.length - i).forEach(function (d, j) { boxes[i + j].value = d; });
            boxes[Math.min(i + digits.length, boxes.length - 1)].focus();
          } else {
            box.value = digits;
            if (digits && boxes[i + 1]) boxes[i + 1].focus();
          }
          sync();
        });
        box.addEventListener("keydown", function (e) {
          if (e.key === "Backspace" && !box.value && boxes[i - 1]) boxes[i - 1].focus();
        });
      });
      if (boxes[0]) boxes[0].focus();
    });
  }

  /* ---- UTR: shown in groups of four, sent as digits ---- */
  function setupUtr() {
    document.querySelectorAll("[data-utr]").forEach(function (input) {
      if (input.dataset.bound) return;
      input.dataset.bound = "1";
      input.addEventListener("input", function () {
        var raw = input.value.replace(/[^0-9A-Za-z]/g, "").toUpperCase().slice(0, 24);
        input.value = raw.replace(/(.{4})(?=.)/g, "$1 ");
      });
    });
  }

  /* ---- a pending claim checks itself every 15s ---- */
  var pollTimer = null;
  function setupPoll() {
    clearTimeout(pollTimer);
    var el = document.querySelector("[data-poll]");
    if (!el) return;
    var every = parseInt(el.getAttribute("data-poll"), 10) || 15000;
    pollTimer = setTimeout(function () {
      if (window.Turbo) window.Turbo.visit(window.location.href, { action: "replace" });
      else window.location.reload();
    }, every);
  }
  document.addEventListener("turbo:before-cache", function () { clearTimeout(pollTimer); });

  /* ---- drag to reorder: data-sortable="/url" on the list, data-id on rows ---- */
  function setupSortable() {
    document.querySelectorAll("[data-sortable]").forEach(function (list) {
      if (list.dataset.bound) return;
      list.dataset.bound = "1";
      var dragging = null;
      list.querySelectorAll("[data-id]").forEach(function (row) { row.setAttribute("draggable", "true"); });
      list.addEventListener("dragstart", function (e) {
        dragging = e.target.closest("[data-id]");
        if (!dragging) return;
        dragging.classList.add("is-dragging");
        e.dataTransfer.effectAllowed = "move";
      });
      list.addEventListener("dragover", function (e) {
        var over = e.target.closest("[data-id]");
        if (!dragging || !over || over === dragging) return;
        e.preventDefault();
        var rect = over.getBoundingClientRect();
        var horizontal = getComputedStyle(list).display === "grid";
        var after = horizontal ? (e.clientX - rect.left) > rect.width / 2 : (e.clientY - rect.top) > rect.height / 2;
        over.parentNode.insertBefore(dragging, after ? over.nextSibling : over);
      });
      list.addEventListener("dragend", function () {
        if (!dragging) return;
        dragging.classList.remove("is-dragging");
        dragging = null;
        var ids = Array.prototype.map.call(list.querySelectorAll("[data-id]"), function (r) { return r.getAttribute("data-id"); });
        fetch(list.getAttribute("data-sortable"), {
          method: "PATCH",
          credentials: "same-origin",
          headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf(), Accept: "application/json" },
          body: JSON.stringify({ ids: ids })
        }).then(function (r) {
          if (r.ok && list.hasAttribute("data-sortable-reload") && window.Turbo) window.Turbo.visit(window.location.href, { action: "replace" });
        });
      });
    });
  }

  /* ---- Spoil me: a preset amount fills the rupee field ---- */
  function setupAmounts() {
    document.querySelectorAll("[data-amounts]").forEach(function (wrap) {
      if (wrap.dataset.bound) return;
      wrap.dataset.bound = "1";
      var out = document.querySelector(wrap.getAttribute("data-amounts"));
      var cta = document.querySelector("[data-amount-cta]");
      wrap.addEventListener("change", function (e) {
        if (!e.target.matches("input[type=radio]")) return;
        if (out) out.value = e.target.value;
        if (cta) cta.textContent = cta.getAttribute("data-template").replace("%s", "₹" + Number(e.target.value).toLocaleString("en-IN"));
      });
    });
  }

  /* ---- file inputs say what was picked ---- */
  function setupFileLabels() {
    document.querySelectorAll("[data-file-label]").forEach(function (input) {
      if (input.dataset.bound) return;
      input.dataset.bound = "1";
      input.addEventListener("change", function () {
        var label = document.querySelector(input.getAttribute("data-file-label"));
        if (!label) return;
        var n = input.files.length;
        label.textContent = n === 0 ? label.getAttribute("data-empty") : (n === 1 ? input.files[0].name : n + " files selected");
        var form = input.form;
        if (form && input.hasAttribute("data-autosubmit-files") && n > 0) form.requestSubmit ? form.requestSubmit() : form.submit();
      });
    });
  }

  /* ---- PWA: service worker and the install prompt ---- */
  if ("serviceWorker" in navigator && window.isSecureContext) {
    window.addEventListener("load", function () {
      navigator.serviceWorker.register("/service-worker.js").catch(function () {});
    });
  }

  var deferredInstall = null;
  window.addEventListener("beforeinstallprompt", function (e) {
    e.preventDefault();
    deferredInstall = e;
    showInstall();
  });

  function standalone() {
    return window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true;
  }

  function dismissed() {
    try { return localStorage.getItem("wf-install-dismissed") === "1"; } catch (e) { return false; }
  }

  function showInstall() {
    var banner = document.querySelector("[data-install-banner]");
    if (!banner || standalone() || dismissed()) return;
    var ios = /iphone|ipad|ipod/i.test(navigator.userAgent) && !window.MSStream;
    if (!deferredInstall && !ios) return;
    var hint = banner.querySelector("[data-install-ios]");
    if (ios && hint) hint.hidden = false;
    var go = banner.querySelector("[data-install-go]");
    if (ios && go) go.hidden = true;
    banner.hidden = false;
  }

  function setupInstall() {
    var banner = document.querySelector("[data-install-banner]");
    if (!banner || banner.dataset.bound) return;
    banner.dataset.bound = "1";
    banner.addEventListener("click", function (e) {
      if (e.target.closest("[data-install-dismiss]")) {
        try { localStorage.setItem("wf-install-dismissed", "1"); } catch (err) {}
        banner.hidden = true;
      }
      if (e.target.closest("[data-install-go]") && deferredInstall) {
        deferredInstall.prompt();
        deferredInstall.userChoice.finally(function () { deferredInstall = null; banner.hidden = true; });
      }
    });
    /* iOS has no install event; offer the Share-sheet hint after a moment. */
    setTimeout(showInstall, 1500);
  }

  /* ---- Web Push: data-push-enable button ---- */
  function urlBase64ToUint8Array(base64String) {
    var padding = "=".repeat((4 - base64String.length % 4) % 4);
    var base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");
    var raw = atob(base64);
    var out = new Uint8Array(raw.length);
    for (var i = 0; i < raw.length; ++i) out[i] = raw.charCodeAt(i);
    return out;
  }

  function setupPush() {
    document.querySelectorAll("[data-push-enable]").forEach(function (btn) {
      if (btn.dataset.bound) return;
      btn.dataset.bound = "1";
      var key = document.querySelector('meta[name="vapid-public-key"]');
      if (!key || !("serviceWorker" in navigator) || !("PushManager" in window)) {
        btn.setAttribute("aria-disabled", "true");
        btn.textContent = "Notifications aren't supported here";
        return;
      }
      btn.addEventListener("click", function (e) {
        e.preventDefault();
        Notification.requestPermission().then(function (perm) {
          if (perm !== "granted") { btn.textContent = "Notifications are blocked"; return; }
          return navigator.serviceWorker.ready.then(function (reg) {
            return reg.pushManager.subscribe({ userVisibleOnly: true, applicationServerKey: urlBase64ToUint8Array(key.content) });
          }).then(function (sub) {
            var json = sub.toJSON();
            return fetch("/push_subscriptions", {
              method: "POST",
              credentials: "same-origin",
              headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf() },
              body: JSON.stringify({ endpoint: json.endpoint, p256dh: json.keys.p256dh, auth: json.keys.auth })
            });
          }).then(function () {
            btn.textContent = "Notifications on";
            btn.setAttribute("aria-disabled", "true");
            var next = btn.getAttribute("data-push-next");
            if (next && window.Turbo) setTimeout(function () { window.Turbo.visit(next); }, 600);
          });
        }).catch(function () { btn.textContent = "Couldn't turn on notifications"; });
      });
    });
  }

  /* ---- viewer: arrow keys page through a collection ---- */
  function setupViewer() {
    var viewer = document.querySelector("[data-viewer]");
    if (!viewer || viewer.dataset.bound) return;
    viewer.dataset.bound = "1";
    document.addEventListener("keydown", function onKey(e) {
      if (!document.body.contains(viewer)) { document.removeEventListener("keydown", onKey); return; }
      var link = e.key === "ArrowRight" ? viewer.querySelector("[data-next]") : e.key === "ArrowLeft" ? viewer.querySelector("[data-prev]") : null;
      if (link && window.Turbo) window.Turbo.visit(link.href, { action: "replace" });
    });
    viewer.addEventListener("contextmenu", function (e) { e.preventDefault(); });
  }

  /* ---- offline banner and "Saved" badges on the unlocks page ---- */
  function setupOffline() {
    var banner = document.querySelector("[data-offline-banner]");
    if (banner) {
      var sync = function () { banner.hidden = navigator.onLine; };
      sync();
      window.addEventListener("online", sync);
      window.addEventListener("offline", sync);
    }
    if (!("caches" in window)) return;
    document.querySelectorAll("[data-saved-check]").forEach(function (row) {
      var path = row.getAttribute("data-saved-check");
      if (!path) return;
      caches.open("wf-unlocks").then(function (c) { return c.match(path); }).then(function (hit) {
        var badge = row.querySelector("[data-saved-badge]");
        if (hit && badge) badge.hidden = false;
      }).catch(function () {});
    });
  }

  /* Signing out of a shared phone must not leave someone's watermarked
     unlocks sitting in the browser cache. */
  document.addEventListener("submit", function (e) {
    var form = e.target;
    if (!form || !/\/sign_out(\?|$)/.test(form.getAttribute("action") || "")) return;
    if ("caches" in window) {
      caches.keys().then(function (keys) {
        keys.forEach(function (k) { if (k === "wf-unlocks" || /-pages$/.test(k)) caches.delete(k); });
      });
    }
  }, true);
})();
