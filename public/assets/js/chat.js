/* Chat over ActionCable, for the two different chats in this app:

     data-chat="live"  public chat inside a live room, gated on subscription
     data-chat="dm"    a private thread between two people

   They share a transport and nothing else, so the differences are confined
   to one subscription descriptor and one row renderer.

   Written as enhancement, like home.js. Both chats are real forms that POST
   and redirect; if the socket never connects, or this file never loads, the
   page still sends and receives messages on a reload. What the socket adds
   is messages arriving without one.

   No framework. */
(function () {
  "use strict";

  /* Turbo Drive swaps the body without a fresh document, so DOMContentLoaded
     fires only on the first full load; turbo:load fires on every visit. */
  function onReady(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
    document.addEventListener("turbo:load", fn);
  }

  /* The live subscription is the one thing here that must not survive a
     navigation. Turbo keeps the tab (and so the ActionCable consumer) alive
     across visits, and a subscription left open would keep appending rows to
     a log that is no longer on screen, then double up when the page is
     visited again. Torn down before Turbo caches the page. */
  var active = null;

  function teardown() {
    if (!active) return;
    try { active.consumer.subscriptions.remove(active.sub); } catch (e) {}
    active = null;
  }

  document.addEventListener("turbo:before-cache", teardown);

  /* Text from other people goes in with textContent, never innerHTML. The
     server escapes on render, but a message arriving over the socket is
     JSON, and building a row with innerHTML here would be an XSS hole that
     the server-rendered path does not have. */
  function el(tag, className, text) {
    var node = document.createElement(tag);
    if (className) node.className = className;
    if (text != null) node.textContent = text;
    return node;
  }

  function atBottom(log) {
    return log.scrollHeight - log.scrollTop - log.clientHeight < 60;
  }

  function scrollToEnd(log) {
    log.scrollTop = log.scrollHeight;
  }

  onReady(function () {
    /* A visit that landed on a page without a chat still needs the previous
       page's socket closed. */
    teardown();

    var mount = document.querySelector("[data-chat]");
    if (!mount) return;

    var log = mount.querySelector("[data-chat-log]");
    var form = mount.querySelector("[data-chat-form]");
    var kind = mount.dataset.chat;
    var me = mount.dataset.me;

    if (log) scrollToEnd(log);

    /* Appending by id, and ignoring an id already present, is what makes
       the socket and the HTTP fallback safe together: a message can arrive
       twice (own echo plus broadcast, or a catch-up overlapping the live
       feed) and only render once. */
    function has(id) {
      return !!log.querySelector('[data-id="' + id + '"]');
    }

    function renderLive(m) {
      var li = el("li", "chat-line" + (m.creator ? " is-creator" : ""));
      li.dataset.id = m.id;
      li.appendChild(el("span", "chat-who mono", "@" + m.handle));
      li.appendChild(el("span", "chat-body", m.body));
      return li;
    }

    function renderDm(m) {
      var mine = String(m.sender_id) === String(me);
      var li = el("li", "dm-line" + (mine ? " is-mine" : ""));
      li.dataset.id = m.id;
      li.appendChild(el("span", "dm-bubble", m.body));
      return li;
    }

    var render = kind === "dm" ? renderDm : renderLive;

    function append(m) {
      if (!m || m.id == null || has(m.id)) return;
      var stick = atBottom(log);
      log.appendChild(render(m));
      /* Only follow the conversation if the reader was already at the
         bottom. Yanking someone back down while they scroll up through the
         history is the thing every chat gets wrong. */
      if (stick) scrollToEnd(log);
    }

    function lastId() {
      var rows = log.querySelectorAll("[data-id]");
      return rows.length ? rows[rows.length - 1].dataset.id : 0;
    }

    /* ---- the socket ---- */

    /* actioncable.js is a classic script and turbo.min.js is a module, so
       their execution order is not guaranteed. Missing ActionCable is not
       fatal: the form still POSTs, which is the documented fallback. */
    if (!window.ActionCable) return;

    /* One consumer per tab. createConsumer opens a socket, so calling it on
       every visit would leak one per navigation. */
    var consumer = window.__chatConsumer ||
      (window.__chatConsumer = window.ActionCable.createConsumer());

    var channel = kind === "dm"
      ? { channel: "ConversationChannel", conversation_id: mount.dataset.conversationId }
      : { channel: "LiveChatChannel", live_id: mount.dataset.liveId };

    var sub = consumer.subscriptions.create(channel, {
      received: append,

      /* A dropped socket loses every message sent while it was down, and
         reconnecting alone does not backfill them. Ask for everything newer
         than the last row we have. */
      connected: function () {
        mount.classList.add("is-connected");
        catchUp();
      },

      disconnected: function () {
        mount.classList.remove("is-connected");
      },

      rejected: function () {
        /* The server refused: not a member any more, or not in this thread.
           Reload so the page re-renders with whatever access is left rather
           than sitting here looking live. */
        window.location.reload();
      }
    });

    active = { consumer: consumer, sub: sub };

    function catchUp() {
      var base = kind === "dm"
        ? "/conversations/" + mount.dataset.conversationId + "/messages"
        : "/lives/" + mount.dataset.liveId + "/messages";

      fetch(base + "?after=" + encodeURIComponent(lastId()), {
        credentials: "same-origin",
        headers: { Accept: "application/json" }
      })
        .then(function (r) { return r.ok ? r.json() : []; })
        .then(function (rows) { rows.forEach(append); })
        .catch(function () { /* offline; the socket will try again */ });
    }

    /* ---- sending ---- */

    if (!form) return;
    var input = form.querySelector(".chat-input");

    if (form.dataset.chatBound) return;
    form.dataset.chatBound = "1";

    form.addEventListener("submit", function (e) {
      var body = input.value.trim();
      if (!body) {
        e.preventDefault();
        return;
      }

      /* Only take over the submit if the socket is actually up. With it
         down, letting the form POST normally is the whole fallback. */
      if (!mount.classList.contains("is-connected")) return;

      e.preventDefault();
      /* Read the live subscription rather than the one captured when this
         handler was bound: Turbo may have torn that one down and opened a
         fresh one on a return visit, while this node came back from cache
         with its original listener still attached. */
      if (!active) return;
      active.sub.perform("speak", { body: body });
      input.value = "";
      input.focus();
    });
  });
})();
