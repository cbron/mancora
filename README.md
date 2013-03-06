# Mancora [![Build Status](https://secure.travis-ci.org/cbron/mancora.png)](http://travis-ci.org/cbron/mancora)

Easily save counts of models or specific model queries on regular intervals into a single table to use for statistics.

For example, you can set up a count on the number of subscribers you get per hour, day, week, etc. That number will be saved in a table in the database with which you can do whatever you want (I'll show you how to graph it below). The other main option is a total count, basically a `User.count` for each of those time periods.


## Installation

Add this line to your application's Gemfile

    gem 'mancora'

And then execute

    bundle

To add it to your application

    rails g mancora:install
    rake db:migrate # Creates a mancora_stats table, use `Mancora::Stat` to access it

## Usage

Then setup your lib/mancora.rb file. Only class_name and intervals are required

    Mancora.widgets do

      widget :errors_per_hour do
        class_name Requests
        intervals :hourly
        conditions :name => "error"
      end
      #this generates: Request.where(:name => "error", :created_at => 1.hour.ago.beginning_of_hour..1.hour.ago.end_of_hour).count

      widget :subscribers_count do
        class_name Subscriber
        intervals [:hourly, :daily, :monthly, :yearly]
        field :registered_at
        time 1.day.ago #lag by one day
      end

      widget :total_subscribers_count do
        class_name Subscriber
        intervals [:daily, :weekly, :monthly, :yearly]
        count_type :total
      end

    end

Options

key | function
--- | ---
class_name | The class name you will be querying on
intervals | The interval you want to collect stats on
count_type | The type of count for this interval. `:timed` will query only this time period and is the default. `:total` will just do a total count on that modal, it cannot be backfilled. 
conditions | Additional conditions for query as a hash
field | Field other than created_at to query on. Not included if count_type is :total.
time | Amount of time to lag by: 1.day, 1.hour.


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

    

Result in db (notice subscribers_count has a day lag, and daily includes the time zone)

id | name | intervals | count | start | end
--- | --- | --- | --- | --- | ---
1 | errors | hourly | 4 | 2013-03-01 21:00:00 | 2013-03-01 21:59:59
2 | subscribers_count | hourly | 2 | 2013-02-28 21:00:00 | 2013-02-28 21:59:59
3 | total_subscribers_count | daily | 972 | 2013-02-27 07:00:00 | 2013-02-28 06:59:59


## Graphing the results

I ended up using Morris: http://www.oesmith.co.uk/morris.js/

After installing Raphael/Morris its as easy as: 

Controller

    @subscribers_today = Mancora::Stat.where(:name => "subscribers_count", :intervals => :hourly).limit(24).order("start desc")

View

    %h1 Subscribers today
    =content_tag :div, "", id: "subscribers_chart", data: {subscriberstoday: @subscribers_today} 

Coffeescript

    Morris.Line
      element: "subscribers_chart"
      data: $("#subscribers_chart").data('subscribers')
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

