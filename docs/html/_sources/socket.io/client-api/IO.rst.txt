IO
==============

Exposed as the ``io`` namespace in the standalone build, or the result
of calling ``require('socket.io-client')``.

.. code:: html

   <script src="/socket.io/socket.io.js"></script>
   <script>
     const socket = io('http://localhost');
   </script>

.. code:: js

   const io = require('socket.io-client');
   // or with import syntax
   import io from 'socket.io-client';


.. class:: io

   const io = require('socket.io-client');

.. attribute:: io.protocol

   The protocol revision number.

   *(Number)*


.. function:: io([url][, options])

   :param String url: defaults to ``window.location``
   :param Object options:

    -  ``forceNew`` *(Boolean)* whether to reuse an existing connection

   :Returns: ``Socket``

Creates a new ``Manager`` for the given URL, and attempts to reuse an
existing ``Manager`` for subsequent calls, unless the ``multiplex``
option is passed with ``false``. Passing this option is the equivalent
of passing ``'force new connection': true`` or ``forceNew: true``.

A new ``Socket`` instance is returned for the namespace specified by the
pathname in the URL, defaulting to ``/``. For example, if the ``url`` is
``http://localhost/users``, a transport connection will be established
to ``http://localhost`` and a Socket.IO connection will be established
to ``/users``.

Query parameters can also be provided, either with the ``query`` option
or directly in the url (example: ``http://localhost/users?token=abc``).

See `new Manager(url[, options]) <#new-Manager-url-options>`_ for the
the list of available ``options``.

Initialization examples
-----------------------

With multiplexing
~~~~~~~~~~~~~~~~~

By default, a single connection is used when connecting to different
namespaces (to minimize resources):

.. code:: js

   const socket = io();
   const adminSocket = io('/admin');
   // a single connection will be established

That behaviour can be disabled with the ``forceNew`` option:

.. code:: js

   const socket = io();
   const adminSocket = io('/admin', { forceNew: true });
   // will create two distinct connections

Note: reusing the same namespace will also create two connections

.. code:: js

   const socket = io();
   const socket2 = io();
   // will also create two distinct connections

With custom ``path``
~~~~~~~~~~~~~~~~~~~~

.. code:: js

   const socket = io('http://localhost', {
     path: '/myownpath'
   });

   // server-side
   const io = require('socket.io')({
     path: '/myownpath'
   });

The request URLs will look like:
``localhost/myownpath/?EIO=3&transport=polling&sid=<id>``

.. code:: js

   const socket = io('http://localhost/admin', {
     path: '/mypath'
   });

Here, the socket connects to the ``admin`` namespace, with the custom
path ``mypath``.

The request URLs will look like:
``localhost/mypath/?EIO=3&transport=polling&sid=<id>`` (the namespace is
sent as part of the payload).

With query parameters
~~~~~~~~~~~~~~~~~~~~~

.. code:: js

   const socket = io('http://localhost?token=abc');

   // server-side
   const io = require('socket.io')();

   // middleware
   io.use((socket, next) => {
     let token = socket.handshake.query.token;
     if (isValid(token)) {
       return next();
     }
     return next(new Error('authentication error'));
   });

   // then
   io.on('connection', (socket) => {
     let token = socket.handshake.query.token;
     // ...
   });

With query option
~~~~~~~~~~~~~~~~~

.. code:: js

   const socket = io({
     query: {
       token: 'cde'
     }
   });

The query content can also be updated on reconnection:

.. code:: js

   socket.on('reconnect_attempt', () => {
     socket.io.opts.query = {
       token: 'fgh'
     }
   });

With ``extraHeaders``
~~~~~~~~~~~~~~~~~~~~~

This only works if ``polling`` transport is enabled (which is the
default). Custom headers will not be appended when using ``websocket``
as the transport. This happens because the WebSocket handshake does not
honor custom headers. (For background see the `WebSocket protocol
RFC <https://tools.ietf.org/html/rfc6455#section-4>`_)

.. code:: js

   const socket = io({
     transportOptions: {
       polling: {
         extraHeaders: {
           'x-clientid': 'abc'
         }
       }
     }
   });

   // server-side
   const io = require('socket.io')();

   // middleware
   io.use((socket, next) => {
     let clientId = socket.handshake.headers['x-clientid'];
     if (isValid(clientId)) {
       return next();
     }
     return next(new Error('authentication error'));
   });

With ``websocket`` transport only
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, a long-polling connection is established first, then
upgraded to “better” transports (like WebSocket). If you like to live
dangerously, this part can be skipped:

.. code:: js

   const socket = io({
     transports: ['websocket']
   });

   // on reconnection, reset the transports option, as the Websocket
   // connection may have failed (caused by proxy, firewall, browser, ...)
   socket.on('reconnect_attempt', () => {
     socket.io.opts.transports = ['polling', 'websocket'];
   });

With a custom parser
~~~~~~~~~~~~~~~~~~~~

The default `parser <https://github.com/socketio/socket.io-parser>`_
promotes compatibility (support for ``Blob``, ``File``, binary check) at
the expense of performance. A custom parser can be provided to match the
needs of your application. Please see the example
`here <https://github.com/socketio/socket.io/tree/master/examples/custom-parsers>`_.

.. code:: js

   const parser = require('socket.io-msgpack-parser'); // or require('socket.io-json-parser')
   const socket = io({
     parser: parser
   });

   // the server-side must have the same parser, to be able to communicate
   const io = require('socket.io')({
     parser: parser
   });

With a self-signed certificate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: js

   // server-side
   const fs = require('fs');
   const server = require('https').createServer({
     key: fs.readFileSync('server-key.pem'),
     cert: fs.readFileSync('server-cert.pem')
   });
   const io = require('socket.io')(server);
   server.listen(3000);

   // client-side
   const socket = io({
     // option 1
     ca: fs.readFileSync('server-cert.pem'),

     // option 2. WARNING: it leaves you vulnerable to MITM attacks!
     rejectUnauthorized: false
   });
