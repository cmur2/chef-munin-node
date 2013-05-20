class Chef::Node
  def generate_munin_node_conf
    return nil if self['munin-node']['conf'].nil?
    
    lines = []
    lines << ''
    
    self['munin-node']['conf'].each do |key,value_or_values|
      (value_or_values.kind_of?(Array) ? value_or_values : [ value_or_values ]).each do |value|
        lines << "#{key} #{value}"
      end
    end
    
    lines << ''
    lines.join "\n"
  end
end
