#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'json'
require 'hashie'

module GruffClient
  def self.new(endpoint)
    Client.new(endpoint)
  end

  class Exception < StandardError
    def initialize(code, message='GruffServer::Exception', body=nil)
      @code = code
      @body = body
      super(message)
    end
  end

  class BadRequest < Exception
    def initialize(message = 'GruffServer::BadRequest', body=nil)
      super 400, message, body
    end
  end

  class Unauthorized < Exception
    def initialize(message = 'GruffServer::Unauthorized', body=nil)
      super 401, message, body
    end
  end

  class Forbidden < Exception
    def initialize(message = 'GruffServer::Forbidden', body=nil)
      super 403, message, body
    end
  end

  class NotFound < Exception
    def initialize(message = 'GruffServer::NotFound', body=nil)
      super 404, message, body
    end
  end

  class InternalServerError < Exception
    def initialize(message = 'GruffServer::InternalServerError', body=nil)
      super 500, message, body
    end
  end

  class Client
    def initialize(endpoint)
      @uri = URI.parse(endpoint)
      @params = Params.new
    end

    def push_data(key, values)
      @params.data[key] = values
    end

    def post
      Net::HTTP.start(@uri.host, @uri.port) { |http|
        response = http.post('/graphs', @params.to_json)
        case response.code
        when /^20\d/
          JSON.parse(response.body)
        else
          raise_error(response)
        end
      }
    end

    def raise_error(response)
      case response.code
      when /^20\d/
        # nothing to do.
      when /^400/
        raise BadRequest.new('BadRequest', response.body)
      when /^401/
        raise Unauthorized.new('Unauthorized', response.body)
      when /^403/
        raise Forbidden.new('Forbidden', response.body)
      when /^404/
        raise NotFound.new('NotFound', response.body)
      when /^500/
        raise InternalServerError.new('InternalServerError', response.body)
      else
        raise Exception.new(response.code.to_i, 'UnexceptedException', response.body)
      end
    end

    def method_missing(method, *args)
      if @params.respond_to?(method)
        return @params.send(method, *args) 
      end

      super
    end
  end

  class Params < Hashie::Dash
    property :title, required: true, default: 'Graph'
    property :labels
    property :data, default: {}
  end
end

if __FILE__ == $0
  puts '= Example ='

  endpoint = ARGV.shift

  if !(endpoint && endpoint =~ URI.regexp)
    puts 'Usage error'
    puts "  $ ruby #{__FILE__} http://127.0.0.1:9292/"
    exit 1
  end

  # gruff client
  client = GruffClient.new(endpoint)

  # title
  client.title = 'My Graph'

  # data
  data = []
  data << [].tap { |data| 30.times { data << (rand()*5).to_i + 12 } }
  data << [].tap { |data| 30.times { data << (rand()*5).to_i + 15 } }
  data << [].tap { |data| 30.times { data << (rand()*5).to_i + 18 } }
  data.each_with_index { |data, i| client.push_data("data #{i}", data) }

  # labels
  labels = {}.tap { |labels| 30.times { |i| labels.merge!(i => (Date.today + i)) } }.select { |key, label| label.wday == 0 }
  client.labels = labels
  puts client.post
end
