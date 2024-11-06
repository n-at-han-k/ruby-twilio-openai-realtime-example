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
You'll need to set up your twilio webhooks to point to your server.
If you're on a local dev machine then you can use NGrok to connect your localhost to a public url.
```
ngrok http localhost:9292
```

### Twilio Dev Phone
Twilio provide a brilliant application called [dev phone](https://github.com/twilio-labs/dev-phone) for testing calling numbers using your web browser.
Install the [Twilio CLI](https://www.twilio.com/docs/twilio-cli/getting-started/install).
Then run the following command:

```sh
twilio dev-phone
```
