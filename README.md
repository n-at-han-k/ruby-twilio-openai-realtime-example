# Ruby Twilio OpenAI Realtime Example

This is an example Rack server demonstrate bi-directional asynchronous streaming in ruby using websockets.
We use the [falcon](https://github.com/socketry/falcon) server and the [asyc](https://github.com/socketry/async) gem.

## Setup
Add your OpenAI API key to the `.env` file.
```sh
OPENAI_API_KEY=abcdefghijklexample
HOST=example.ngrok.com
```
Then run 
```sh
bin/server
```

### Twilio Dev Phone
Twilio provide a brilliant application called [dev phone](https://github.com/twilio-labs/dev-phone) for testing calling numbers using your web browser.
You'll need a paid twilio number.
Install the [Twilio CLI](https://www.twilio.com/docs/twilio-cli/getting-started/install).
Then run the following command:

````sh
twilio dev-phone
```
