require 'benchmark'
require 'yaml'
#require 'marshal'

class Vac
  attr_accessor :title
  def initialize(title)
    @title = title
  end

  def dump
    Marshal.dump(self)
  end

  def self.load(string)
    Marshal.load(string)
  end
end


Benchmark.bm(1000) do |rpt|

  v1 = Vac.new("ruby")

  rpt.report("marshal") do 
    serialized_hash = Marshal.dump(v1)
    Marshal.load(serialized_hash)
  end

  rpt.report "yaml" do 
    serialized_hash = YAML.dump(v1)
    YAML.load(v1)
  end
end
