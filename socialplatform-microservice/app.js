import { app, query, update, sparql, errorHandler } from "mu";
import bodyParser from "body-parser";
import fetch from "node-fetch";

const APPLICATION_GRAPH = "http://mu.semte.ch/graphs/public";
app.use(
	bodyParser.json({
		limit: "500mb",
		type: function (req) {
			return /^application\/json/.test(req.get("content-type"));
		},
	})
);

function formatValue(tripleElement) {
	if (tripleElement.type == "uri") {
		return `<${tripleElement.value}>`;
	} else {
		return `"${tripleElement.value}"`;
	}
}

function toString(triple) {
	return `${formatValue(triple.subject)} ${formatValue(
		triple.predicate
	)} ${formatValue(triple.object)}.`;
}

function generateQuery(inserts, deletes) {
	let insertString = "";
	inserts.forEach((insert) => {
		insertString += toString(insert) + "\n";
	});
	let deleteString = "";
	deletes.forEach((deleteOp) => {
		deleteString += toString(deleteOp) + "\n";
	});

	if (insertString) {
		insertString = `INSERT {
            GRAPH <${APPLICATION_GRAPH}> {
                ${insertString}
            }
        }`;
	}
	if (deleteString) {
		deleteString = `
        DELETE {
            GRAPH <${APPLICATION_GRAPH}> {
                ${deleteString}
            }
        }`;
	}

	let queryStr = `
        ${deleteString}\n
        ${insertString}
    `;
	return queryStr;
}

app.post("/posts", function (req, res) {
	let inserts = [];
	let deletes = [];
	req.body.forEach((operation) => {
		operation.inserts.forEach((insert) => {
			inserts.push(insert);
		});
		operation.deletes.forEach((deleteOp) => {
			deletes.push(deleteOp);
		});
	});

	query(generateQuery(inserts, deletes))
		.then(function (response) {
			res.send(JSON.stringify(response));
		})
		.catch(function (err) {
			res.send("Oops something went wrong: " + JSON.stringify(err));
		});
});

async function sendLDESRequest(uri, body) {
	const queryParams = new URLSearchParams({
		resource: uri,
		stream: "http://example.org/post-stream",
		"relation-path": "https://schema.org/dateCreated",
		fragmenter: "time-fragmenter",
	});

	return fetch(
		"http://ldes-time-fragmenter:3000/social-media-posts?" + queryParams,
		{
			method: "POST",
			headers: {
				"Content-Type": "text/turtle",
			},
			body: body,
		}
	);
}

app.post("/posts-ldes", async function (req, res) {
	console.log("ldes");
	for (const operation of req.body) {
		let resource = operation.inserts;
		if (resource) {
			let subject = resource[0].subject.value;
			let turtleBody = "";
			resource.forEach((triple) => {
				turtleBody += toString(triple) + "\n";
			});
			let response = await sendLDESRequest(subject, turtleBody);
			console.log(response);
		}
	}
});

app.use(errorHandler);
