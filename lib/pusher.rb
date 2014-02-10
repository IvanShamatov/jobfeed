# encoding: utf-8
module JobFeed
  class Pusher

    def self.run(message)
      word, counter = Marshal.load(message)
      tokens = get_tokens (word)
      EM::Iterator.new(tokens).each do |token, iter|
        pusher.push( notification(token, word, counter) )
        iter.next
      end
    end



    def self.get_tokens(word)
      redis.smembers("keyword:#{word}:tokens")
    end

    def self.notification(token, word, counter)
      Grocer::Notification.new(
          device_token: "#{token}",
          alert: "New jobs available",
          badge: counter,
          expiry: Time.now + 60*60*24
      )
    end

    def self.pusher
      @pusher ||= Grocer.pusher(certificate: "./../certificate.pem")
    end


    def self.redis
      @redis ||= Redis.new(path: "/tmp/redis.sock")
    end
  end
end