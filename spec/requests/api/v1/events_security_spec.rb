require "rails_helper"

RSpec.describe "Api::V1::Events Security", type: :request do
  let!(:published_event) { create(:event, title: "Public Event", status: "published", starts_at: 1.day.from_now) }
  let!(:draft_event) { create(:event, title: "Secret Draft", status: "draft", starts_at: 1.day.from_now) }

  describe "GET /api/v1/events" do
    it "does not return draft events via SQL injection" do
      # SQL injection payload to try and see draft events
      injection_payload = "' OR status = 'draft' OR '1'='1"
      
      get "/api/v1/events", params: { search: injection_payload }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      # Should only see the published event (if it matched, which it shouldn't)
      # or no events at all if the search doesn't match literal injection string.
      event_titles = json_response.map { |e| e["title"] }
      expect(event_titles).not_to include("Secret Draft")
    end

    it "handles single quotes safely" do
      get "/api/v1/events", params: { search: "O'Reilly" }
      expect(response).to have_http_status(:success)
    end
  end
end
