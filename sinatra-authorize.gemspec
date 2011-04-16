# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'sinatra-authorize/version'

Gem::Specification.new do |s|
  s.name        = "sinatra-authorize"
  s.version     = Sinatra::Authorize::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ole Petter Bang"]
  s.email       = ["olepbang@gmail.com"]
  s.homepage    = "https://github.com/gnab/sinatra-authorize"
  s.summary     = "Smooth authentication-agnostic rule-based authorization " +
                  "extension for Sinatra"
  s.description = s.summary

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "sinatra-authorize"

  s.add_development_dependency "bundler", ">= 1.0.0.rc.5"
  s.add_development_dependency "rake", ">= 0.8"
  s.add_development_dependency "rack-test", ">= 0.5.7"
  s.add_development_dependency "rspec", ">= 2.4"

  s.add_runtime_dependency "sinatra", ">= 1.2"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
end
