class AddStudioFieldsToLiveSessionsAndMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :live_sessions, :duration_minutes, :integer, default: 60, null: false
    add_column :live_sessions, :admission_mode, :string, default: "vip_only", null: false
    add_column :live_sessions, :ticket_price_cents, :integer, default: 29900, null: false
    add_column :live_sessions, :stream_mode, :string, default: "obs_rtmp", null: false
    add_column :live_sessions, :stream_key, :string
    add_column :live_sessions, :auto_save_vault, :boolean, default: true, null: false
    add_column :live_sessions, :incentive_goal_enabled, :boolean, default: true, null: false
    add_column :live_sessions, :incentive_goal_cents, :integer, default: 1000000, null: false
    add_column :live_sessions, :incentive_reward_title, :string
    add_column :live_sessions, :pay_to_chat_cents, :integer, default: 5000, null: false
    add_column :live_sessions, :chat_delay_seconds, :integer, default: 10, null: false
    add_column :live_sessions, :forensic_watermark_enabled, :boolean, default: true, null: false
    add_column :live_sessions, :vip_alert_dispatch, :boolean, default: true, null: false

    add_column :live_messages, :tip_cents, :integer, default: 0, null: false
    add_column :live_messages, :is_announcement, :boolean, default: false, null: false
  end
end
