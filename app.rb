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
      urls = ["http://rabota.mail.ru/rss/searchvacancy.xml?text=_WORD_"]
      urls.map! {|url| url.gsub!("_WORD_", URI.escape(params[:word].gsub(" ","+")))}
      feeds = Feedzirra::Feed.fetch_and_parse(urls)
      jobs = []
      feeds.each do |link, feed|
        if feed.respond_to?(:entries)
          jobs << feed.entries.map{|e| Vacancy.new(e, link)}
        end
      end
      jobs.flatten!
      jobs.sort_by!(&:published).reverse!
      jobs.map(&:to_hash).to_json
    end


  end
end