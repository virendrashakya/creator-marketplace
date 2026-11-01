module Api
  module V1
    class PaymentClaimsController < BaseController
      def create
        purchasable_type = params[:purchasable_type].presence || "PaidMediaCollection"
        purchasable_id = params[:purchasable_id]

        purchasable = case purchasable_type
                      when "PaidMediaCollection" then PaidMediaCollection.live.find(purchasable_id)
                      when "PaidMediaPost" then PaidMediaPost.published.find(purchasable_id)
                      else return render json: { error: "Unsupported item" }, status: :unprocessable_entity
                      end

        creator = purchasable.user
        amount_cents = purchasable.price_cents

        claim = PaymentClaim.new(
          claimant: current_user,
          creator: creator,
          purchasable: purchasable,
          amount_cents: amount_cents,
          currency: purchasable.currency,
          payment_method: "upi_manual",
          status: "pending",
          utr: params[:utr].to_s.strip
        )

        paid = params[:paid_rupees].to_s.gsub(/[^0-9.]/, "")
        claim.claimed_amount_cents = paid.present? ? (paid.to_f * 100).round : amount_cents

        if claim.save
          if claim.auto_approvable?
            claim.approve!(creator)
          else
            Notifier.claim_created(claim) rescue nil
          end

          # Track event
          EventTracker.track(
            action: "payment_claim_created",
            actor: current_user.id,
            creator: creator.id,
            target: purchasable,
            properties: { utr: claim.utr, amount_cents: claim.amount_cents, status: claim.status },
            request: request
          )

          render json: {
            success: true,
            status: claim.status,
            unlocked: claim.status == "approved",
            message: claim.status == "approved" ? "Unlocked successfully!" : "Claim submitted! Waiting for creator approval."
          }
        else
          render json: { error: claim.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        render json: { error: "This 12-digit UTR was already claimed." }, status: :unprocessable_entity
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
