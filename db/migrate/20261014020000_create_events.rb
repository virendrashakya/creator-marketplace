class CreateEvents < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      CREATE TABLE events (
        id          BIGSERIAL,
        actor_id    BIGINT NOT NULL,
        creator_id  BIGINT,
        action      VARCHAR NOT NULL,
        target_type VARCHAR,
        target_id   BIGINT,
        properties  JSONB DEFAULT '{}',
        source      VARCHAR,
        referrer    VARCHAR,
        device_type VARCHAR,
        ip_hash     VARCHAR,
        session_id  VARCHAR,
        created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        PRIMARY KEY (id, created_at)
      ) PARTITION BY RANGE (created_at);

      CREATE INDEX idx_events_creator_action_date ON events (creator_id, action, created_at);
      CREATE INDEX idx_events_actor_action_date   ON events (actor_id, action, created_at);
      CREATE INDEX idx_events_target_action        ON events (target_type, target_id, action);
      CREATE INDEX idx_events_session              ON events (session_id);
    SQL

    # Create monthly partitions for the next 6 months from today.
    6.times do |i|
      start_date = Date.today.beginning_of_month + i.months
      end_date   = start_date + 1.month
      table_name = "events_#{start_date.strftime('%Y_%m')}"
      execute <<~SQL
        CREATE TABLE #{table_name} PARTITION OF events
          FOR VALUES FROM ('#{start_date}') TO ('#{end_date}');
      SQL
    end
  end

  def down
    execute "DROP TABLE IF EXISTS events CASCADE"
  end
end
