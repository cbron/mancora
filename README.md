# Mancora [![Build Status](https://secure.travis-ci.org/cbron/mancora.png)](http://travis-ci.org/cbron/mancora)

Easily save counts of models or specific model queries on regular intervals into a single table to use for statistics.

## Installation

Add this line to your application's Gemfile

    gem 'mancora'

And then execute

    bundle

To add it to your application

    rails g mancora:install
    rake db:migrate # Creates a mancora_stats table, use `Mancora::Stat` to access it

## Usage

Then setup your lib/mancora.rb file. Only class_name and interval are required

    Mancora.widgets do

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

Now to run it

    #in the console
    Mancora.run

    #backfill the last 36 hours
    Mancora.run(36)

    #via rake
    rake mancora

Finally setup a cron to run **every hour**. You could use the whenever gem but personally I still like: 

    # Every hour at 5 minutes in
    5 */1 * * * cd /rails_path && /usr/local/bin/rake RAILS_ENV=production mancora >> /rails_path/log/mancora.log 2>&1

    

Result in db (notice subscribers_count has a day lag)

id | name | interval | count | start | end
--- | --- | --- | --- | --- | ---
1 | errors | hourly | 4 | 2013-03-01 21:00:00 | 2013-03-01 21:59:59
2 | subscribers_count | hourly | 2 | 2013-02-28 21:00:00 | 2013-02-28 21:59:59


## Graphing the results

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

