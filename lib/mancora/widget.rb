class Widget
  attr_accessor :name, :class_name, :interval, :count_type, :conditions, :start, :end, :time, :field, :query
  
  def initialize(name, backfill = 0, &block)
    @name = name
    @conditions = {}
    instance_eval &block

    lazy_names

    #run all backfills plus the original @time
    backfill.downto(0) do |b|
      b != 0 ? @backfilling = true : @backfilling = false
      @run_time = @time - b.hours

      @interval.each do |i|
        time_interval = @query.blank? ? get_interval(i) : {}
        all_conditions = @conditions.merge(time_interval)
        run(i, all_conditions) if should_i_run?(i)
      end
    end

  end

  def class_name(str)
    @class_name = str
  end

  def interval(opts)
    @interval =  opts.instance_of?(Array)? opts : [opts]
  end

  def count_type(str)
    @count_type = str
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

  def query(str)
    @query = str
  end

  def lazy_names
    @time ||= Time.now
    @field ||= :created_at
    @count_type ||= :timed
  end

  def run(interval, all_conditions)
    puts "Running " + interval.to_s + " " + self.name.to_s
    if @count_type == :timed
      result = @class_name.where(all_conditions)
    elsif @count_type == :total
      count = (@backfilling ? nil : @class_name.where(@conditions).count)
    elsif !@query.blank?
      result = eval(@query)
    end

    #create or update record, this way we can backfill without overwriting
    obj = Mancora::Stat.find_or_initialize_by_name_and_start(name, @start)

    obj.update_attributes(
       :name => @name,
       :start => @start,
       :end => @end,
       :interval => interval,
       :count => (@count_type == :timed ? result.count : count)
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
        return {@field => @start..@end}
      when :monthly
        @start = @run_time.yesterday.beginning_of_month
        @end = @run_time.yesterday.end_of_month
        return {@field => @start..@end}
      when :yearly
        @start = @run_time.yesterday.beginning_of_year
        @end = @run_time.yesterday.end_of_year
        return {@field => @start..@end}
    end
  end

  #given an interval symbol, determine whether or not a query (and relative db insert) should take place
  def should_i_run?(interval)
    if interval == :hourly
      true
    elsif interval == :daily && @run_time.hour == 0
      true
    elsif interval == :weekly && @run_time.beginning_of_week == @run_time.beginning_of_day
      true
    elsif interval == :monthly && @run_time.day == 1
      true
    elsif interval == :yearly && @run_time.beginning_of_year == @run_time.beginning_of_day
      true
    else
      false
    end
  end


end