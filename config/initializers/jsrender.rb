require 'tilt'
require 'stringio'

# Note: It does not make sense to run execjs on the template for the purpose of
# detecting errors since this would only be done ms before the same is done in
# the client. However, it would be useful to actually compile the template into
# javascript to send down if that is possible using the jstemplate library.
class JsRenderTemplate < Tilt::Template
  self.default_mime_type = 'application/javascript'

  def self.default_mime_type
    'application/javascript'
  end

  def self.engine_initialized?
    return true
  end

  def allows_script?
    return false
  end

  def prepare
  end

  def evaluate(scope, locals, &block)
    lines = []
    lines << "var #{variable_name} = $.templates("
    buf = StringIO.new(data, 'r')
    buf.each_line do |line|
      line = line.chomp
      line2 = line.lstrip
      line3 = line2.rstrip
      if line3.length > 0
        indent = ' ' * (line.length - line2.length)
        line3.gsub!(/\\/) { |s| '\\\\' }
        line3.gsub!(/\'/) { |s| '\\\'' }
        lines << "  #{indent}'#{line3}\\n' +"
      end
    end
    lines << "  '');"

    @output ||= lines.join("\n")
  end

  def variable_name
    name = File.basename(file)
    if name.index('.')
      name = name[0, name.index('.')]
    end
    parts = name.split('_')
    parts.each_index do |i|
      if i > 0
        parts[i] = parts[i].capitalize
      end
    end
    parts << 'Template'
    return parts.join('')
  end
end

Rails.application.assets.register_engine '.render', JsRenderTemplate
