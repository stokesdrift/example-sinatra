require 'sinatra'

class HelloWorld < Sinatra::Application
  get '/' do
    'Hello world!'
  end
end