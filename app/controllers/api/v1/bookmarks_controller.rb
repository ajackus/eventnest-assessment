module Api
  module V1
    class BookmarksController < ApplicationController
      def index
        bookmarks = current_user.bookmarks.includes(:event)
        render json: bookmarks.map { |b|
          {
            id: b.id,
            event: {
              id: b.event.id,
              title: b.event.title,
              starts_at: b.event.starts_at,
              city: b.event.city
            },
            created_at: b.created_at
          }
        }
      end

      def create
        event = Event.find(params[:event_id])
        bookmark = current_user.bookmarks.new(event: event)

        if bookmark.save
          render json: { id: bookmark.id, message: "Event bookmarked successfully" }, status: :created
        else
          render json: { errors: bookmark.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        bookmark = current_user.bookmarks.find_by(event_id: params[:event_id])
        
        if bookmark
          bookmark.destroy
          head :no_content
        else
          render json: { error: "Bookmark not found" }, status: :not_found
        end
      end
    end
  end
end
