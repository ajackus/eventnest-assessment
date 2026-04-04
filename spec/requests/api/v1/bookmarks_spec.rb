require "rails_helper"

RSpec.describe "Api::V1::Bookmarks", type: :request do
  let(:attendee) { create(:user, role: "attendee") }
  let(:organizer) { create(:user, role: "organizer") }
  let(:event) { create(:event) }
  let(:token) { attendee.generate_jwt }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "POST /api/v1/events/:event_id/bookmark" do
    it "creates a bookmark for an attendee" do
      post "/api/v1/events/#{event.id}/bookmark", headers: headers
      expect(response).to have_http_status(:created)
      expect(Bookmark.count).to eq(1)
    end

    it "rejects duplicate bookmarks" do
      create(:bookmark, user: attendee, event: event)
      post "/api/v1/events/#{event.id}/bookmark", headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("User has already bookmarked this event")
    end

    it "prevents organizers from bookmarking" do
      org_token = organizer.generate_jwt
      post "/api/v1/events/#{event.id}/bookmark", headers: { "Authorization" => "Bearer #{org_token}" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("User must be an attendee to bookmark events")
    end
  end

  describe "GET /api/v1/bookmarks" do
    it "lists bookmarks for the current user" do
      create(:bookmark, user: attendee, event: event)
      get "/api/v1/bookmarks", headers: headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).length).to eq(1)
    end
  end

  describe "DELETE /api/v1/events/:event_id/bookmark" do
    it "removes a bookmark" do
      create(:bookmark, user: attendee, event: event)
      delete "/api/v1/events/#{event.id}/bookmark", headers: headers
      expect(response).to have_http_status(:no_content)
      expect(Bookmark.count).to eq(0)
    end
  end

  describe "Event JSON visibility" do
    let!(:bookmark) { create(:bookmark, user: attendee, event: event) }

    it "shows bookmarks_count to the organizer" do
      org_token = event.user.generate_jwt
      get "/api/v1/events/#{event.id}", headers: { "Authorization" => "Bearer #{org_token}" }
      expect(JSON.parse(response.body)["bookmarks_count"]).to eq(1)
    end

    it "does not show bookmarks_count to an attendee" do
      get "/api/v1/events/#{event.id}", headers: headers
      expect(JSON.parse(response.body)["bookmarks_count"]).to be_nil
    end
  end
end
