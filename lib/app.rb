# encoding: utf-8

module JobFeed
  class App < Sinatra::Base

    set :public_folder, 'public'

    get '/' do
      erb :index
    end


    # "http://rabota.yandex.ru/rss.xml?currency=RUR&text=_WORD_",
    # "http://rabota.mail.ru/rss/searchvacancy.xml?text=_WORD_",
    # "http://hh.ru/rss/searchvacancy.xml?&text=_WORD_",
    # "http://hh.ua/rss/searchvacancy.xml?&text=_WORD_",
    # "http://rss.superjob.ru/vacancy/search/?keywords[0][keys]=_WORD_",
    # "http://itmozg.ru/search/vacancy?VacancySearchParams[keyword]=_WORD_&rss=true",
    # "http://careers.stackoverflow.com/jobs/feed?searchTerm=_WORD_&allowsremote=True"]


    get '/jobs/:word' do 
      content_type :json
      params[:word] = URI.escape(params[:word].gsub(" ","+"))
      jobs = []
      if feed.respond_to?(:entries)
        jobs << feed.entries.map{|e| Vacancy.new(e, "mail.ru")}
      end
      jobs.flatten!
      jobs.sort_by!(&:published).reverse!
      jobs.map(&:to_hash).to_json
    end



    def redis
      @redis = Redis.new(path: "/tmp/redis.sock")
    end



    def feed
      marshaled_feed = redis.get "keyword:#{params[:word]}:feed"
      if marshaled_feed.nil?
        feed = Feedzirra::Feed.fetch_and_parse(feed_links)
        redis.set "keyword:#{params[:word]}:feed", Marshal.dump(feed)
        resis.sadd "keyword:#{params[:word]}:tokens", params[:token] unless params[:token].nil?
        feed        
      else 
        Marshal.load(marshaled_feed)
      end
    end



    def feed_links
      "http://rabota.mail.ru/rss/searchvacancy.xml?text=#{params[:word]}"
    end
 
  end
end