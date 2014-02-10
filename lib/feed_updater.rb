# encoding: utf-8
module JobFeed
  class FeedUpdater


    # Get all feeds from redis
    # run update on each
    # on_success, we need to get tokens for each feed
    # and push it in PubSub
    def self.run
      feeds = get_feeds
      EM::Iterator.new(feeds, 10).each do |feed, iter|
        word = feed[0]
        feed = Marshal.load(feed[1])
        feed = Feedzirra::Feed.update(feed)
        if feed.updated?
          counter = feed.new_entries.count
          redis.set word, feed
          word.gsub!("keyword:","")
          word.gsub!(":feed","")
          redis.publish ("push_notification", Marshal.dump([word, counter]))
        end
        puts "feed #{feed.feed_url} executed"
        iter.next
      end
    end



    def self.get_feeds
      keys = redis.keys("keyword:*:feed")
      feeds = redis.mget keys
      keys.zip(feeds)
    end



    def self.redis
      @redis ||= Redis.new(path: "/tmp/redis.sock")
    end
  end
end