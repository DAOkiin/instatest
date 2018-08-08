class ScrapeByQueryJob < ApplicationJob
  queue_as :scrapers

  def perform(search_id)
    data = Scraper::YoulaService.call(query: Search.find(search_id).query)
    ItemsService.call search_id: search_id, data: data
  end
end
