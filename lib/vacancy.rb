# encoding: utf-8
module JobFeed
  class Vacancy
    include ActionView::Helpers::DateHelper
    attr_accessor :title, :description, :url, :published, :author, :location
   
    def initialize(entity, link=nil)
      @title = entity.title
      @description = entity.summary 
      @url = entity.url
      @published = entity.published
      @author = entity.author || get_author(link)
      @location = entity.location || "Удаленно"
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
       published: time_ago_in_words(published)+" ago",
       author: author,
       location: location}
    end
  end

end