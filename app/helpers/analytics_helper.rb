module AnalyticsHelper
  # Formats the given ratio as a float.
  def FormatRatio(numer, denom)
    return FormatFloat(numer / Float(denom))
  end

  # Formats the given float.
  def FormatFloat(value)
    return '%.1f' % value
  end
end
