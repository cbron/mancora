# Mancora

Easily save counts of models or specific model queries on regular intervals into a single table to use for statistics.

## Installation

Add this line to your application's Gemfile:

    gem 'mancora'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mancora
    rails g mancora:install
    rake db:migrate # Creates a mancora_stats table, Mancora::Stat from rails

Then setup your lib/mancora.rb file

    Mancora.widgets do 

      # widget :example do 
      #   class_name whatever_class_name_to_query
      #   interval [:hour, :daily, :weekly, :monthly, :yearly]
      #   conditions any_condition_to_include_in_query
      #   field field_if_not_created_at
      #   time if_not_default_of_last_hour
      # end

      widget :errors do
        class_name ManualStat
        interval [:hourly, :daily, :monthly]
        conditions :name => "error"
      end

      widget :subscribers_count do
        class_name Subscriber
        interval :hourly
        field :registered_at
        time 1.day.ago #lag by one day
      end

    end


Finally setup the cron

    cron here

This will create:

    db stuff here

## Using in a view


    # show how to use in Controller/View with Morris. 



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
