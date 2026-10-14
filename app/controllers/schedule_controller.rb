# Studio · Book (5f). One week of calls, lives and open slots on a calendar,
# beside the list of what fans can book.
class ScheduleController < ApplicationController
  before_action :require_user

  Entry = Struct.new(:at, :ends_at, :kind, :title, :detail, :path, keyword_init: true)

  def show
    @week_start = parse_week.beginning_of_week(:monday)
    week = @week_start.beginning_of_day..(@week_start + 6.days).end_of_day
    @entries = (live_entries(week) + meet_entries(week)).sort_by(&:at)

    hours = @entries.flat_map { |e| [ e.at.hour, (e.ends_at || e.at + 1.hour).hour + ((e.ends_at || e.at + 1.hour).min.positive? ? 1 : 0) ] }
    @first_hour = [ hours.min || 17, 17 ].min.clamp(0, 22)
    @last_hour = [ hours.max || 22, 22 ].max.clamp(@first_hour + 1, 24)

    @meet_offers = current_user.meet_offers.order(:created_at)
    @contact_reveals = current_user.contact_reveals.order(:created_at)
    @next_up = (live_entries(Time.current..60.days.from_now) + meet_entries(Time.current..60.days.from_now)).sort_by(&:at).first(6)
  end

  private

  def parse_week
    Date.strptime(params[:week].to_s, "%Y-%m-%d")
  rescue ArgumentError, TypeError
    Date.current
  end

  def live_entries(range)
    current_user.live_sessions.visible.where(scheduled_for: range).map do |live|
      Entry.new(at: live.scheduled_for, ends_at: live.scheduled_for + 1.hour, kind: :live,
                title: "Live · #{live.title}",
                detail: [ wf_time(live.scheduled_for), (live.members_only? ? "Close Friends" : "Everyone") ].join(" · "),
                path: studio_live_session_path(live))
    end
  end

  def meet_entries(range)
    MeetSlot.joins(:meet_offer)
            .includes(:meet_offer, meet_booking: :attendee)
            .where(meet_offers: { user_id: current_user.id })
            .where(starts_at: range)
            .map do |slot|
      booking = slot.meet_booking
      Entry.new(at: slot.starts_at, ends_at: slot.ends_at, kind: booking ? :call : :open,
                title: booking ? "Call · #{booking.attendee.handle}" : "Open slot",
                detail: booking ? "#{wf_time(slot.starts_at)} · #{helpers.money(booking.amount_cents, booking.currency)}" : slot.meet_offer.title,
                path: edit_meet_offer_path(slot.meet_offer))
    end
  end

  def wf_time(time) = time.strftime("%-l:%M %p")
end
