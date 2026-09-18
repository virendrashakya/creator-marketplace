module ApplicationHelper
  # Every amount in the database is an integer of the currency's minor unit
  # (paise, cents). Views must never do this arithmetic themselves. They did,
  # five different ways, and all of them hardcoded the rupee sign.
  # Delegates to MoneyFormatting so views, models and mailers all group rupees
  # the same way (lakh and crore, not thousands).
  def money(minor_units, currency = "INR")
    MoneyFormatting.format_money(minor_units, currency)
  end

  # Social handles are creator-supplied and were being interpolated straight
  # into an href. Strip the platform's own prefixes, then escape what is left
  # so a handle cannot smuggle a path or query into the destination.
  def social_url(base_url, handle)
    cleaned = handle.to_s.strip.delete_prefix("@").delete_prefix("u/")
    "#{base_url}#{ERB::Util.url_encode(cleaned)}"
  end

  # The label shown next to any bookable time, so a creator in Mumbai and a
  # follower elsewhere read the same slot the same way.
  def slot_timezone_label
    Time.zone.now.strftime("%Z")
  end

  # Minor-unit fields are a trap: a creator typing "499" means ₹499, not ₹4.99.
  # Forms pair this hint with a ₹ prefix on the input itself.
  def minor_unit_hint(currency = "INR")
    currency == "USD" ? "cents" : "paise"
  end
end
