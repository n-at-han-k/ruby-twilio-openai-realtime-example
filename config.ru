require 'bundler/setup'
Bundler.require :default
Dotenv.load

require 'async/websocket/adapters/rack'
require 'set'

$connections = Set.new

class IncomingCall
  def self.call(env)
    response = Twilio::TwiML::VoiceResponse.new
    response.say(message: "Connecting you to an agent.")

    url = "wss://#{ENV["HOST"]}/twilio-socket"
    puts url
    connect = Twilio::TwiML::Connect.new.stream(url: url)
    response.append(connect)

    [200, {"content-type" => "application/xml"}, [response.to_s]]
  end
end

class TwilioStream
  def self.call(env)
    Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
      $connections << connection
      
      while message = connection.read
        $connections.each do |connection|
          connection.write(message)
          connection.flush
        end
      end
    ensure
      $connections.delete(connection)
    end

    url = 'wss://api.openai.com/v1/realtime'
    query = '?model=gpt-4o-realtime-preview-2024-10-01'
    headers = [
      ["Authorization", "Bearer #{ENV['OPENAI_API_KEY']}"],
      ["OpenAI-Beta", "realtime=v1"]
    ]
	  endpoint = Async::HTTP::Endpoint.parse(url + query, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)

    Async::WebSocket::Client.connect(endpoint, headers: headers) do |connection|
      while message = connection.read
        puts message.inspect
      end
    end

  end
end

class Application
  def self.call(env)
    request = Rack::Request.new(env)
    if request.path == '/incoming-call'
      IncomingCall.(env)
    elsif request.path == '/twilio-stream'
      TwilioStream.(env)
    else
      default(env)
    end
  end

  def self.default(env)
    Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
      $connections << connection
      
      while message = connection.read
        $connections.each do |connection|
          connection.write(message)
          connection.flush
        end
      end
    ensure
      $connections.delete(connection)
    end or [200, {'content-type' => 'text/html'}, ["Hello World"]] 
  end
end

run Application
