# Async job for incremental fan profile engagement scoring.
# Subclasses FanProfileRecalculateJob to maintain compatibility with both
# job names across the codebase and architecture plan.
class IncrementFanProfileJob < FanProfileRecalculateJob
  queue_as :analytics
end
