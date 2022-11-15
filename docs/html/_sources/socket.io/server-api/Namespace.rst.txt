Namespace
=========

Represents a pool of sockets connected under a given scope identified by a pathname (eg: ``/chat``).

A client always connects to ``/`` (the main namespace), then potentially
connect to other namespaces (while using the same underlying
connection).

For the how and why, please take a look at: `Rooms and Namespaces </docs/rooms-and-namespaces/>`_.

.. attribute:: namespace.name

   -  *(String)*

   The namespace identifier property.

.. attribute:: namespace.connected

   -  *(Object)*

   The hash of ``Socket`` objects that are connected to this namespace, indexed by ``id``.

.. attribute:: namespace.adapter

   -  *(Adapter)*

   The ``Adapter`` used for the namespace. Useful when using the
   ``Adapter`` based on `Redis <https://github.com/socketio/socket.io-redis>`_,
   as it exposes methods to manage sockets and rooms accross your cluster.

   .. note:: the adapter of the main namespace can be accessed with ``io.of('/').adapter``.

.. attribute:: namespace.to(room)

   -  ``room`` *(String)*
   -  **Returns** ``Namespace`` for chaining

   Sets a modifier for a subsequent event emission that the event will only
   be *broadcasted* to clients that have joined the given ``room``.

   To emit to multiple rooms, you can call ``to`` several times.

   .. code:: js

      const io = require('socket.io')();
      const adminNamespace = io.of('/admin');

      adminNamespace.to('level1').emit('an event', { some: 'data' });

.. attribute:: namespace.in(room)

   Synonym of `namespace.to(room) <#namespace-to-room>`_.

   .. attribute:: namespace.emit(eventName[, …args])

   -  ``eventName`` *(String)*
   -  ``args``

   Emits an event to all connected clients. The following two are
   equivalent:

   .. code:: js

      const io = require('socket.io')();
      io.emit('an event sent to all connected clients'); // main namespace

      const chat = io.of('/chat');
      chat.emit('an event sent to all connected clients in chat namespace');

   .. note:: acknowledgements are not supported when emitting from namespace.

.. attribute:: namespace.clients(callback)

   -  ``callback`` *(Function)*

   Gets a list of client IDs connected to this namespace (across all nodes if applicable).

   .. code:: js

      const io = require('socket.io')();
      io.of('/chat').clients((error, clients) => {
        if (error) throw error;
        console.log(clients); // => [PZDoMHjiu8PYfRiKAAAF, Anw2LatarvGVVXEIAAAD]
      });

   An example to get all clients in namespace’s room:

   .. code:: js

      io.of('/chat').in('general').clients((error, clients) => {
        if (error) throw error;
        console.log(clients); // => [Anw2LatarvGVVXEIAAAD]
      });

   As with broadcasting, the default is all clients from the default
   namespace (‘/’):

   .. code:: js

      io.clients((error, clients) => {
        if (error) throw error;
        console.log(clients); // => [6em3d4TJP8Et9EMNAAAA, G5p55dHhGgUnLUctAAAB]
      });

.. attribute:: namespace.use(fn)

   -  ``fn`` *(Function)*

   Registers a middleware, which is a function that gets executed for every
   incoming ``Socket``, and receives as parameters the socket and a
   function to optionally defer execution to the next registered
   middleware.

   Errors passed to middleware callbacks are sent as special ``error``
   packets to clients.

   .. code:: js

      io.use((socket, next) => {
        if (socket.request.headers.cookie) return next();
        next(new Error('Authentication error'));
      });

.. function:: Event.connect

   -  ``socket`` *(Socket)* socket connection with client

   Fired upon a connection from client.

   .. code:: js

      io.on('connect', (socket) => {
        // ...
      });

      io.of('/admin').on('connect', (socket) => {
        // ...
      });

.. function:: Event.connection

   Synonym of `Event: ‘connect’ <#Event-‘connect’>`_.

.. function:: Flag.volatile

   Sets a modifier for a subsequent event emission that the event data may
   be lost if the clients are not ready to receive messages (because of
   network slowness or other issues, or because they’re connected through
   long polling and is in the middle of a request-response cycle).

   .. code:: js

      io.volatile.emit('an event', { some: 'data' }); // the clients may or may not receive it

.. function:: Flag.binary

   Specifies whether there is binary data in the emitted data.
   Increases performance when specified. Can be ``true`` or ``false``.

   .. code:: js

      io.binary(false).emit('an event', { some: 'data' });

.. function:: Flag.local

   Sets a modifier for a subsequent event emission that the event data will only be *broadcast* to the current node
   (when the `Redis adapter <https://github.com/socketio/socket.io-redis>`_ is used).

   .. code:: js

      io.local.emit('an event', { some: 'data' });
