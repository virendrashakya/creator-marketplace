class AddSectionHeadingsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Section headings were hardcoded in the profile view: "Behind the haul",
    # "Book me", "Things I recommend". They are written in the creator's own
    # voice but the creator could not change a word of them, so every page
    # said the same thing in the same tone.
    #
    # Null means "use the default", so existing pages keep the current copy
    # and nobody has to fill in six fields before their page reads correctly.
    add_column :users, :posts_heading, :string
    add_column :users, :media_heading, :string
    add_column :users, :links_heading, :string
    add_column :users, :meet_heading, :string
    add_column :users, :reveal_heading, :string
    # The referral disclosure is a legal-ish statement, so the default stays
    # authoritative, but a creator in a different arrangement needs to be able
    # to correct it.
    add_column :users, :links_note, :text
  end
end
