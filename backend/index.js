const express = require('express')
const app = express()
const cors = require("cors")
const http = require('http')
const WebSocket = require('ws')
const PORT = 3000;

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

app.get('/', (req, res) => res.send('Hello World!'))

server.listen(PORT, () => console.log(`Lisening on port :${PORT}`))