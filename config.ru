require 'bundler/setup'
Bundler.require :default
Dotenv.load

require 'async/websocket/adapters/rack'
require 'async/barrier'

require_relative 'lib/socket/open_ai'
require_relative 'lib/socket/twilio'
require_relative 'lib/bridge'

URL = 'wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-10-01'
HEADERS = [
  ["Authorization", "Bearer #{ENV['OPENAI_API_KEY']}"],
  ["OpenAI-Beta", "realtime=v1"]
]

class IncomingCall
  def self.call(env)
    response = Twilio::TwiML::VoiceResponse.new
    #response.say(message: "Connecting you to an agent.")

    url = "wss://#{ENV["HOST"]}/ai-stream"
    connect = Twilio::TwiML::Connect.new.stream(url: url)
    response.append(connect)

    [200, {"content-type" => "application/xml"}, [response.to_s]]
  end
end

class AiStream
  def self.call(env)
    Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws'], handler: Socket::Twilio) do |twilio|

      openai = Async::WebSocket::Client.connect(openai_endpoint, headers: HEADERS, handler: Socket::OpenAi)
      bridge = Bridge.new twilio, openai

      openai_task = Async do
        while message = openai.read
          bridge.handle_openai(message.parse)
        end
      end

      while message = twilio.read
        bridge.handle_twilio(message.parse)
      end

      puts 'DISCONNECTED'

    ensure
      openai&.close
      openai_task&.stop
    end
  end

  def self.openai_endpoint
	  Async::HTTP::Endpoint.parse(URL, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
  end
end

class Application
  def self.call(env)
    request = Rack::Request.new(env)
    if request.path == '/incoming-call'
      IncomingCall.(env)
    elsif request.path == '/ai-stream'
      AiStream.(env)
    else
      default(env)
    end
  end

  def self.default(env)
    Async::WebSocket::Adapters::Rack.open(env, protocols: ['ws']) do |connection|
      while message = connection.read
        puts message.parse
      end
    end or [200, {'content-type' => 'text/html'}, ["Hello World"]] 
  end
end

run Application
