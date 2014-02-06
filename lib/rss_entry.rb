module Feedzirra
  module Parser
    class RSSEntry
      element :"hhvac:creationTime", :as => :create_time
      element :"hhvac:vacancyId", :as => :external_vacancy_id
      element :"hhvac:workExperience", :as => :work_experience
      element :"hhvac:compensationFrom", :as => :salary_from
      element :"hhvac:compensationTo", :as => :salary_to
      element :"hhvac:compensationCurrency", :as => :salary_currency
      element :"hhvac:areaName", :as => :location
      element :"hhvac:employerId", :as => :external_employer_id
      element :"hhvac:employerName", :as => :employer_name
      element :"hhvac:employerEmail", :as => :employer_email
      element :"hhvac:companyName", :as => :company_name
      element :"hhvac:profArea", :as => :category      
    end
  end
end