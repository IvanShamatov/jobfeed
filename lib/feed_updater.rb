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
        if feed.nil?
          return
        else
          feed = Marshal.load(feed)
          feed.update
          if feed.updated?
            counter = feed.new_entries.count
            # redis.publish ("push_notification", [feed, counter])
          end
          EM.next_tick &updater
        end
      end
      EM.next_tick &updater
    end



    def self.get_feeds
      keys = redis.keys("feed:*")
      feeds = redis.mget keys
    end



    def self.redis
      JobFeed.redis
    end
  end
end