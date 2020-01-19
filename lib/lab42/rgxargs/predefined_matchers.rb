module Lab42::Rgxargs::PredefinedMatchers extend self
  PREDEFINED = {
    list:  [%r{(\w+)(?:,(\w+))*},   ->(groups){ groups }],
    range: [%r{\A(\d+)\.\.(\d+)\z}, ->(groups){ Range.new(*groups.map(&:to_i)) }]
  }

  def defined_names
     @__defined_names__ ||= PREDEFINED.keys.join("\n\t")
  end
  def fetch(key, default=nil, &blk)
    return PREDEFINED[key] if PREDEFINED.has_key?(key)
    blk ? blk.(key) : default
  end
end
