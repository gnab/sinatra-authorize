require File.join(File.dirname(__FILE__), '..', 'spec_helper')

shared_examples_for "when no default authorization is set" do
  it 'should allow route with allow all rule' do
    app.get('/', :allow => :all) {}
    get '/'
    last_response.status.should == 200
  end

  it 'should allow route with deny none rule' do
    app.get('/', :deny => :none) {}
    get '/'
    last_response.status.should == 200
  end

  it 'should deny route with deny all rule' do
    app.get('/', :deny => :all) {}
    get '/'
    last_response.status.should == 403
  end

  it 'should deny route with allow none rule' do
    app.get('/', :allow => :none) {}
    get '/'
    last_response.status.should == 403
  end
end

describe Sinatra::Authorize do
  
  before :all do
    app.authorize  do |rule, args|
      allow_default = lambda do |args|
        if args == [] || args == [:all]
          true
        elsif args == [:none]
          false
        else
          raise "Unknown authorization rule argument: #{args}."
        end
      end

      if rule == :allow
        allow_default.call(args)
      elsif rule == :deny
        !allow_default.call(args)
      else
        raise "Unknown authorization rule: #{rule}."
      end
    end
  end

  before do
    app.reset!
  end

  it 'should allow routes by default' do
    app.get('/') {}
    get '/'
    last_response.status.should == 200
  end  

  it_behaves_like "when no default authorization is set"

  context "#authorize :allow" do
    before do
      app.authorize :allow
    end

    it 'should allow routes by default' do
      app.get('/') {}
      get '/'
      last_response.status.should == 200
    end

    it_behaves_like "when no default authorization is set"

    context ' => :all' do
      before do
        app.authorize :allow => :all
      end

      it 'should allow routes by default' do
        app.get('/') {}
        get '/'
        last_response.status.should == 200
      end

      it_behaves_like "when no default authorization is set"
    end

    context ' => :none' do
      before do
        app.authorize :allow => :none
      end

      it 'should deny routes by default' do
        app.get('/') {}
        get '/'
        last_response.status.should == 403
      end

      it_behaves_like "when no default authorization is set"
    end
  end

  context '#authorize :deny' do
    before do
      app.authorize :deny
    end

    it 'should deny routes by default' do
      app.get('/') {}
      get '/'
      last_response.status.should == 403
    end

    it_behaves_like "when no default authorization is set"

    context ' => :all' do
      before do
        app.authorize :deny => :all
      end

      it 'should deny routes by default' do
        app.get('/') {}
        get '/'
        last_response.status.should == 403
      end

      it_behaves_like "when no default authorization is set"
    end

    context ' => :none' do
      before do
        app.authorize :deny => :none
      end

      it 'should allow routes by default' do
        app.get('/') {}
        get '/'
        last_response.status.should == 200
      end

      it_behaves_like "when no default authorization is set"
    end
  end
end
