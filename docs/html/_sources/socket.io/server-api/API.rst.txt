Server API
===============

Exposed by ``require('socket.io')``.

.. class:: new Server(httpServer[, options])

   Works with and without ``new``:

   :param http.Server httpServer: he server to bind to.
   :param Object options:

   :Example:

    .. code:: js

        const io = require('socket.io')();
        // or
        const Server = require('socket.io');
        const io = new Server();

   Available options:

   +-------------+------------------------------+-------------------------+
   | Option      | Default value                | Description             |
   +=============+==============================+=========================+
   | ``path``    | ``/socket.io``               | name of the path to     |
   |             |                              | capture                 |
   +-------------+------------------------------+-------------------------+
   | ``serveClie | ``true``                     | whether to serve the    |
   | nt``        |                              | client files            |
   +-------------+------------------------------+-------------------------+
   | ``adapter`` | -                            | the adapter to use.     |
   |             |                              | Defaults to an instance |
   |             |                              | of the ``Adapter`` that |
   |             |                              | ships with socket.io    |
   |             |                              | which is memory based.  |
   |             |                              | See                     |
   |             |                              | `socket.io-adapter <htt |
   |             |                              | ps://github.com/socketi |
   |             |                              | o/socket.io-adapter>`_ |
   +-------------+------------------------------+-------------------------+
   | ``origins`` | ``*``                        | the allowed origins     |
   +-------------+------------------------------+-------------------------+
   | ``parser``  | -                            | the parser to use.      |
   |             |                              | Defaults to an instance |
   |             |                              | of the ``Parser`` that  |
   |             |                              | ships with socket.io.   |
   |             |                              | See                     |
   |             |                              | `socket.io-parser <http |
   |             |                              | s://github.com/socketio |
   |             |                              | /socket.io-parser>`_ .  |
   +-------------+------------------------------+-------------------------+

   Available options for the underlying Engine.IO server:

   +-------------+------------------------------+-------------------------+
   | Option      | Default value                | Description             |
   +=============+==============================+=========================+
   | ``pingTimeo | ``5000``                     | how many ms without a   |
   | ut``        |                              | pong packet to consider |
   |             |                              | the connection closed   |
   +-------------+------------------------------+-------------------------+
   | ``pingInter | ``25000``                    | how many ms before      |
   | val``       |                              | sending a new ping      |
   |             |                              | packet                  |
   +-------------+------------------------------+-------------------------+
   | ``upgradeTi | ``10000``                    | how many ms before an   |
   | meout``     |                              | uncompleted transport   |
   |             |                              | upgrade is cancelled    |
   +-------------+------------------------------+-------------------------+
   | ``maxHttpBu | ``10e7``                     | how many bytes or       |
   | fferSize``  |                              | characters a message    |
   |             |                              | can be, before closing  |
   |             |                              | the session (to avoid   |
   |             |                              | DoS).                   |
   +-------------+------------------------------+-------------------------+
   | ``allowRequ |                              | A function that         |
   | est``       |                              | receives a given        |
   |             |                              | handshake or upgrade    |
   |             |                              | request as its first    |
   |             |                              | parameter, and can      |
   |             |                              | decide whether to       |
   |             |                              | continue or not. The    |
   |             |                              | second argument is a    |
   |             |                              | function that needs to  |
   |             |                              | be called with the      |
   |             |                              | decided information:    |
   |             |                              | ``fn(err, success)``,   |
   |             |                              | where ``success`` is a  |
   |             |                              | boolean value where     |
   |             |                              | false means that the    |
   |             |                              | request is rejected,    |
   |             |                              | and err is an error     |
   |             |                              | code.                   |
   +-------------+------------------------------+-------------------------+
   | ``transport | ``['polling', 'websocket']`` | transports to allow     |
   | s``         |                              | connections to          |
   +-------------+------------------------------+-------------------------+
   | ``allowUpgr | ``true``                     | whether to allow        |
   | ades``      |                              | transport upgrades      |
   +-------------+------------------------------+-------------------------+
   | ``perMessag | ``true``                     | parameters of the       |
   | eDeflate``  |                              | WebSocket               |
   |             |                              | permessage-deflate      |
   |             |                              | extension (see `ws      |
   |             |                              | module <https://github. |
   |             |                              | com/einaros/ws>`_      |
   |             |                              | api docs). Set to       |
   |             |                              | ``false`` to disable.   |
   +-------------+------------------------------+-------------------------+
   | ``httpCompr | ``true``                     |  parameters of the http |
   | ession``    |                              | compression for the     |
   |             |                              | polling transports (see |
   |             |                              | `zlib <http://nodejs.or |
   |             |                              | g/api/zlib.html#zlib_op |
   |             |                              | tions>`_               |
   |             |                              | api docs). Set to       |
   |             |                              | ``false`` to disable.   |
   +-------------+------------------------------+-------------------------+
   | ``cookie``  | ``io``                       | name of the HTTP cookie |
   |             |                              | that contains the       |
   |             |                              | client sid to send as   |
   |             |                              | part of handshake       |
   |             |                              | response headers. Set   |
   |             |                              | to ``false`` to not     |
   |             |                              | send one.               |
   +-------------+------------------------------+-------------------------+
   | ``cookiePat | ``/``                        | path of the above       |
   | h``         |                              | ``cookie`` option. If   |
   |             |                              | false, no path will be  |
   |             |                              | sent, which means       |
   |             |                              | browsers will only send |
   |             |                              | the cookie on the       |
   |             |                              | engine.io attached path |
   |             |                              | (``/engine.io``). Set   |
   |             |                              | false to not save io    |
   |             |                              | cookie on all requests. |
   +-------------+------------------------------+-------------------------+
   | ``cookieHtt | ``true``                     | if ``true`` HttpOnly io |
   | pOnly``     |                              | cookie cannot be        |
   |             |                              | accessed by client-side |
   |             |                              | APIs, such as           |
   |             |                              | JavaScript. *This       |
   |             |                              | option has no effect if |
   |             |                              | ``cookie`` or           |
   |             |                              | ``cookiePath`` is set   |
   |             |                              | to ``false``.*          |
   +-------------+------------------------------+-------------------------+
   | ``wsEngine` | ``ws``                       |  what WebSocket server  |
   | `           |                              | implementation to use.  |
   |             |                              | Specified module must   |
   |             |                              | conform to the ``ws``   |
   |             |                              | interface (see `ws      |
   |             |                              | module api              |
   |             |                              | docs <https://github.co |
   |             |                              | m/websockets/ws/blob/ma |
   |             |                              | ster/doc/ws.md>`_ ).    |
   |             |                              | Default value is        |
   |             |                              | ``ws``. An alternative  |
   |             |                              | c++ addon is also       |
   |             |                              | available by installing |
   |             |                              | ``uws`` module.         |
   +-------------+------------------------------+-------------------------+

   Among those options:

   -  The ``pingTimeout`` and ``pingInterval`` parameters will impact the
      delay before a client knows the server is not available anymore. For
      example, if the underlying TCP connection is not closed properly due
      to a network issue, a client may have to wait up to
      ``pingTimeout + pingInterval`` ms before getting a ``disconnect``
      event.

   -  The order of the ``transports`` array is important. By default, a
      long-polling connection is established first, and then upgraded to
      WebSocket if possible. Using ``['websocket']`` means there will be no
      fallback if a WebSocket connection cannot be opened.

   .. code:: js

      const server = require('http').createServer();

      const io = require('socket.io')(server, {
        path: '/test',
        serveClient: false,
        // below are engine.IO options
        pingInterval: 10000,
        pingTimeout: 5000,
        cookie: false
      });

      server.listen(3000);

.. class:: new Server(port[, options])

   -  ``port`` *(Number)* a port to listen to (a new ``http.Server`` will
      be created)
   -  ``options`` *(Object)*

   See `above <#new-Server-httpServer-options>`_ for the list of available
   ``options``.

   .. code:: js

      const io = require('socket.io')(3000, {
        path: '/test',
        serveClient: false,
        // below are engine.IO options
        pingInterval: 10000,
        pingTimeout: 5000,
        cookie: false
      });

.. class:: new Server(options)

   -  ``options`` *(Object)*

   See `above <#new-Server-httpServer-options>`_ for the list of available ``options``.

   .. code:: js

      const io = require('socket.io')({
        path: '/test',
        serveClient: false,
      });

      // either
      const server = require('http').createServer();

      io.attach(server, {
        pingInterval: 10000,
        pingTimeout: 5000,
        cookie: false
      });

      server.listen(3000);

      // or
      io.attach(3000, {
        pingInterval: 10000,
        pingTimeout: 5000,
        cookie: false
      });

.. attribute:: server.sockets

   -  *(Namespace)*

   An alias for the default (``/``) namespace.

   .. code:: js

      io.sockets.emit('hi', 'everyone');
      // is equivalent to
      io.of('/').emit('hi', 'everyone');

.. function:: server.serveClient([value])


   -  ``value`` *(Boolean)*
   -  **Returns** ``Server|Boolean``

   If ``value`` is ``true`` the attached server (see ``Server#attach``)
   will serve the client files. Defaults to ``true``. This method has no
   effect after ``attach`` is called. If no arguments are supplied this
   method returns the current value.

   .. code:: js

      // pass a server and the `serveClient` option
      const io = require('socket.io')(http, { serveClient: false });

      // or pass no server and then you can call the method
      const io = require('socket.io')();
      io.serveClient(false);
      io.attach(http);

.. function:: server.path([value])


   -  ``value`` *(String)*
   -  **Returns** ``Server|String``

   Sets the path ``value`` under which ``engine.io`` and the static files
   will be served. Defaults to ``/socket.io``. If no arguments are supplied
   this method returns the current value.

   .. code:: js

      const io = require('socket.io')();
      io.path('/myownpath');

      // client-side
      const socket = io({
        path: '/myownpath'
      });

.. function:: server.adapter([value])

   -  ``value`` *(Adapter)*
   -  **Returns** ``Server|Adapter``

   Sets the adapter ``value``. Defaults to an instance of the ``Adapter``
   that ships with socket.io which is memory based. See
   `socket.io-adapter <https://github.com/socketio/socket.io-adapter>`_ .
   If no arguments are supplied this method returns the current value.

   .. code:: js

      const io = require('socket.io')(3000);
      const redis = require('socket.io-redis');
      io.adapter(redis({ host: 'localhost', port: 6379 }));

   .. function:: server.origins([value])

   -  ``value`` *(String|String[])*
   -  **Returns** ``Server|String``

   Sets the allowed origins ``value``. Defaults to any origins being
   allowed. If no arguments are supplied this method returns the current
   value.

   .. code:: js

      io.origins(['https://foo.example.com:443']);

.. function:: server.origins(fn)

   -  ``fn`` *(Function)*
   -  **Returns** ``Server``

   Provides a function taking two arguments ``origin:String`` and
   ``callback(error, success)``, where ``success`` is a boolean value
   indicating whether origin is allowed or not. If ``success`` is set to
   ``false``, ``error`` must be provided as a string value that will be
   appended to the server response, e.g. “Origin not allowed”.

   **Potential drawbacks**: \* in some situations, when it is not possible
   to determine ``origin`` it may have value of ``*`` \* As this function
   will be executed for every request, it is advised to make this function
   work as fast as possible \* If ``socket.io`` is used together with
   ``Express``, the CORS headers will be affected only for ``socket.io``
   requests. For Express you can use
   `cors <https://github.com/expressjs/cors>`_ .

   .. code:: js

      io.origins((origin, callback) => {
        if (origin !== 'https://foo.example.com') {
          return callback('origin not allowed', false);
        }
        callback(null, true);
      });

.. function:: server.attach(httpServer[, options])

   -  ``httpServer`` *(http.Server)* the server to attach to
   -  ``options`` *(Object)*

   Attaches the ``Server`` to an engine.io instance on ``httpServer`` with
   the supplied ``options`` (optionally).

.. function:: server.attach(port[, options])

   -  ``port`` *(Number)* the port to listen on
   -  ``options`` *(Object)*

   Attaches the ``Server`` to an engine.io instance on a new http.Server
   with the supplied ``options`` (optionally).

.. function:: server.listen(httpServer[, options])


   Synonym of `server.attach(httpServer[,options]) <#server-attach-httpServer-options>`_ .

.. function:: server.listen(port[, options])

   Synonym of `server.attach(port[,options]) <#server-attach-port-options>`_ .

.. function:: server.bind(engine)

   -  ``engine`` *(engine.Server)*
   -  **Returns** ``Server``

   Advanced use only. Binds the server to a specific engine.io ``Server``
   (or compatible API) instance.

.. function:: server.onconnection(socket)

   -  ``socket`` *(engine.Socket)*
   -  **Returns** ``Server``

   Advanced use only. Creates a new ``socket.io`` client from the incoming
   engine.io (or compatible API) ``Socket``.

.. function:: server.of(nsp)

   -  ``nsp`` *(String|RegExp|Function)*
   -  **Returns** ``Namespace``

   Initializes and retrieves the given ``Namespace`` by its pathname
   identifier ``nsp``. If the namespace was already initialized it returns
   it immediately.

   .. code:: js

      const adminNamespace = io.of('/admin');

   A regex or a function can also be provided, in order to create namespace
   in a dynamic way:

   .. code:: js

      const dynamicNsp = io.of(/^\/dynamic-\d+$/).on('connect', (socket) => {
        const newNamespace = socket.nsp; // newNamespace.name === '/dynamic-101'

        // broadcast to all clients in the given sub-namespace
        newNamespace.emit('hello');
      });

      // client-side
      const socket = io('/dynamic-101');

      // broadcast to all clients in each sub-namespace
      dynamicNsp.emit('hello');

      // use a middleware for each sub-namespace
      dynamicNsp.use((socket, next) => { /* ... */ });

   With a function:

   .. code:: js

      io.of((name, query, next) => {
        next(null, checkToken(query.token));
      }).on('connect', (socket) => { /* ... */ });

.. function:: server.close([callback])

   -  ``callback`` *(Function)*

   Closes the socket.io server. The ``callback`` argument is optional and will be called when all connections are closed.

   .. code:: js

      const Server = require('socket.io');
      const PORT   = 3030;
      const server = require('http').Server();

      const io = Server(PORT);

      io.close(); // Close current server

      server.listen(PORT); // PORT is free to use

      io = Server(server);

.. attribute:: server.engine.generateId

   Overwrites the default method to generate your custom socket id.

   The function is called with a node request object (``http.IncomingMessage``) as first parameter.

   .. code:: js

      io.engine.generateId = (req) => {
        return "custom:id:" + custom_id++; // custom id must be unique
      }

