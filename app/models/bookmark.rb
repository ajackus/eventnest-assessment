class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :user_id, uniqueness: { scope: :event_id, message: "has already bookmarked this event" }
  validate :user_is_attendee

  private

  def user_is_attendee
    errors.add(:user, "must be an attendee to bookmark events") unless user&.role == "attendee"
  end
end
