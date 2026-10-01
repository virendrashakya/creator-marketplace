class AddControlsToLiveSessions < ActiveRecord::Migration[8.0]
  def change
    # Controls a creator reaches for mid-broadcast, from the studio page.
    # All default to the permissive setting a live normally wants, so an
    # existing live keeps behaving the way it already did.
    change_table :live_sessions, bulk: true do |t|
      # Interaction. Chat can be turned off entirely, or narrowed to members
      # when a public live gets rowdy.
      t.boolean :chat_enabled, null: false, default: true
      t.boolean :chat_members_only, null: false, default: false

      # Privacy. Unlisted keeps the live off the creator's public page so the
      # only way in is the link; it is not a second paywall, and the access
      # rules still apply on top.
      t.boolean :unlisted, null: false, default: false
      # Whether the chat transcript survives the broadcast. Some lives are
      # meant to be ephemeral.
      t.boolean :keep_chat_after, null: false, default: true
    end
  end
end
