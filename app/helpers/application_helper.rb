module ApplicationHelper
  # Every amount in the database is an integer of the currency's minor unit
  # (paise, cents). Views must never do this arithmetic themselves — they did,
  # five different ways, and all of them hardcoded the rupee sign.
  def money(minor_units, currency = "INR")
    major = minor_units.to_i / 100.0
    return number_to_currency(major, unit: "$", precision: 2, format: "%u%n") if currency == "USD"

    "₹#{indian_grouping(format('%.2f', major))}"
  end

  # Rupees group by lakh and crore: 1,50,000 rather than 150,000. Rails'
  # delimiter cannot express this, so the integer part is grouped by hand —
  # last three digits, then pairs.
  def indian_grouping(formatted)
    whole, decimals = formatted.split(".")
    sign = whole.start_with?("-") ? "-" : ""
    digits = whole.delete("-")

    grouped =
      if digits.length > 3
        head, tail = digits[0..-4], digits[-3..]
        "#{head.reverse.scan(/\d{1,2}/).join(",").reverse},#{tail}"
      else
        digits
      end

    [ "#{sign}#{grouped}", decimals ].compact.join(".")
  end

  # The label shown next to any bookable time, so a creator in Mumbai and a
  # follower elsewhere read the same slot the same way.
  def slot_timezone_label
    Time.zone.now.strftime("%Z")
  end

  # Social handles are creator-supplied and were being interpolated straight
  # into an href. Strip the platform's own prefixes, then escape what is left
  # so a handle cannot smuggle a path or query into the destination.
  def social_url(base_url, handle)
    cleaned = handle.to_s.strip.delete_prefix("@").delete_prefix("u/")
    "#{base_url}#{ERB::Util.url_encode(cleaned)}"
  end

  # Minor-unit fields are a trap: a creator typing "499" means ₹499, not ₹4.99.
  # Forms pair this hint with a ₹ prefix on the input itself.
  def minor_unit_hint(currency = "INR")
    currency == "USD" ? "cents" : "paise"
  end
end
