module Lab42::Rgxargs::PredefinedMatchers extend self
  PREDEFINED = {
    int_list: [%r{\A(-?\d+(?:,-?\d+)*)\z}, ->(groups){ groups.first.split(",").map(&:to_i)}],
    int_range: [%r{\A(-?\d+)(?:-|\.\.)(-?\d+)\z}, ->((f, l)){ Range.new(f.to_i, l.to_i) }],
    list:  [%r{(\w+)(?:,(\w+))*},   ->(groups){ groups.compact }],
    range: [%r{\A(\d+)\.\.(\d+)\z}, ->(groups){ Range.new(*groups.map(&:to_i)) }]
  }

  def defined_names
     @__defined_names__ ||= PREDEFINED.keys.join("\n\t")
  end

  def fetch(key, default=nil, &blk)
    return PREDEFINED[key] if PREDEFINED.has_key?(key)
    blk ? blk.(key) : default
  end

  def list_matcher values
    [%r{\A((?:#{values.join("|")})(?:,(?:#{values.join("|")}))*)\z}, _list_extractor]
  end


  # Memoized
  def _list_extractor
    @__list_extractor__ ||= ->(groups){ groups.first.split(",") }
  end
end
