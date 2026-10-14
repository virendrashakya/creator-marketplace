# The few moments worth interrupting someone for, in one place: a fan's
# unlock was approved or bounced, a creator has a payment to check. Each goes
# out as a Web Push (if the person installed the app and allowed it) and,
# where they asked for it, a WhatsApp message.
class Notifier
  def self.routes = Rails.application.routes.url_helpers

  def self.claim_created(claim)
    creator = claim.creator
    WebPushNotifier.deliver(creator,
      title: "New payment to confirm",
      body: "@#{claim.claimant.handle} sent #{claim.money_label} for #{claim.item_title}",
      url: routes.payment_claims_path, tag: "claims")
    return unless creator.notify_whatsapp_claims?

    WhatsappClient.send_notice(creator.phone_number,
      "@#{claim.claimant.handle} says they paid #{claim.money_label} (UTR #{claim.utr}). Check your bank, then approve in Wishful.")
  end

  def self.claim_approved(claim)
    fan = claim.claimant
    WebPushNotifier.deliver(fan,
      title: "#{claim.creator.first_name} approved your #{claim.item_kind}",
      body: "#{claim.item_title} is yours.",
      url: routes.payment_claim_path(claim), tag: "claim-#{claim.id}")
    return unless fan.phone_verified_at && fan.notify_whatsapp_claims?

    WhatsappClient.send_notice(fan.phone_number,
      "#{claim.creator.first_name} approved your payment. #{claim.item_title} is unlocked on Wishful.")
  end

  def self.claim_rejected(claim)
    WebPushNotifier.deliver(claim.claimant,
      title: "#{claim.creator.first_name} couldn't find your payment",
      body: "Check the UTR for #{claim.item_title}, or send #{claim.creator.first_name} your receipt.",
      url: routes.payment_claim_path(claim), tag: "claim-#{claim.id}")
  end
end
