const http = require('http');

const hostname = '192.168.1.146';// '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  // res.end('Hello World\n');

  // console.log('try req=%s', req);

  let theParams = splitParams(req);

  console.log(theParams);

  if (typeof theParams !== 'undefined') {
  	let mid = theParams['mid'];

  	if (typeof mid !== 'undefined') {
  		getFirebaseCustomToken(res, mid);
  	}
  }

});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});

var admin = require("firebase-admin");

initFirebase();

function initFirebase() {
	var serviceAccount = require("./chat-e9a53-firebase-adminsdk-4jfyn-0dc966850f.json");

	admin.initializeApp({
  		credential: admin.credential.cert(serviceAccount),
  		databaseURL: "https://chat-e9a53.firebaseio.com"
	});
}

function getFirebaseCustomToken(res, mid) {
	// console.log(mid);
	admin.auth().createCustomToken(mid)
	.then(function(customToken){
		console.log(customToken);
		res.end(customToken);
	})
	.catch(function(error) {
		console.log('Error creating custom token:', error);
	});
}

var splitParams = function(req) {
	let q = req.url.split('?'), result = {};
	if (q.length >= 2) {
		q[1].split('&').forEach((item) => {
			try {
				result[item.split('=')[0]] = item.split('=')[1];
			} catch (e) {
				result[item.split('=')[0]] = '';
			}
		})
	}
	return result;
}
