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
    get '/content/:id' :allow => :user do
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

(The MIT License)

Copyright (c) 2011 Ole Petter Bang &lt;olepbang@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
