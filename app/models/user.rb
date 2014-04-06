class User < ActiveRecord::Base
  validates_presence_of :name

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
    end
  end

  BATCH_SIZE = 1000
  def crawl_feed!(token)
    @graph = Koala::Facebook::API.new(token)
    objects = []
    feed = @graph.get_connections("me", "feed")
    loop do
      feed.each do |f|
        objects << build_algolia_object(f)
        if objects.length == BATCH_SIZE
          INDEX.add_objects(objects)
          objects = []
        end
      end
      feed = feed.next_page
      break if feed.nil? || feed.empty?
    end
    INDEX.add_objects(objects) unless objects.empty?
  end

  private
  def build_algolia_object(f)
    f.merge objectID: "#{uid}_#{f['id']}",
      _tags: [ uid, f['type'] ],
      created_time_i: DateTime.parse(f['created_time']).to_i,
      likes_count: f['likes'].try(:[], 'data').try(:length).to_i,
      comments_count: f['comments'].try(:[], 'data').try(:length).to_i
  end

end
