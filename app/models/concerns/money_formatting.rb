# One place that turns minor units (paise, cents) into a label.
#
# Rupees group by lakh and crore: 1,20,000 rather than 120,000. Five models
# were each formatting money themselves with Western grouping, so an Indian
# creator saw ₹120000 where they expect ₹1,20,000.
module MoneyFormatting
  extend ActiveSupport::Concern

  module_function

  # Trailing ".00" is dropped so prices read as ₹499 rather than ₹499.00, but
  # a real paise remainder is kept.
  def format_money(minor_units, currency = "INR")
    major = minor_units.to_i / 100.0
    whole, decimals = format("%.2f", major).split(".")
    grouped = currency == "USD" ? group_western(whole) : group_indian(whole)
    symbol = currency == "USD" ? "$" : "₹"

    decimals == "00" ? "#{symbol}#{grouped}" : "#{symbol}#{grouped}.#{decimals}"
  end

  def group_indian(digits)
    sign = digits.start_with?("-") ? "-" : ""
    body = digits.delete("-")
    return "#{sign}#{body}" if body.length <= 3

    head, tail = body[0..-4], body[-3..]
    "#{sign}#{head.reverse.scan(/\d{1,2}/).join(",").reverse},#{tail}"
  end

  def group_western(digits)
    sign = digits.start_with?("-") ? "-" : ""
    body = digits.delete("-")
    "#{sign}#{body.reverse.scan(/\d{1,3}/).join(",").reverse}"
  end

  # Instance helper for models that carry their own `currency` column.
  def money_label_for(minor_units, currency_value = nil)
    MoneyFormatting.format_money(minor_units, currency_value || try(:currency) || "INR")
  end
end
