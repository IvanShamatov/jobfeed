# encoding: utf-8

class Vacancy
  include ActionView::Helpers::DateHelper
  attr_accessor :title, :description, :url, :published, :author
  def initialize(entity, link=nil)
    @title = entity.title
    @description = entity.summary 
    @url = entity.url
    @published = entity.published
    @author = entity.author || get_author(link)
  end

  def get_author(link)
    case link
    when /hh.ru/
      "HeadHunter"
    when /itmozg/
      "ItMozg"
    when /stackoverflow/
      "Stackoverflow"
    when /mail.ru/
      "Mail.ru"
    when /hh.ua/
      "HeadHunter Ukraine"
    end
  end

  def to_hash
    {title: title,
     description: description,
     url: url,
     published: time_ago_in_words(published),
     author: author}
  end

end


class App < Sinatra::Base

  get '/' do
    erb :index 
  end

  get '/jobs/:word' do 
    content_type :json
    urls = [#"http://rabota.yandex.ru/rss.xml?currency=RUR&text=_WORD_",
            "http://rabota.mail.ru/rss/searchvacancy.xml?text=_WORD_",
            "http://hh.ru/rss/searchvacancy.xml?&text=_WORD_",
            "http://hh.ua/rss/searchvacancy.xml?&text=_WORD_",
            "http://rss.superjob.ru/vacancy/search/?keywords[0][keys]=_WORD_",
            "http://itmozg.ru/search/vacancy?VacancySearchParams[keyword]=_WORD_&rss=true",
            "http://careers.stackoverflow.com/jobs/feed?searchTerm=_WORD_&allowsremote=True"]
    urls.map! {|url| url.gsub!("_WORD_", params[:word])}
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