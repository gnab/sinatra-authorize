require File.join(File.dirname(__FILE__), '..', 'spec_helper')

def set_and_get(route = '/', rules = {})
  app.get(route, rules) {}
  get route
end

describe Sinatra::Authorize do
  before :each do
    app.reset!
    if app.respond_to? :authorize_default
      class << app; undef_method(:authorize_default); end
    end
    if app.respond_to? :authorize_block
      class << app; undef_method(:authorize_block); end
    end
  end

  context 'defining route' do
    it 'should be possible to set allow rule' do
      app.get '/', :allow => :all do end
    end

    it 'should be possible to set deny rule' do
      app.get '/', :deny => :all do end
    end
  end

  context 'defining authorize block' do
    it 'should be possible to define' do
      app.authorize do |rule, args| end
    end

    it 'should be possible to set default route' do
      app.authorize :allow => :all do |rule, args| end
    end

    it 'should use default route :allow => [] when no route is set' do
      app.authorize do |rule, args| end
      authorize_block = mock('authorize_block')
      authorize_block.should_receive(:call).with(:allow, [])
      app.authorize_block.should_receive(:bind).and_return(authorize_block)
      set_and_get
    end
  end

  context 'authorize block not defined' do
    it 'should raise exception when default rule is set' do
      app.authorize :allow => :all
      expect { set_and_get }.to raise_error(
        RuntimeError, 'No authorize block is defined.')
    end

    it 'should raise exception when route rule is set' do
      expect { set_and_get '/', :allow => :all }.to raise_error(
        RuntimeError, 'No authorize block is defined.')
    end
  end
end
