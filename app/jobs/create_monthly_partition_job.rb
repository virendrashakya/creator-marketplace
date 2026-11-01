# Runs on the 25th of each month to pre-create next month's event partition.
# The events table uses PostgreSQL RANGE partitioning by created_at (monthly).
# Without this, inserts at month boundaries would fail with a
# "no partition of relation 'events' found" error.
class CreateMonthlyPartitionJob < ApplicationJob
  queue_as :maintenance

  def perform
    next_month = Date.today.next_month
    table_name = "events_#{next_month.strftime('%Y_%m')}"
    range_start = next_month.beginning_of_month.to_date
    range_end = (next_month + 1.month).beginning_of_month.to_date

    conn = ActiveRecord::Base.connection

    if conn.table_exists?(table_name)
      Rails.logger.info("[CreateMonthlyPartitionJob] Partition #{table_name} already exists, skipping.")
      return
    end

    conn.execute(<<~SQL)
      CREATE TABLE #{table_name} PARTITION OF events
      FOR VALUES FROM ('#{range_start}') TO ('#{range_end}');
    SQL

    Rails.logger.info("[CreateMonthlyPartitionJob] Created partition #{table_name} for #{range_start} to #{range_end}")
  rescue StandardError => e
    Rails.logger.error("[CreateMonthlyPartitionJob] Failed: #{e.message}")
    raise # Let Solid Queue retry
  end
end
