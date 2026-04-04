class CrmSyncJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    # Mocking job
  end
end
