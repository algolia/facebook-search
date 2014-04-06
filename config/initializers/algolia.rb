Algolia.init application_id: ENV['ALGOLIA_APPLICATION_ID'], api_key: ENV['ALGOLIA_API_KEY']
INDEX = Algolia::Index.new("facebook_#{Rails.env}")
INDEX.set_settings({
  attributesToIndex: ['unordered(description)', 'unordered(name)', 'unordered(message)', 'unordered(comments.data.message)', 'unordered(story)'],
  attributesForFaceting: ['application.name', 'type', 'story_tags.name', 'from.name'],
  customRanking: ['desc(created_time_i)']
})
