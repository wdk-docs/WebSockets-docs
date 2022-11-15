
Socket
======

A ``Socket`` is the fundamental class for interacting with browser
clients. A ``Socket`` belongs to a certain ``Namespace`` (by default
``/``) and uses an underlying ``Client`` to communicate.

It should be noted the ``Socket`` doesn’t relate directly to the actual
underlying TCP/IP ``socket`` and it is only the name of the class.

Within each ``Namespace``, you can also define arbitrary channels
(called ``room``) that the ``Socket`` can join and leave. That provides
a convenient way to broadcast to a group of ``Socket``\ s (see
``Socket#to`` below).

The ``Socket`` class inherits from
`EventEmitter <https://nodejs.org/api/events.html#events_class_eventemitter>`_.
The ``Socket`` class overrides the ``emit`` method, and does not modify
any other ``EventEmitter`` method. All methods documented here which
also appear as ``EventEmitter`` methods (apart from ``emit``) are
implemented by ``EventEmitter``, and documentation for ``EventEmitter``
applies.

.. attribute:: socket.id

-  *(String)*

A unique identifier for the session, that comes from the underlying
``Client``.

.. attribute:: socket.rooms

-  *(Object)*

A hash of strings identifying the rooms this client is in, indexed by
room name.

.. code:: js

   io.on('connection', (socket) => {
     socket.join('room 237', () => {
       let rooms = Object.keys(socket.rooms);
       console.log(rooms); // [ <socket.id>, 'room 237' ]
     });
   });

.. attribute:: socket.client

-  *(Client)*

A reference to the underlying ``Client`` object.

.. attribute:: socket.conn

-  *(engine.Socket)*

A reference to the underlying ``Client`` transport connection (engine.io
``Socket`` object). This allows access to the IO transport layer, which
still (mostly) abstracts the actual TCP/IP socket.

.. attribute:: socket.request

-  *(Request)*

A getter proxy that returns the reference to the ``request`` that
originated the underlying engine.io ``Client``. Useful for accessing
request headers such as ``Cookie`` or ``User-Agent``.

.. attribute:: socket.handshake

-  *(Object)*

The handshake details:

.. code:: js

   {
     headers: /* the headers sent as part of the handshake */,
     time: /* the date of creation (as string) */,
     address: /* the ip of the client */,
     xdomain: /* whether the connection is cross-domain */,
     secure: /* whether the connection is secure */,
     issued: /* the date of creation (as unix timestamp) */,
     url: /* the request URL string */,
     query: /* the query object */
   }

Usage:

.. code:: js

   io.use((socket, next) => {
     let handshake = socket.handshake;
     // ...
   });

   io.on('connection', (socket) => {
     let handshake = socket.handshake;
     // ...
   });

.. attribute:: socket.use(fn)

-  ``fn`` *(Function)*

Registers a middleware, which is a function that gets executed for every
incoming ``Packet`` and receives as parameter the packet and a function
to optionally defer execution to the next registered middleware.

Errors passed to middleware callbacks are sent as special ``error``
packets to clients.

.. code:: js

   io.on('connection', (socket) => {
     socket.use((packet, next) => {
       if (packet.doge === true) return next();
       next(new Error('Not a doge error'));
     });
   });

.. attribute:: socket.send([…args][, ack])


-  ``args``
-  ``ack`` *(Function)*
-  **Returns** ``Socket``

Sends a ``message`` event. See `socket.emit(eventName[, …args][,
ack]) <#socketemiteventname-args-ack>`_.

.. attribute:: socket.emit(eventName[, …args][, ack])

*(overrides ``EventEmitter.emit``)* - ``eventName`` *(String)* -
``args`` - ``ack`` *(Function)* - **Returns** ``Socket``

Emits an event to the socket identified by the string name. Any other
parameters can be included. All serializable datastructures are
supported, including ``Buffer``.

.. code:: js

   socket.emit('hello', 'world');
   socket.emit('with-binary', 1, '2', { 3: '4', 5: new Buffer(6) });

The ``ack`` argument is optional and will be called with the client’s
answer.

.. code:: js

   io.on('connection', (socket) => {
     socket.emit('an event', { some: 'data' });

     socket.emit('ferret', 'tobi', (data) => {
       console.log(data); // data will be 'woot'
     });

     // the client code
     // client.on('ferret', (name, fn) => {
     //   fn('woot');
     // });

   });

.. attribute:: socket.on(eventName, callback)

*(inherited from ``EventEmitter``)* - ``eventName`` *(String)* -
``callback`` *(Function)* - **Returns** ``Socket``

Register a new handler for the given event.

.. code:: js

   socket.on('news', (data) => {
     console.log(data);
   });
   // with several arguments
   socket.on('news', (arg1, arg2, arg3) => {
     // ...
   });
   // or with acknowledgement
   socket.on('news', (data, callback) => {
     callback(0);
   });

.. attribute:: socket.once(eventName, listener)


.. attribute:: socket.removeListener(eventName, listener)


.. attribute:: socket.removeAllListeners([eventName])

.. attribute:: socket.eventNames()

Inherited from ``EventEmitter`` (along with other methods not mentioned
here). See Node.js documentation for the ``events`` module.

.. attribute:: socket.join(room[, callback])

-  ``room`` *(String)*
-  ``callback`` *(Function)*
-  **Returns** ``Socket`` for chaining

Adds the client to the ``room``, and fires optionally a callback with
``err`` signature (if any).

.. code:: js

   io.on('connection', (socket) => {
     socket.join('room 237', () => {
       let rooms = Object.keys(socket.rooms);
       console.log(rooms); // [ <socket.id>, 'room 237' ]
       io.to('room 237').emit('a new user has joined the room'); // broadcast to everyone in the room
     });
   });

The mechanics of joining rooms are handled by the ``Adapter`` that has
been configured (see ``Server#adapter`` above), defaulting to
`socket.io-adapter <https://github.com/socketio/socket.io-adapter>`_.

For your convenience, each socket automatically joins a room identified
by its id (see ``Socket#id``). This makes it easy to broadcast messages
to other sockets:

.. code:: js

   io.on('connection', (socket) => {
     socket.on('say to someone', (id, msg) => {
       // send a private message to the socket with the given id
       socket.to(id).emit('my message', msg);
     });
   });

.. attribute:: socket.join(rooms[, callback])

-  ``rooms`` *(Array)*
-  ``callback`` *(Function)*
-  **Returns** ``Socket`` for chaining

Adds the client to the list of room, and fires optionally a callback
with ``err`` signature (if any).

.. attribute:: socket.leave(room[, callback])

-  ``room`` *(String)*
-  ``callback`` *(Function)*
-  **Returns** ``Socket`` for chaining

Removes the client from ``room``, and fires optionally a callback with
``err`` signature (if any).

**Rooms are left automatically upon disconnection**.

.. attribute:: socket.to(room)

-  ``room`` *(String)*
-  **Returns** ``Socket`` for chaining

Sets a modifier for a subsequent event emission that the event will only
be *broadcasted* to clients that have joined the given ``room`` (the
socket itself being excluded).

To emit to multiple rooms, you can call ``to`` several times.

.. code:: js

   io.on('connection', (socket) => {

     // to one room
     socket.to('others').emit('an event', { some: 'data' });

     // to multiple rooms
     socket.to('room1').to('room2').emit('hello');

     // a private message to another socket
     socket.to(/* another socket id */).emit('hey');

     // WARNING: `socket.to(socket.id).emit()` will NOT work, as it will send to everyone in the room
     // named `socket.id` but the sender. Please use the classic `socket.emit()` instead.
   });

.. note:: acknowledgements are not supported when broadcasting.

.. attribute:: socket.in(room)

Synonym of `socket.to(room) <#socket-to-room>`_.

.. attribute:: socket.compress(value)

-  ``value`` *(Boolean)* whether to following packet will be compressed
-  **Returns** ``Socket`` for chaining

Sets a modifier for a subsequent event emission that the event data will
only be *compressed* if the value is ``true``. Defaults to ``true`` when
you don’t call the method.

.. code:: js

   io.on('connection', (socket) => {
     socket.compress(false).emit('uncompressed', "that's rough");
   });

.. attribute:: socket.disconnect(close)

-  ``close`` *(Boolean)* whether to close the underlying connection
-  **Returns** ``Socket``

Disconnects this client. If value of close is ``true``, closes the
underlying connection. Otherwise, it just disconnects the namespace.

.. code:: js

   io.on('connection', (socket) => {
     setTimeout(() => socket.disconnect(true), 5000);
   });

.. attribute:: Flag.broadcast

Sets a modifier for a subsequent event emission that the event data will
only be *broadcast* to every sockets but the sender.

.. code:: js

   io.on('connection', (socket) => {
     socket.broadcast.emit('an event', { some: 'data' }); // everyone gets it but the sender
   });

.. _flag-volatile-1:

.. attribute:: Flag.volatile

Sets a modifier for a subsequent event emission that the event data may
be lost if the client is not ready to receive messages (because of
network slowness or other issues, or because they’re connected through
long polling and is in the middle of a request-response cycle).

.. code:: js

   io.on('connection', (socket) => {
     socket.volatile.emit('an event', { some: 'data' }); // the client may or may not receive it
   });

.. _flag-binary-1:

.. attribute:: Flag.binary

Specifies whether there is binary data in the emitted data. Increases
performance when specified. Can be ``true`` or ``false``.

.. code:: js

   var io = require('socket.io')();
   io.on('connection', function(socket){
     socket.binary(false).emit('an event', { some: 'data' }); // The data to send has no binary data
   });

.. attribute:: Event.disconnect

-  ``reason`` *(String)* the reason of the disconnection (either client
   or server-side)

Fired upon disconnection.

.. code:: js

   io.on('connection', (socket) => {
     socket.on('disconnect', (reason) => {
       // ...
     });
   });

Possible reasons:

+------------------+-------------+-------------------------------------+
|      Reason      |    Side     |             Description             |
+==================+=============+=====================================+
| ``transport err  | Server Side | Transport error                     |
| or``             |             |                                     |
+------------------+-------------+-------------------------------------+
| ``server namesp  | Server Side | Server performs a                   |
| ace disconnect`` |             | ``socket.disconnect()``             |
|                  |             |                                     |
+------------------+-------------+-------------------------------------+
| ``client namesp  | Client Side | Got disconnect packet from client   |
| ace disconnect`` |             |                                     |
|                  |             |                                     |
+------------------+-------------+-------------------------------------+
| ``ping timeout`` | Client Side | Client stopped responding to pings  |
|                  |             | in the allowed amount of time (per  |
|                  |             | the ``pingTimeout`` config setting) |
+------------------+-------------+-------------------------------------+
| ``transport clo  | Client Side | Client stopped sending data         |
| se``             |             |                                     |
+------------------+-------------+-------------------------------------+

.. attribute:: Event.error


-  ``error`` *(Object)* error object

Fired when an error occurs.

.. code:: js

   io.on('connection', (socket) => {
     socket.on('error', (error) => {
       // ...
     });
   });

.. attribute:: Event.disconnecting

-  ``reason`` *(String)* the reason of the disconnection (either client
   or server-side)

Fired when the client is going to be disconnected (but hasn’t left its
``rooms`` yet).

.. code:: js

   io.on('connection', (socket) => {
     socket.on('disconnecting', (reason) => {
       let rooms = Object.keys(socket.rooms);
       // ...
     });
   });

These are reserved events (along with ``connect``, ``newListener`` and
``removeListener``) which cannot be used as event names.


