module Logging
  # Records the given event in the log.
  def self.log_event(activity, user, duration=nil, params)
    evt = Event.new(
      :activity => activity,
      :at => Time.now)

    evt.user_id = user.id if user
    evt.duration = duration if duration

    evt.params = []
    params.each_key do |key|
      param = EventParam.new(:key => key)
      if params[key].class == String
        param.str_value = params[key]
      elsif params[key].class == Fixnum
        param.int_value = params[key]
      elsif params[key].class == Float
        param.float_value = params[key]
      else
        raise "Unsupported parameter type: #{params[key].class}"
      end
      evt.params << param
    end

    evt.save!
  end

  # Remove log records older than 30 days.
  def self.clean
    before_count = Event.count
    Event.where('at < ?', Time.now - 30 * 24 * 60 * 60).destroy_all
    after_count = Event.count

    $stderr.puts "Reduced log from #{before_count} to #{after_count} events."
  end
end
