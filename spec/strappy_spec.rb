require 'rspec'
require 'strappy'

describe Strappy do

  strappy = Strappy.new("spec/example")
  test = "this is a test"
  result = strappy.processTemplates(binding())		

  it "processes .erb files" do
    result.to_s.should match /this is a test/
  end

  it "process other text/x-include-url" do
    result.to_s.should match /text\/x-include-url/
  end

  it "process other text/x-shellscript" do
    result.to_s.should match /text\/x-shellscript/
  end

  it "process other text/x-cloudconfig" do
    result.to_s.should match /text\/cloud-config/
  end

  it "process other text/upstart-job" do
    result.to_s.should match /text\/upstart-job/
  end

  it "process other text/part-handler" do
    result.to_s.should match /text\/part-handler/
  end

  it "process other text/cloud-boothook" do
    result.to_s.should match /text\/cloud-boothook/
  end
end