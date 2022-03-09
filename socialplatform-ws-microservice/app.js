import { app, query, update, sparql, errorHandler } from 'mu';

import http from 'http';
import bodyParser from 'body-parser';
import { Server } from 'socket.io';
const server = http.createServer(app);
const io = new Server(server);

app.use(bodyParser.json({
    limit: '500mb',
    type: function(req) {
      return /^application\/json/.test(req.get('content-type'));
    },
  }));

function extractHeadline(triples){
  let result = triples.filter(triple => triple.predicate.value === 'https://schema.org/headline');
  if(result){
    return result[0];
  }
}

function extractBody(triples){
  let result = triples.filter(triple => triple.predicate.value === 'https://schema.org/articleBody');
  if(result){
    return result[0];
  }
}

app.get('/', (req, res) => {
  res.send('<h1>Hello world</h1>');
});

app.post('/posts', (req, res) => {
  req.body.forEach(operation => {
    let headlinetriple = extractHeadline(operation.inserts);
    console.log(operation.insrts)
    let bodytriple = extractBody(operation.inserts);
    if(headlinetriple && bodytriple){
      console.log(headlinetriple);
      io.emit("new post", {
        headline: headlinetriple.object.value,
        body: bodytriple.object.value
      })
    }
  })
})

io.on('connection', (socket) => {
  console.log('User connected')
})


app.use(errorHandler);

server.listen(3000, () => {
  console.log('listening on *:3000');
});