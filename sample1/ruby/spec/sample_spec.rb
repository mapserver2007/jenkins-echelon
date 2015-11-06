$: << File.dirname(__FILE__) + "/../lib"
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

describe 'Sample' do
  it 'sample testcase' do
    result = Sample.new.add(1,2)
    expect(result).to eq(3)
  end

  it 'secret file from external' do
    result = Sample.new.load_secret()
    expect(result).to eq("hogehoge")
  end
end
