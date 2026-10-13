// Share Teaser and Controlled Referral Tracking
window.handleShareTeaser = function(btn) {
  const url = btn.dataset.shareUrl;
  const title = btn.dataset.shareTitle;
  const text = btn.dataset.shareText;

  if (navigator.share && /mobile|android|iphone|ipad/i.test(navigator.userAgent)) {
    navigator.share({
      title: title,
      text: text,
      url: url
    }).catch(() => {});
    return;
  }

  const wrap = btn.closest(".media-share-dropdown-wrap");
  if (!wrap) return;
  const popover = wrap.querySelector(".share-popover");
  if (!popover) return;

  const isOpen = popover.style.display === "block";
  document.querySelectorAll(".share-popover").forEach(p => p.style.display = "none");
  popover.style.display = isOpen ? "none" : "block";
};

window.copyShareUrl = function(btn) {
  const url = btn.dataset.url;
  if (!url) return;
  navigator.clipboard.writeText(url).then(() => {
    const originalText = btn.innerHTML;
    btn.innerHTML = '<span>✅</span> Copied to Clipboard!';
    setTimeout(() => {
      btn.innerHTML = originalText;
      const popover = btn.closest(".share-popover");
      if (popover) popover.style.display = "none";
    }, 1500);
  });
};

document.addEventListener("click", function(e) {
  if (!e.target.closest(".media-share-dropdown-wrap")) {
    document.querySelectorAll(".share-popover").forEach(p => p.style.display = "none");
  }

  const shareBtn = e.target.closest("[data-share-url]");
  if (!shareBtn || shareBtn.onclick || shareBtn.hasAttribute("onclick")) return;
  const url = shareBtn.dataset.shareUrl;
  const title = shareBtn.dataset.shareTitle || document.title;

  if (navigator.share && /mobile|android|iphone|ipad/i.test(navigator.userAgent)) {
    navigator.share({ title: title, url: url }).catch(() => {});
  } else if (navigator.clipboard) {
    navigator.clipboard.writeText(url).then(() => {
      const orig = shareBtn.innerHTML;
      shareBtn.innerHTML = 'Copied! ✓';
      setTimeout(() => { shareBtn.innerHTML = orig; }, 1800);
    }).catch(() => {});
  }
});
