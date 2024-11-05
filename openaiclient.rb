require 'async'
require 'async/http/endpoint'
require 'async/websocket/client'
require 'dotenv'
Dotenv.load

url = 'wss://api.openai.com/v1/realtime'
query = '?model=gpt-4o-realtime-preview-2024-10-01'
headers = [
  ["Authorization", "Bearer #{ENV['OPENAI_API_KEY']}"],
  ["OpenAI-Beta", "realtime=v1"]
]


#URL = "wss://stream.binance.com:9443/ws/btcusdt@bookTicker"
URL = url + query

Async do |task|
	endpoint = Async::HTTP::Endpoint.parse(URL, alpn_protocols: Async::HTTP::Protocol::HTTP11.names)
	
	Async::WebSocket::Client.connect(endpoint, headers: headers) do |connection|
		while message = connection.read
			$stdout.puts message.parse
		end
	end
end
