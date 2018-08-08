class ScraperScheduleJob < ApplicationJob
  queue_as :schedule

  def perform
    Search.not_deleted.find_each do |search|
      ScrapeByQueryJob.perform_later search.id
    end
  end
end
