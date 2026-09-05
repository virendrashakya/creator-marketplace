class AllowUploadedMediaOnly < ActiveRecord::Migration[8.0]
  def change
    change_column_null :paid_media_posts, :media_url, true
    change_column_null :paid_media_posts, :price_cents, true
  end
end
