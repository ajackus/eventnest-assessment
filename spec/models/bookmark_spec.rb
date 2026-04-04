require "rails_helper"

RSpec.describe Bookmark, type: :model do
  let(:attendee) { create(:user, role: "attendee") }
  let(:organizer) { create(:user, role: "organizer") }
  let(:event) { create(:event) }

  it "is valid for an attendee" do
    bookmark = Bookmark.new(user: attendee, event: event)
    expect(bookmark).to be_valid
  end

  it "is invalid for an organizer" do
    bookmark = Bookmark.new(user: organizer, event: event)
    expect(bookmark).not_to be_valid
    expect(bookmark.errors[:user]).to include("must be an attendee to bookmark events")
  end

  it "enforces uniqueness of user and event" do
    create(:bookmark, user: attendee, event: event)
    duplicate = Bookmark.new(user: attendee, event: event)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:user_id]).to include("has already bookmarked this event")
  end
end
