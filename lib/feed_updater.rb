# encoding: utf-8
module JobFeed
  class FeedUpdater


    # Get all feeds from redis
    # run update on each
    # on_success, we need to get tokens for each feed
    # and push it in PubSub
    def self.run
      feeds = get_feeds
      updater = Proc.new do
        feed = feeds.shift
        unless feed.nil?
          feed = Marshal.load(feed)
          feed = Feedzirra::Feed.update(feed)
          if feed.updated?
            counter = feed.new_entries.count
            # redis.publish ("push_notification", [feed, counter])
          end
          puts "feed #{feed.feed_url} executed"
          EM.next_tick &updater
        end
      end
      EM.next_tick &updater
      puts "exit from updater"
    end



    def self.get_feeds
      keys = redis.keys("keyword:*")
      feeds = redis.mget keys
    end



    def self.redis
      @redis ||= Redis.new(path: "/tmp/redis.sock")
    end
  end
end