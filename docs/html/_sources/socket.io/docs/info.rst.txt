introduce
===========

What Socket.IO is
-----------------

Socket.IO is a library that enables real-time, bidirectional and
event-based communication between the browser and the server. It
consists of:

-  a Node.js server: `Source <https://github.com/socketio/socket.io>`_
   \| `API </docs/server-api/>`_
-  a Javascript client library for the browser (which can be also run
   from Node.js):
   `Source <https://github.com/socketio/socket.io-client>`_ \|
   `API </docs/client-api/>`_

Its main features are:

Reliability
~~~~~~~~~~~

Connections are established even in the presence of:

-  proxies and load balancers.
-  personal firewall and antivirus software.

For this purpose, it relies on
`Engine.IO <https://github.com/socketio/engine.io>`_, which first
establishes a long-polling connection, then tries to upgrade to better
transports that are “tested” on the side, like WebSocket. Please see the
`Goals <https://github.com/socketio/engine.io#goals>`_ section for more
information.

Auto-reconnection support
~~~~~~~~~~~~~~~~~~~~~~~~~

Unless instructed otherwise a disconnected client will try to reconnect
forever, until the server is available again. Please see the available
reconnection options
`here <https://socket.io/docs/client-api/#new-Manager-url-options>`_.

Disconnection detection
~~~~~~~~~~~~~~~~~~~~~~~

A heartbeat mechanism is implemented at the Engine.IO level, allowing
both the server and the client to know when the other one is not
responding anymore.

That functionality is achieved with timers set on both the server and
the client, with timeout values (the pingInterval and pingTimeout
parameters) shared during the connection handshake. Those timers require
any subsequent client calls to be directed to the same server, hence the
sticky-session requirement when using multiples nodes.

Binary support
~~~~~~~~~~~~~~

Any serializable data structures can be emitted, including:

-  `ArrayBuffer <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer>`_
   and `Blob <https://developer.mozilla.org/en-US/docs/Web/API/Blob>`_
   in the browser
-  `ArrayBuffer <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer>`_
   and `Buffer <https://nodejs.org/api/buffer.html>`_ in Node.js

Multiplexing support
~~~~~~~~~~~~~~~~~~~~

In order to create separation of concerns within your application (for
example per module, or based on permissions), Socket.IO allows you to
create several `Namespaces </docs/rooms-and-namespaces/#Namespaces>`_,
which will act as separate communication channels but will share the
same underlying connection.

Room support
~~~~~~~~~~~~

Within each `Namespace </docs/rooms-and-namespaces/#Namespaces>`_, you
can define arbitrary channels, called
`Rooms </docs/rooms-and-namespaces/#Rooms>`_, that sockets can join and
leave. You can then broadcast to any given room, reaching every socket
that has joined it.

This is a useful feature to send notifications to a group of users, or
to a given user connected on several devices for example.

Those features come with a simple and convenient API, which looks like
the following:

.. code:: js

   io.on('connection', function(socket){
     socket.emit('request', /* */); // emit an event to the socket
     io.emit('broadcast', /* */); // emit an event to all connected sockets
     socket.on('reply', function(){ /* */ }); // listen to the event
   });

What Socket.IO is not
---------------------

Socket.IO is **NOT** a WebSocket implementation. Although Socket.IO
indeed uses WebSocket as a transport when possible, it adds some
metadata to each packet: the packet type, the namespace and the ack id
when a message acknowledgement is needed. That is why a WebSocket client
will not be able to successfully connect to a Socket.IO server, and a
Socket.IO client will not be able to connect to a WebSocket server
either. Please see the protocol specification
`here <https://github.com/socketio/socket.io-protocol>`_.

.. code:: js

   // WARNING: the client will NOT be able to connect!
   const client = io('ws://echo.websocket.org');

Installing
----------

Server
~~~~~~

.. code:: sh

   npm install --save socket.io

`Source <https://github.com/socketio/socket.io>`_

Javascript Client
~~~~~~~~~~~~~~~~~

A standalone build of the client is exposed by default by the server at
``/socket.io/socket.io.js``.

It can also be served from a CDN, like
`cdnjs <https://cdnjs.com/libraries/socket.io>`_.

To use it from Node.js, or with a bundler like
`webpack <https://webpack.js.org/>`_ or
`browserify <http://browserify.org/>`_, you can also install the
package from npm:

.. code:: sh

   npm install --save socket.io-client

`Source <https://github.com/socketio/socket.io-client>`_

Other client implementations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are several client implementations in other languages, which are
maintained by the community:

-  Java: https://github.com/socketio/socket.io-client-java
-  C++: https://github.com/socketio/socket.io-client-cpp
-  Swift: https://github.com/socketio/socket.io-client-swift
-  Dart: https://github.com/rikulo/socket.io-client-dart
-  Python: https://github.com/miguelgrinberg/python-socketio
-  .Net: https://github.com/Quobject/SocketIoClientDotNet

Using with Node http server
---------------------------

Server (app.js)
~~~~~~~~~~~~~~~

.. code:: js

   var app = require('http').createServer(handler)
   var io = require('socket.io')(app);
   var fs = require('fs');

   app.listen(80);

   function handler (req, res) {
     fs.readFile(__dirname + '/index.html',
     function (err, data) {
       if (err) {
         res.writeHead(500);
         return res.end('Error loading index.html');
       }

       res.writeHead(200);
       res.end(data);
     });
   }

   io.on('connection', function (socket) {
     socket.emit('news', { hello: 'world' });
     socket.on('my other event', function (data) {
       console.log(data);
     });
   });

Client (index.html)
~~~~~~~~~~~~~~~~~~~

.. code:: html

   <script src="/socket.io/socket.io.js"></script>
   <script>
     var socket = io('http://localhost');
     socket.on('news', function (data) {
       console.log(data);
       socket.emit('my other event', { my: 'data' });
     });
   </script>

Using with Express
--------------------------

Server (app.js)
~~~~~~~~~~~~~~~

.. code:: js

   var app = require('express')();
   var server = require('http').Server(app);
   var io = require('socket.io')(server);

   server.listen(80);
   // WARNING: app.listen(80) will NOT work here!

   app.get('/', function (req, res) {
     res.sendFile(__dirname + '/index.html');
   });

   io.on('connection', function (socket) {
     socket.emit('news', { hello: 'world' });
     socket.on('my other event', function (data) {
       console.log(data);
     });
   });

.. _client-index.html-1:

Client (index.html)
~~~~~~~~~~~~~~~~~~~

.. code:: html

   <script src="/socket.io/socket.io.js"></script>
   <script>
     var socket = io.connect('http://localhost');
     socket.on('news', function (data) {
       console.log(data);
       socket.emit('my other event', { my: 'data' });
     });
   </script>

Sending and receiving events
----------------------------

Socket.IO allows you to emit and receive custom events. Besides
``connect``, ``message`` and ``disconnect``, you can emit custom events:

.. _server-1:

Server
~~~~~~

.. code:: js

   // note, io(<port>) will create a http server for you
   var io = require('socket.io')(80);

   io.on('connection', function (socket) {
     io.emit('this', { will: 'be received by everyone'});

     socket.on('private message', function (from, msg) {
       console.log('I received a private message by ', from, ' saying ', msg);
     });

     socket.on('disconnect', function () {
       io.emit('user disconnected');
     });
   });

Restricting yourself to a namespace
-----------------------------------

If you have control over all the messages and events emitted for a
particular application, using the default / namespace works. If you want
to leverage 3rd-party code, or produce code to share with others,
socket.io provides a way of namespacing a socket.

This has the benefit of ``multiplexing`` a single connection. Instead of
socket.io using two ``WebSocket`` connections, it’ll use one.

.. _server-app.js-2:

Server (app.js)
~~~~~~~~~~~~~~~

.. code:: js

   var io = require('socket.io')(80);
   var chat = io
     .of('/chat')
     .on('connection', function (socket) {
       socket.emit('a message', {
           that: 'only'
         , '/chat': 'will get'
       });
       chat.emit('a message', {
           everyone: 'in'
         , '/chat': 'will get'
       });
     });

   var news = io
     .of('/news')
     .on('connection', function (socket) {
       socket.emit('item', { news: 'item' });
     });

Client (index.html)
~~~~~~~~~~~~~~~~~~~~~

.. code:: html

   <script>
     var chat = io.connect('http://localhost/chat')
       , news = io.connect('http://localhost/news');

     chat.on('connect', function () {
       chat.emit('hi!');
     });

     news.on('news', function () {
       news.emit('woot');
     });
   </script>

Sending volatile messages
-------------------------

Sometimes certain messages can be dropped. Let’s say you have an app
that shows realtime tweets for the keyword ``bieber``.

If a certain client is not ready to receive messages (because of network
slowness or other issues, or because they’re connected through long
polling and is in the middle of a request-response cycle), if it doesn’t
receive ALL the tweets related to bieber your application won’t suffer.

In that case, you might want to send those messages as volatile
messages.

**Server**

.. code:: js

   var io = require('socket.io')(80);

   io.on('connection', function (socket) {
     var tweets = setInterval(function () {
       getBieberTweet(function (tweet) {
         socket.volatile.emit('bieber tweet', tweet);
       });
     }, 100);

     socket.on('disconnect', function () {
       clearInterval(tweets);
     });
   });

Sending and getting data (acknowledgements)
-------------------------------------------

Sometimes, you might want to get a callback when the client confirmed
the message reception.

To do this, simply pass a function as the last parameter of ``.send`` or
``.emit``. What’s more, when you use ``.emit``, the acknowledgement is
done by you, which means you can also pass data along:

.. _server-app.js-3:

Server (app.js)
~~~~~~~~~~~~~~~

.. code:: js

   var io = require('socket.io')(80);

   io.on('connection', function (socket) {
     socket.on('ferret', function (name, word, fn) {
       fn(name + ' says ' + word);
     });
   });

.. _client-index.html-2:

Client (index.html)
~~~~~~~~~~~~~~~~~~~

.. code:: html

   <script>
     var socket = io(); // TIP: io() with no args does auto-discovery
     socket.on('connect', function () { // TIP: you can avoid listening on `connect` and listen on events directly too!
       socket.emit('ferret', 'tobi', 'woot', function (data) { // args are sent in order to acknowledgement function
         console.log(data); // data will be 'tobi says woot'
       });
     });
   </script>

Broadcasting messages
---------------------

To broadcast, simply add a ``broadcast`` flag to ``emit`` and ``send``
method calls. Broadcasting means sending a message to everyone else
except for the socket that starts it.

.. _server-2:

Server
~~~~~~

.. code:: js

   var io = require('socket.io')(80);

   io.on('connection', function (socket) {
     socket.broadcast.emit('user connected');
   });

Using it just as a cross-browser WebSocket
------------------------------------------

If you just want the WebSocket semantics, you can do that too. Simply
leverage ``send`` and listen on the ``message`` event:

Server (app.js)
~~~~~~~~~~~~~~~

.. code:: js

   var io = require('socket.io')(80);

   io.on('connection', function (socket) {
     socket.on('message', function () { });
     socket.on('disconnect', function () { });
   });

Client (index.html)
~~~~~~~~~~~~~~~~~~~

.. code:: html

   <script>
     var socket = io('http://localhost/');
     socket.on('connect', function () {
       socket.send('hi');

       socket.on('message', function (msg) {
         // my msg
       });
     });
   </script>

If you don’t care about reconnection logic and such, take a look at
Engine.IO, which is the WebSocket semantics transport layer Socket.IO
uses.
