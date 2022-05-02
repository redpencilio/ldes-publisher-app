import { app, query, update, sparql, errorHandler } from "mu";
import { WebSocketServer, WebSocket } from "ws";
import http from "http";
import bodyParser from "body-parser";
const server = http.createServer(app);
//TODO: Disable origin: * once running on the same port!
const wss = new WebSocketServer({ server });

app.use(
	bodyParser.json({
		limit: "500mb",
		type: function (req) {
			return /^application\/json/.test(req.get("content-type"));
		},
	})
);

function extractHeadline(triples) {
	let result = triples.filter(
		(triple) => triple.predicate.value === "https://schema.org/headline"
	);
	if (result) {
		return result[0];
	}
}

function extractBody(triples) {
	let result = triples.filter(
		(triple) => triple.predicate.value === "https://schema.org/articleBody"
	);
	if (result) {
		return result[0];
	}
}

function extractUuid(triples) {
	let result = triples.filter(
		(triple) =>
			triple.predicate.value ===
			"http://mu.semte.ch/vocabularies/core/uuid"
	);
	if (result) {
		return result[0];
	}
}

app.get("/", (req, res) => {
	res.send("<h1>Hello world</h1>");
});

app.post("/posts", (req, res) => {
	console.log("ws");
	req.body.forEach((operation) => {
		console.log(operation.inserts);
		let uuidTriple = extractUuid(operation.inserts);
		// let headlinetriple = extractHeadline(operation.inserts);
		// let bodytriple = extractBody(operation.inserts);
		if (uuidTriple) {
			wss.clients.forEach((client) => {
				if (client.readyState === WebSocket.OPEN) {
					client.send(
						JSON.stringify({
							uuid: uuidTriple.object.value,
						})
					);
				}
			});
		}
	});
});

wss.on("connection", (socket) => {
	console.log("User connected");
});

app.use(errorHandler);

server.listen(3000, () => {
	console.log("listening on *:3000");
});
