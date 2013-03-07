Mancora.widgets do 

  # widget :errors do
  #   class_name ManualStat
  #   intervals [:hourly, :daily, :weekly, :monthly, :yearly]
  #   conditions :name => "error"
  # end

  # widget :subscribers_count do
  #   class_name Subscriber
  #   intervals :hourly
  #   field :registered_at
  #   time 1.day.ago #lag by one day
  # end

  # widget :total_subscribers_count do
  #   class_name Subscriber
  #   intervals [:daily, :weekly, :monthly, :yearly]
  #   count_type :total
  # end

  # widget :custm_promo_codes
  #   class_name Subscriber
  #   class_method generate_promo_code_hash
  #   intervals :monthly
  # end

end
