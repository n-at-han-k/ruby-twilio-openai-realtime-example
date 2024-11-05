class Socket::Twilio < Async::WebSocket::Connection
  attr_reader :stream_sid, :latest_media_timestamp

  def initialize(*, **)
    super

    @stream_sid = nil
    @latest_media_timestamp = nil
  end
end
