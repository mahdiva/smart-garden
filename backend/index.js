const express = require('express')
const app = express()
const cors = require("cors")
const http = require('http')
const WebSocket = require('ws')
const PORT = 80;

app.use(
    cors({
        origin: "*"
    })
)

const server = http.createServer(app);
const wss = new WebSocket.Server({ server: server });

wss.on('connection', function (ws) {
    console.log('A new client connected');

    ws.on('message', function (message) {
        console.log(`Received: ${message.toString()}`);

        wss.clients.forEach(function each(client) {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(message.toString());
            }
        });
    });

    ws.on("close", () => {
        console.log("The client has disconnected");
    });

    ws.onerror = function () {
        console.log("Some error occurred")
    }
});

app.get('/', (req, res) => res.send('Hello World!'));

app.get('/led-on', (req, res) => {
    const ws = new WebSocket("ws://127.0.0.1");
    setTimeout(() => {
        ws.send('{"action": "led_toggle", "state": 1}');
        res.send('LED ON');
    }, 100);
});

app.get('/led-off', (req, res) => {
    const ws = new WebSocket("ws://127.0.0.1");
    setTimeout(() => {
        ws.send('{"action": "led_toggle", "state": 0}');
        res.send('LED OFF');
    }, 100);
});

app.get('/window-open', (req, res) => {
    const ws = new WebSocket("ws://127.0.0.1");
    setTimeout(() => {
        ws.send('{"action": "window_toggle", "state": 1}');
        res.send('WINDOW OPEN');
    }, 100);
});

app.get('/window-closed', (req, res) => {
    const ws = new WebSocket("ws://127.0.0.1");
    setTimeout(() => {
        ws.send('{"action": "window_toggle", "state": 0}');
        res.send('WINDOW CLOSED');
    }, 100);
});

app.get('/shower', (req, res) => {
    const ws = new WebSocket("ws://127.0.0.1");
    setTimeout(() => {
        ws.send('{"action": "shower"}');
        res.send('SHOWER');
    }, 100);
});

server.listen(PORT, () => console.log(`Lisening on port :${PORT}`))