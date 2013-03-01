# Mancora

Easily save counts of models or specific model queries on regular intervals into a single table to use for statistics.

## Installation

Add this line to your application's Gemfile:

    gem 'mancora'

And then execute:

    $ bundle

Or install it yourself as:

    gem install mancora
    rails g mancora:install
    rake db:migrate # Creates a mancora_stats table, Mancora::Stat from rails

Then setup your lib/mancora.rb file. Only class_name and interval are required

    Mancora.widgets do

      # widget :example do 
      #   class_name whatever_class_name_to_query
      #   interval [:hour, :daily, :weekly, :monthly, :yearly]
      #   conditions any_condition_to_include_in_query
      #   field field_if_not_created_at
      #   time lag_by_this_amount
      # end

      widget :errors do
        class_name Requests
        interval :hourly
        conditions :name => "error"
      end

      widget :subscribers_count do
        class_name Subscriber
        interval [:hourly, :daily, :monthly, :yearly]
        field :registered_at
        time 1.day.ago #lag by one day
      end

    end

To run this in the console
    Mancora.run

And to backfill the last 36 hours
    Mancora.run(36)

Finally setup the cron

    cron here

Result in db

id | name | interval | count | start | end | created_at | updated_at
--- | --- | --- | --- | --- | --- | --- | --- 
1 | errors | hourly | 4 | 2013-03-01 21:00:00 | 2013-03-01 21:59:59 | 2013-03-01 22:13:52 | 2013-03-01 22:13:52
2 | subscribers_count | hourly | 2 | 2013-02-28 21:00:00 | 2013-02-28 21:59:59 | 2013-03-01 22:13:52 | 2013-03-01 22:13:52


## Graphing in a view

I ended up using Morris: http://www.oesmith.co.uk/morris.js/
After installing Raphael/Morris its as easy as: 

Controller

    @errors_today = Mancora::Stat.where(:name => "errors", :interval => :hourly).limit(24).order("start desc")

View

    %h1 Errors today
    =content_tag :div, "", id: "errors_chart", data: {errors: @errors_today} 

Coffeescript

    Morris.Line
      element: "errors_chart"
      data: $("#errors_chart").data('errors')
      xkey: "start"
      ykeys: ["count"]
      labels: ["Count"]
      hideHover: false


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
