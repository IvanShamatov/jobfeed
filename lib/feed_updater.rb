# encoding: utf-8
module JobFeed
  class FeedUpdater
    # Get all feeds from redis
    # run update on each
    # on_success, we need to get tokens for each feed
    # and push it in PubSub
    def run
      JobFeed.redis.incr 'updater'    
    end
  end
end