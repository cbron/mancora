class Widget
  attr_accessor :name, :class_name, :interval, :conditions, :start, :end, :time, :field
  
  def initialize(name, backfill = 0, &block)
    @name = name
    @conditions = {}
    instance_eval &block

    @time ||= Time.now
    @field ||= :created_at

    #run all backfills plus the original @time
    backfill.downto(0) do |b|
      @run_time = @time - b.hours
      @interval.each do |i|
        conditions = @conditions.merge!(get_interval(i))
        run(i, conditions) if should_i_run?(i)
      end
    end
  end

  def class_name(str)
    @class_name = str
  end

  def interval(opts)
    @interval =  opts.instance_of?(Array)? opts : [opts]
  end

  def conditions(str)
    @conditions =  str
  end

  def time(str)
    @time = str
  end

  def field(str)
    @field = str
  end

  def run(interval, conditions)
    puts "Running " + interval.to_s.capitalize + " " + self.name.to_s
    result = @class_name.where(conditions)

    #create or update record, this way we can backfill without overwriting
    obj = Mancora::Stat.find_or_initialize_by_name_and_start(name, @start)

    obj.update_attributes(
       :name => @name,
       :start => @start,
       :end => @end,
       :interval => interval,
       :count => result.count
    )
  end

  #given an interval symbol, return a hash with the correct conditions
  def get_interval(interval)
    case interval
      when :custom
        return {}
      when :hourly
        @start = (@run_time - 1.hour).beginning_of_hour
        @end = (@run_time - 1.hour).end_of_hour
        return {@field => @start..@end}
      when :daily
        @start = @run_time.yesterday.beginning_of_day
        @end = @run_time.yesterday.end_of_day
        return {@field => @start..@end}
      when :weekly
        @start = @run_time.yesterday.beginning_of_week
        @end = @run_time.yesterday.end_of_week
        return {:created_at => @start..@end}
      when :monthly
        @start = @run_time.yesterday.beginning_of_month
        @end = @run_time.yesterday.end_of_month
        return {:created_at => @start..@end}
      when :yearly
        @start = @run_time.yesterday.beginning_of_year
        @end = @run_time.yesterday.end_of_year
        return {:created_at => @start..@end}
    end
  end

  #given an interval symbol, determine whether or not a query (and relative db insert) should take place
  def should_i_run?(interval)
    if interval == :hourly
      true
    elsif @run_time.hour == 0 && interval == :daily
      true
    elsif @run_time.beginning_of_week == @run_time.beginning_of_day && interval == :weekly
      true
    elsif (@run_time.day == 1) && interval == :monthly
      true
    elsif @run_time.beginning_of_year == @run_time.beginning_of_day && interval == :yearly
      true
    else
      false
    end
  end


end