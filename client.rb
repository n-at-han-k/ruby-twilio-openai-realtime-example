url = 'https://nathank.ngrok.pizza'
headers = [
  ["Authorization", "Bearer #{ENV['OPENAI_API_KEY']}"],
  ["OpenAI-Beta", "realtime=v1"]
]

require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'

USER = ARGV.pop || "anonymous"
URL = url 
#URL = "http://localhost:9292"

Async do |task|
  # Work around for NGrok fake http2
  #endpoint = Async::HTTP::Endpoint.parse(URL)
  endpoint = Async::HTTP::Endpoint.parse(URL, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
	
	Async::WebSocket::Client.connect(endpoint) do |connection|
		input_task = task.async do
			while line = $stdin.gets
				connection.write({user: USER, text: line})
				connection.flush
			end
		end
		
		# Generate a text message by geneating a JSON payload from a hash:
		connection.write(Protocol::WebSocket::TextMessage.generate({
			user: USER,
			status: "connected",
		}))
		
		while message = connection.read
			puts message.inspect
		end
	ensure
		input_task&.stop
	end
end
