class Socket::Twilio < Async::WebSocket::Connection
  attr_reader :stream_sid, :latest_media_timestamp

  def initialize(*, **)
    super

    @stream_sid = nil
    @latest_media_timestamp = nil
  end

  def connected_event(message)
  end

  def start_event(message)
  end

  def mark_event(message)
  end

  def media_event(message)
  end
end
