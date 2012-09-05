# Split the string between authors or at institutions.
AUTHOR_SEP = /\s*,\s*(?!\s*and\s)|(?:\s*,)?\s+and\s+|(\([^)]*\))/

# Each part of the legend starts with a numeric code.
LEGEND_SEP = /(?:,\s*|\s*and\s*)?(\(\d+\))/

# Split the legend references similarly to authors.
REF_SEP = /\s*,\s*(?!\s*and\s)|(?:\s*,)?\s+and\s+/

# Character codes of parenthesis.
LPAREN = '('
RPAREN = ')'


module Arxiv

  # Cleans up an author name (does almost nothing).
  def self.parse_author(name)
    return name.strip
  end

  # Cleans up an institution name (does almost nothing).
  def self.parse_institution(inst)
    inst = inst.strip
    if inst.length > 255
      inst = inst[0, 252] + '...'
    end
    return inst
  end

  # Parses the list of author names in the arxiv metadata.
  def self.parse_authors(names_str)
    # Look for a legend at the end of the string.
    legend = nil
    if names_str =~ /\((\s*\(.*)\)$/m
      legend_str = $~[1]
      names_str = names_str.slice(0, $~.begin(0))
      legend = parse_legend(legend_str)
    end

    # Split the authors list into individual names and institutions.
    names = []
    names_str.split(AUTHOR_SEP).each do |name|
      name = name.strip
      next if name.length == 0

      if (name[0] == LPAREN) and (name[-1] == RPAREN)
        if names.length > 0
          inst = substitute_legend(remove_parens(name), legend)
          inst = parse_institution(inst)
          names[-1][:institution] = inst
        end
      else
        name = parse_author(name)
        names << {:name => name}
      end
    end
    return names
  end

  # Parses the legend into a map from number to institution string.
  def self.parse_legend(legend_str)
    parts = legend_str.split(LEGEND_SEP)
    legend = {}
    i = 0
    while i < parts.length
      part = parts[i].strip
      if part.length == 0
        i += 1
      else
        if i + 1 < parts.length
          legend[remove_parens(part)] = parts[i+1].strip
        else
          $stderr.puts "improperly formatted legend: #{legend_str}"
        end
        i += 2
      end
    end
    return legend
  end

  # Substitutes from the legend if the string is a list of numbers.
  private
  def self.substitute_legend(str, legend)
    return str if not legend
    return str if not str =~ /^[and\d\s,]+$/  # quick format check

    parts = []
    str.split(REF_SEP).each do |ref|
      ref = ref.strip
      return str if not ref =~ /^[0-9]+$/  # full format check
      if legend.include? ref
        parts << legend[ref]
      else
        $stderr.puts "missing legend reference: #{ref}"
      end
    end
    return parts.join(", ")
  end

  # Returns a string of the form '(...)' with the parens removed.
  private
  def self.remove_parens(str)
    return str.slice(1, str.length - 2)
  end
end
