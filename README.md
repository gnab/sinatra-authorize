# sinatra-authorize

### Authentication-agnostic rule-based authorization extension for Sinatra

Provides a flexible rule-based authorization framework:

* Define `authorize` block for evaluating rules
* Set default rule for all routes
* Override default rule per route

Choice of authentication approach is entirely up to the application.

### Installation

    gem install sinatra-authorize

### Usage

Define `authorize` block for evaluating rules, and optionally set the default rule:

    authorize :deny => :all do |rule, args|
      # evaluate rule 
    end

Omitting a default rule when defining the `authorize` block makes 
`:allow => []` the default rule.

Override default rule per route:

    get '/', :allow => :all do
      # :allow => :all rule overrides default :deny => :all rule
    end

Authorization is performed just before the route is evaluated, after the
pattern has been matched and any other conditions have been evaluated.

#### Usage scenario

Simple scenario with default `:allow` rule, which is overriden for protected 
routes:

    require 'sinatra'
    require 'sinatra/authorize'

    enable :sessions

    authorize do |rule, args|
      if args == [:user]
        session[:user] != nil
      elsif args == [:admin]
        session[:admin] != nil
      end
    end

    # Availabe to all, as default rule is :allow => []
    get '/' do
    end

    # Availabe to all, as default rule is :allow => []
    post '/authenticate' do
      if params[:username] == 'username' && params[:password] == 'password'
        session[:user] = params[:username]

        if session[:user] == 'admin'
          session[:admin] = true
        end
      end
    end

    # Only run for authorized user requests, because of override rule 
    get '/content/:id', :allow => :user do
    end

    # Only run for authorized admin requests, because of override rule 
    get '/admin/content/:id', :allow => :admin do
    end

The `authorize` block only needs to handle the `:allow` rules present in the 
scenario. Also, only the rule arguments used, `:user` and `:admin`, are 
accounted for. No default rule is set when defining the `authorize` block, 
thus making `:allow => []` the default rule. The routes `/` and `/authenticate` 
is evaluated using the default `:allow` rule, whereas the `/content/:id` and 
`/admin/content:id` routes override the default rule.

### License 

sinatra-authorize is licensed under the MIT license. See LICENCE for further 
details.
