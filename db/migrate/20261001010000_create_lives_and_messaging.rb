class CreateLivesAndMessaging < ActiveRecord::Migration[8.0]
  def change
    # ---- scheduled lives ----

    create_table :live_sessions do |t|
      t.references :user, null: false, foreign_key: true

      t.string :title, null: false
      t.text :description

      # When it is meant to start, and when it actually did / ended. Scheduled
      # time alone cannot tell you whether a live is running: creators start
      # late, and a live that ended must stop being watchable.
      t.datetime :scheduled_for, null: false
      t.datetime :started_at
      t.datetime :ended_at

      # scheduled -> live -> ended, plus canceled. Kept as a string for the
      # same reason the rest of this app does: it reads in a console and in
      # the logs without a lookup table.
      t.string :status, null: false, default: "scheduled"

      # Who may watch. "members" means an active subscription to one of this
      # creator's plans; "public" is a free live, which is how a creator
      # advertises the paid ones.
      t.string :access, null: false, default: "members"

      # Optional: gate on one specific plan rather than any of them, so a
      # creator can run a live only for their top tier.
      t.references :subscription_plan, foreign_key: true, null: true

      # The provider embed. Deliberately not tied to one vendor: this app has
      # no streaming account, so the video area takes whatever URL the
      # creator's provider gives them (Mux, LiveKit, an unlisted YouTube,
      # Zoom) and renders it only for people allowed to watch.
      t.string :playback_url

      t.integer :live_messages_count, null: false, default: 0

      t.timestamps
    end

    # The profile page asks for "this creator's upcoming lives, soonest
    # first", which is this index.
    add_index :live_sessions, [ :user_id, :scheduled_for ]
    add_index :live_sessions, [ :status, :scheduled_for ]

    # ---- chat inside a live ----
    #
    # Public to everyone in the room and tied to the live, which is what
    # makes it a different thing from a direct message: it has no recipient,
    # it is readable by every viewer, and it only exists while the live does.

    create_table :live_messages do |t|
      t.references :live_session, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    # Always read as "messages for this live, in order", and the catch-up
    # after a reconnect is "... after this id".
    add_index :live_messages, [ :live_session_id, :id ]

    # ---- direct messages ----
    #
    # A private thread between one fan and one creator. Separate from live
    # chat in every way that matters: two participants rather than a room,
    # kept forever rather than for the duration of a broadcast, and readable
    # only by the two people in it.

    create_table :conversations do |t|
      # Named rather than a generic join so the access rule is obvious at a
      # glance: a conversation is always fan -> creator on this app, because
      # that is the only direction a thread can start.
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :fan, null: false, foreign_key: { to_table: :users }

      # Denormalised for the inbox, which orders by most recent activity and
      # would otherwise need a join and a MAX() per row.
      t.datetime :last_message_at

      # Unread counts per side. Two columns rather than per-message read
      # flags: the inbox only ever needs "how many have I not seen", and a
      # flag per message makes that a count query on every row.
      t.integer :creator_unread_count, null: false, default: 0
      t.integer :fan_unread_count, null: false, default: 0

      t.timestamps
    end

    # One thread per pair. Without this a double-tap on "Message" would make
    # two threads and split the history.
    add_index :conversations, [ :creator_id, :fan_id ], unique: true
    add_index :conversations, [ :creator_id, :last_message_at ]
    add_index :conversations, [ :fan_id, :last_message_at ]

    create_table :direct_messages do |t|
      t.references :conversation, null: false, foreign_key: true
      # Who wrote it. Always one of the conversation's two participants,
      # enforced in the model.
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.timestamps
    end

    add_index :direct_messages, [ :conversation_id, :id ]
  end
end
