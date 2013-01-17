require 'rspec'
require 'strappy'

describe Strappy do
  it "does not barf on all kinds of input" do
    strappy = Strappy.new("test/example")
    test = "this is a test"
    result = strappy.processTemplates(binding())

    result.should contain test
  end
end