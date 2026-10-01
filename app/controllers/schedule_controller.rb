class ScheduleController < ApplicationController
  before_action :require_user

  # One calendar for everything a creator has to turn up to: booked meets and
  # scheduled lives. They live in different tables and mean different things,
  # so the view gets a single ordered list of plain structs rather than two
  # collections it has to interleave itself.
  Entry = Struct.new(:at, :ends_at, :kind, :title, :detail, :path, :state, keyword_init: true)

  def show
    @month = parse_month
    range = @month.beginning_of_month.beginning_of_day..@month.end_of_month.end_of_day

    @entries = (live_entries(range) + meet_entries(range)).sort_by(&:at)
    @by_day = @entries.group_by { |e| e.at.to_date }

    # "What is next" is the question a creator actually opens this for, and it
    # should not depend on which month they are looking at.
    @next_up = (live_entries(Time.current..1.year.from_now) +
                meet_entries(Time.current..1.year.from_now)).sort_by(&:at).first(5)
  end

  private

  def parse_month
    Date.strptime(params[:month].to_s, "%Y-%m")
  rescue ArgumentError, TypeError
    Date.current
  end

  def live_entries(range)
    current_user.live_sessions
                .visible
                .where(scheduled_for: range)
                .map do |live|
      Entry.new(
        at: live.scheduled_for, ends_at: nil, kind: :live,
        title: live.title,
        detail: live.members_only? ? "Members only" : "Open to everyone",
        path: live_session_path(live),
        state: live.status
      )
    end
  end

  def meet_entries(range)
    MeetSlot.joins(:meet_offer)
            .includes(:meet_offer, meet_booking: :attendee)
            .where(meet_offers: { user_id: current_user.id })
            .where(starts_at: range)
            .map do |slot|
      booking = slot.meet_booking
      Entry.new(
        at: slot.starts_at, ends_at: slot.ends_at, kind: :meet,
        title: slot.meet_offer.title,
        # A booked slot is an appointment with a person; an open one is just
        # availability, and the difference is the whole point of the row.
        detail: booking ? "Booked by @#{booking.attendee.handle}" : "Open slot",
        path: edit_meet_offer_path(slot.meet_offer),
        state: booking ? booking.status : "open"
      )
    end
  end
end
