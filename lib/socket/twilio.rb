class Socket::Twilio < Async::WebSocket::Connection
  attr_accessor :stream_sid, :latest_media_timestamp, :mark_queue

  def initialize(*, **)
    super

    @stream_sid = nil
    @latest_media_timestamp = 0
    @mark_queue = []
  end

  def send_media(payload)
    message = Protocol::WebSocket::TextMessage.generate({
      event: 'media', 
      streamSid: @stream_sid,
      media: {
        payload: payload
      }
    })
    self.write message
    # puts '<-- [TWILIO] media'
    # puts message.parse
  end

  def send_mark
    if @stream_sid != nil
      message = Protocol::WebSocket::TextMessage.generate({
        event: 'mark',
        streamSid: @stream_sid,
        mark: {
          name: 'responsePart'
        }
      })
      self.write message
      @mark_queue.push.append('responsePart')
      # puts '<-- [TWILIO] mark'
      # puts message.parse
    end
  end

  def send_clear
    message = Protocol::WebSocket::TextMessage.generate({
      event: "clear",
      streamSid: @stream_sid
    })
    self.write message
    @mark_queue.clear

    # puts '<-- [TWILIO] clear'
    # puts message.parse
  end
end
