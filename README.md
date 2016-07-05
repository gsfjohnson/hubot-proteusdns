# hubot-proteusdns

Hubot plugin to interact with proteus dns.

## Installation

Add **hubot-proteusdns** to your `package.json` file:

```javascript
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-proteusdns": "*"
}
```

Add **hubot-proteusdns** to your `external-scripts.json`:

```javascript
["hubot-proteusdns"]
```

Run `npm install`

## Usage

Assuming your hubot instance is called `hubot`, you can instruct it to relay a message as follows:

`hubot: pdns search <keyword>`

Proteus will be queried and when available the results will be provided.


## Configuration

It is necessary to procure an api username and password from your proteus administrator. Once obtained, set the `HUBOT_PROTEUSDNS_URL`, `HUBOT_PROTEUSDNS_USER`, and `HUBOT_PROTEUSDNS_PASS` environment variables.

