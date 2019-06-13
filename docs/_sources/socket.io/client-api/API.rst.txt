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

io.protocol
-----------

-  *(Number)*

The protocol revision number.

io([url][, options])
--------------------

-  ``url`` *(String)* (defaults to ``window.location``)
-  ``options`` *(Object)*

   -  ``forceNew`` *(Boolean)* whether to reuse an existing connection

-  **Returns** ``Socket``

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

See `new Manager(url[, options]) <#new-Manager-url-options>`__ for the
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
RFC <https://tools.ietf.org/html/rfc6455#section-4>`__)

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

The default `parser <https://github.com/socketio/socket.io-parser>`__
promotes compatibility (support for ``Blob``, ``File``, binary check) at
the expense of performance. A custom parser can be provided to match the
needs of your application. Please see the example
`here <https://github.com/socketio/socket.io/tree/master/examples/custom-parsers>`__.

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

Manager
=======

new Manager(url[, options])
---------------------------

-  ``url`` *(String)*
-  ``options`` *(Object)*
-  **Returns** ``Manager``

Available options:

+-------------+------------------------------+-------------------------+
| Option      | Default value                | Description             |
+=============+==============================+=========================+
| ``path``    | ``/socket.io``               |  name of the path that  |
|             |                              | is captured on the      |
|             |                              | server side             |
+-------------+------------------------------+-------------------------+
| ``reconnect | ``true``                     |  whether to reconnect   |
| ion``       |                              | automatically           |
+-------------+------------------------------+-------------------------+
| ``reconnect | ``Infinity``                 | number of reconnection  |
| ionAttempts |                              | attempts before giving  |
| ``          |                              | up                      |
+-------------+------------------------------+-------------------------+
| ``reconnect | ``1000``                     | how long to initially   |
| ionDelay``  |                              | wait before attempting  |
|             |                              | a new reconnection      |
|             |                              | (``1000``). Affected by |
|             |                              | +/-                     |
|             |                              | ``randomizationFactor`` |
|             |                              | ,                       |
|             |                              | for example the default |
|             |                              | initial delay will be   |
|             |                              | between 500 to 1500ms.  |
+-------------+------------------------------+-------------------------+
| ``reconnect |  ``5000``                    | maximum amount of time  |
| ionDelayMax |                              | to wait between         |
| ``          |                              | reconnections           |
|             |                              | (``5000``). Each        |
|             |                              | attempt increases the   |
|             |                              | reconnection delay by   |
|             |                              | 2x along with a         |
|             |                              | randomization as above  |
+-------------+------------------------------+-------------------------+
| ``randomiza | ``0.5``                      | 0 <=                    |
| tionFactor` |                              | randomizationFactor <=  |
| `           |                              | 1                       |
+-------------+------------------------------+-------------------------+
| ``timeout`` | ``20000``                    | connection timeout      |
|             |                              | before a                |
|             |                              | ``connect_error`` and   |
|             |                              | ``connect_timeout``     |
|             |                              | events are emitted      |
+-------------+------------------------------+-------------------------+
| ``autoConne | ``true``                     |  by setting this false, |
| ct``        |                              | you have to call        |
|             |                              | ``manager.open``        |
|             |                              | whenever you decide     |
|             |                              | it’s appropriate        |
+-------------+------------------------------+-------------------------+
| ``query``   | ``{}``                       | additional query        |
|             |                              | parameters that are     |
|             |                              | sent when connecting a  |
|             |                              | namespace (then found   |
|             |                              | in                      |
|             |                              | ``socket.handshake.quer |
|             |                              | y``                     |
|             |                              | object on the           |
|             |                              | server-side)            |
+-------------+------------------------------+-------------------------+
| ``parser``  | -                            | the parser to use.      |
|             |                              | Defaults to an instance |
|             |                              | of the ``Parser`` that  |
|             |                              | ships with socket.io.   |
|             |                              | See                     |
|             |                              | `socket.io-parser <http |
|             |                              | s://github.com/socketio |
|             |                              | /socket.io-parser>`__.  |
+-------------+------------------------------+-------------------------+

Available options for the underlying Engine.IO client:

+-------------+------------------------------+-------------------------+
| Option      | Default value                | Description             |
+=============+==============================+=========================+
| ``upgrade`` | ``true``                     | whether the client      |
|             |                              | should try to upgrade   |
|             |                              | the transport from      |
|             |                              | long-polling to         |
|             |                              | something better.       |
+-------------+------------------------------+-------------------------+
| ``forceJSON | ``false``                    | forces JSONP for        |
| P``         |                              | polling transport.      |
+-------------+------------------------------+-------------------------+
| ``jsonp``   | ``true``                     | determines whether to   |
|             |                              | use JSONP when          |
|             |                              | necessary for polling.  |
|             |                              | If disabled (by         |
|             |                              | settings to false) an   |
|             |                              | error will be emitted   |
|             |                              | (saying “No transports  |
|             |                              | available”) if no other |
|             |                              | transports are          |
|             |                              | available. If another   |
|             |                              | transport is available  |
|             |                              | for opening a           |
|             |                              | connection              |
|             |                              | (e.g. WebSocket) that   |
|             |                              | transport will be used  |
|             |                              | instead.                |
+-------------+------------------------------+-------------------------+
| ``forceBase | ``false``                    | forces base 64 encoding |
| 64``        |                              | for polling transport   |
|             |                              | even when XHR2          |
|             |                              | responseType is         |
|             |                              | available and WebSocket |
|             |                              | even if the used        |
|             |                              | standard supports       |
|             |                              | binary.                 |
+-------------+------------------------------+-------------------------+
| ``enablesXD | ``false``                    | enables XDomainRequest  |
| R``         |                              | for IE8 to avoid        |
|             |                              | loading bar flashing    |
|             |                              | with click sound.       |
|             |                              | default to ``false``    |
|             |                              | because XDomainRequest  |
|             |                              | has a flaw of not       |
|             |                              | sending cookie.         |
+-------------+------------------------------+-------------------------+
| ``timestamp | -                            | whether to add the      |
| Requests``  |                              | timestamp with each     |
|             |                              | transport request.      |
|             |                              | Note: polling requests  |
|             |                              | are always stamped      |
|             |                              | unless this option is   |
|             |                              | explicitly set to       |
|             |                              | ``false``               |
+-------------+------------------------------+-------------------------+
| ``timestamp | ``t``                        |  the timestamp          |
| Param``     |                              | parameter               |
+-------------+------------------------------+-------------------------+
| ``policyPor | ``843``                      | port the policy server  |
| t``         |                              | listens on              |
+-------------+------------------------------+-------------------------+
| ``transport | ``['polling', 'websocket']`` | a list of transports to |
| s``         |                              | try (in order).         |
|             |                              | ``Engine`` always       |
|             |                              | attempts to connect     |
|             |                              | directly with the first |
|             |                              | one, provided the       |
|             |                              | feature detection test  |
|             |                              | for it passes.          |
+-------------+------------------------------+-------------------------+
| ``transport | ``{}``                       | hash of options,        |
| Options``   |                              | indexed by transport    |
|             |                              | name, overriding the    |
|             |                              | common options for the  |
|             |                              | given transport         |
+-------------+------------------------------+-------------------------+
| ``rememberU | ``false``                    | If true and if the      |
| pgrade``    |                              | previous websocket      |
|             |                              | connection to the       |
|             |                              | server succeeded, the   |
|             |                              | connection attempt will |
|             |                              | bypass the normal       |
|             |                              | upgrade process and     |
|             |                              | will initially try      |
|             |                              | websocket. A connection |
|             |                              | attempt following a     |
|             |                              | transport error will    |
|             |                              | use the normal upgrade  |
|             |                              | process. It is          |
|             |                              | recommended you turn    |
|             |                              | this on only when using |
|             |                              | SSL/TLS connections, or |
|             |                              | if you know that your   |
|             |                              | network does not block  |
|             |                              | websockets.             |
+-------------+------------------------------+-------------------------+
| ``onlyBinar | ``false``                    | whether transport       |
| yUpgrades`` |                              | upgrades should be      |
|             |                              | restricted to           |
|             |                              | transports supporting   |
|             |                              | binary data             |
+-------------+------------------------------+-------------------------+
| ``requestTi | ``0``                        | timeout for xhr-polling |
| meout``     |                              | requests in             |
|             |                              | milliseconds (``0``)    |
|             |                              | (*only for polling      |
|             |                              | transport*)             |
+-------------+------------------------------+-------------------------+
| ``protocols | -                            | a list of subprotocols  |
| ``          |                              | (see `MDN               |
|             |                              | reference <https://deve |
|             |                              | loper.mozilla.org/en-US |
|             |                              | /docs/Web/API/WebSocket |
|             |                              | s_API/Writing_WebSocket |
|             |                              | _servers#Subprotocols>` |
|             |                              | __)                     |
|             |                              | (*only for websocket    |
|             |                              | transport*)             |
+-------------+------------------------------+-------------------------+

Node.js-only options for the underlying Engine.IO client:

+-------------+------------------------------+-------------------------+
| Option      | Default value                | Description             |
+=============+==============================+=========================+
| ``agent``   | ``false``                    | the ``http.Agent`` to   |
|             |                              | use                     |
+-------------+------------------------------+-------------------------+
| ``pfx``     | -                            | Certificate, Private    |
|             |                              | key and CA certificates |
|             |                              | to use for SSL.         |
+-------------+------------------------------+-------------------------+
| ``key``     | -                            | Private key to use for  |
|             |                              | SSL.                    |
+-------------+------------------------------+-------------------------+
| ``passphras | -                            | A string of passphrase  |
| e``         |                              | for the private key or  |
|             |                              | pfx.                    |
+-------------+------------------------------+-------------------------+
| ``cert``    | -                            | Public x509 certificate |
|             |                              | to use.                 |
+-------------+------------------------------+-------------------------+
| ``ca``      | -                            | An authority            |
|             |                              | certificate or array of |
|             |                              | authority certificates  |
|             |                              | to check the remote     |
|             |                              | host against.           |
+-------------+------------------------------+-------------------------+
| ``ciphers`` | -                            | A string describing the |
|             |                              | ciphers to use or       |
|             |                              | exclude. Consult the    |
|             |                              | `cipher format          |
|             |                              | list <http://www.openss |
|             |                              | l.org/docs/apps/ciphers |
|             |                              | .html#CIPHER_LIST_FORMA |
|             |                              | T>`__                   |
|             |                              | for details on the      |
|             |                              | format.                 |
+-------------+------------------------------+-------------------------+
| ``rejectUna | ``false``                    | If true, the server     |
| uthorized`` |                              | certificate is verified |
|             |                              | against the list of     |
|             |                              | supplied CAs. An        |
|             |                              | ‘error’ event is        |
|             |                              | emitted if verification |
|             |                              | fails. Verification     |
|             |                              | happens at the          |
|             |                              | connection level,       |
|             |                              | before the HTTP request |
|             |                              | is sent.                |
+-------------+------------------------------+-------------------------+
| ``perMessag | ``true``                     | parameters of the       |
| eDeflate``  |                              | WebSocket               |
|             |                              | permessage-deflate      |
|             |                              | extension (see `ws      |
|             |                              | module <https://github. |
|             |                              | com/einaros/ws>`__      |
|             |                              | api docs). Set to       |
|             |                              | ``false`` to disable.   |
+-------------+------------------------------+-------------------------+
| ``extraHead | ``{}``                       | Headers that will be    |
| ers``       |                              | passed for each request |
|             |                              | to the server (via      |
|             |                              | xhr-polling and via     |
|             |                              | websockets). These      |
|             |                              | values then can be used |
|             |                              | during handshake or for |
|             |                              | special proxies.        |
+-------------+------------------------------+-------------------------+
| ``forceNode | ``false``                    | Uses NodeJS             |
| ``          |                              | implementation for      |
|             |                              | websockets - even if    |
|             |                              | there is a native       |
|             |                              | Browser-Websocket       |
|             |                              | available, which is     |
|             |                              | preferred by default    |
|             |                              | over the NodeJS         |
|             |                              | implementation. (This   |
|             |                              | is useful when using    |
|             |                              | hybrid platforms like   |
|             |                              | nw.js or electron)      |
+-------------+------------------------------+-------------------------+
| ``localAddr | -                            | the local IP address to |
| ess``       |                              | connect to              |
+-------------+------------------------------+-------------------------+

manager.reconnection([value])
-----------------------------

-  ``value`` *(Boolean)*
-  **Returns** ``Manager|Boolean``

Sets the ``reconnection`` option, or returns it if no parameters are
passed.

manager.reconnectionAttempts([value])
-------------------------------------

-  ``value`` *(Number)*
-  **Returns** ``Manager|Number``

Sets the ``reconnectionAttempts`` option, or returns it if no parameters
are passed.

manager.reconnectionDelay([value])
----------------------------------

-  ``value`` *(Number)*
-  **Returns** ``Manager|Number``

Sets the ``reconnectionDelay`` option, or returns it if no parameters
are passed.

manager.reconnectionDelayMax([value])
-------------------------------------

-  ``value`` *(Number)*
-  **Returns** ``Manager|Number``

Sets the ``reconnectionDelayMax`` option, or returns it if no parameters
are passed.

manager.timeout([value])
------------------------

-  ``value`` *(Number)*
-  **Returns** ``Manager|Number``

Sets the ``timeout`` option, or returns it if no parameters are passed.

manager.open([callback])
------------------------

-  ``callback`` *(Function)*
-  **Returns** ``Manager``

If the manager was initiated with ``autoConnect`` to ``false``, launch a
new connection attempt.

The ``callback`` argument is optional and will be called once the
attempt fails/succeeds.

manager.connect([callback])
---------------------------

Synonym of `manager.open([callback]) <#manageropencallback>`__.

manager.socket(nsp, options)
----------------------------

-  ``nsp`` *(String)*
-  ``options`` *(Object)*
-  **Returns** ``Socket``

Creates a new ``Socket`` for the given namespace.

Event: ‘connect_error’
----------------------

-  ``error`` *(Object)* error object

Fired upon a connection error.

Event: ‘connect_timeout’
------------------------

Fired upon a connection timeout.

Event: ‘reconnect’
------------------

-  ``attempt`` *(Number)* reconnection attempt number

Fired upon a successful reconnection.

Event: ‘reconnect_attempt’
--------------------------

-  ``attempt`` *(Number)* reconnection attempt number

Fired upon an attempt to reconnect.

Event: ‘reconnecting’
---------------------

-  ``attempt`` *(Number)* reconnection attempt number

Fired upon an attempt to reconnect.

Event: ‘reconnect_error’
------------------------

-  ``error`` *(Object)* error object

Fired upon a reconnection attempt error.

Event: ‘reconnect_failed’
-------------------------

Fired when couldn’t reconnect within ``reconnectionAttempts``.

Event: ‘ping’
-------------

Fired when a ping packet is written out to the server.

Event: ‘pong’
-------------

-  ``ms`` *(Number)* number of ms elapsed since ``ping`` packet (i.e.:
   latency).

Fired when a pong is received from the server.
