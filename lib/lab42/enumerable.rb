module Enumerable
  def find_value default=nil, &blk
    each do |ele|
      value = blk.(ele)
      return value if value
    end
    default
  end
end
