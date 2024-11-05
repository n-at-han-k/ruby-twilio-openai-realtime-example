#
# The purpose of this class is to handle the events from the 2 sockets
# and manage the communication between them both
#

require 'base64'

class Bridge

  # https://www.twilio.com/docs/voice/media-streams/websocket-messages
  TWILIO_EVENTS = [
    'start',
    'media',
    'mark'
  ]

  # https://platform.openai.com/docs/guides/realtime#events
  OPENAI_EVENTS = [
    'response.audio.delta',
    'input_audio_buffer.speech_started',
  ]

  def initialize(twilio, openai)
    # Websocket connection objects
    @twilio = twilio
    @openai = openai

    # Sending initial prompts
    @openai.initialize_session
    @openai.send_system_message
    @openai.get_response
  end

  def handle_twilio(message)
    begin
      event = message[:event]
      if TWILIO_EVENTS.include? event
        send('twilio_' + event.to_s, message)
      end
    # rescue
      # handle error here
    end
  end
  def handle_openai(message)
    begin
      event = message[:type]
      if OPENAI_EVENTS.include? event
        send('openai_' + event.gsub('.', '_'), message)
      end
    # rescue
      # handle error here
    end
  end

  private

  # -------------
  # Twilio EVENTS
  # -------------
  def twilio_start(message)
    @twilio.stream_sid = message[:start][:streamSid]
    # puts '--> [TWILIO] start'
    # puts message.inspect
  end
  def twilio_media(message)
    data = message[:media]
    @twilio.latest_media_timestamp = data[:timestamp]
    @openai.input_audio_buffer_append({
      type: 'input_audio_buffer.append',
      audio: data[:payload]
    })
    # puts '--> [TWILIO] media'
    # puts message.inspect
  end
  def twilio_mark(message)
    @twilio.mark_queue.pop(0) unless @twilio.mark_queue.empty?
    # puts '--> [TWILIO] mark'
    # puts message.inspect
  end

  # -------------
  # OpenAI EVENTS
  # -------------
  def openai_response_audio_delta(message)
    payload = message[:delta]
    @twilio.send_media(payload)
    if @openai.response_start_timestamp.nil?
      @openai.response_start_timestamp = @twilio.latest_media_timestamp
    end
    @openai.last_assistant_item = message[:item_id]
    @twilio.send_mark
  end
  def openai_input_audio_buffer_speech_started(message)
    if @openai.last_assistant_item != nil
      if @twilio.mark_queue and (@openai.response_start_timestamp != nil)
        elapsed_time = @twilio.latest_media_timestamp.to_i - @openai.response_start_timestamp.to_i
      end
      @openai.conversation_item_truncate(elapsed_time)
      @twilio.send_clear
      @openai.last_assistant_item = nil
      @openai.response_start_timestamp = nil
    end
  end
end
