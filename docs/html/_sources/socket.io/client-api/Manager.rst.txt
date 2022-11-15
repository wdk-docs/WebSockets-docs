
Manager
=======

.. class:: new Manager(url[, options])

   new Manager(url[, options])

   :param String url:
   :param Object options:
   :Returns: ``Manager``

Available options:

+--------------------------+----------------+------------------------------------+
|          Option          | Default value  |            Description             |
+==========================+================+====================================+
| ``path``                 | ``/socket.io`` | name of the path that              |
|                          |                | is captured on the                 |
|                          |                | server side                        |
+--------------------------+----------------+------------------------------------+
| ``reconnection``         | ``true``       | whether to reconnect automatically |
+--------------------------+----------------+------------------------------------+
| ``reconnectionAttempts`` | ``Infinity``   | number of reconnection             |
|                          |                | attempts before giving             |
|                          |                | up                                 |
+--------------------------+----------------+------------------------------------+
| ``reconnectionDelay``    | ``1000``       | how long to initially              |
|                          |                | wait before attempting             |
|                          |                | a new reconnection                 |
|                          |                | (``1000``). Affected by            |
|                          |                | +/-                                |
|                          |                | ``randomizationFactor``            |
|                          |                | ,                                  |
|                          |                | for example the default            |
|                          |                | initial delay will be              |
|                          |                | between 500 to 1500ms.             |
+--------------------------+----------------+------------------------------------+
| ``reconnectionDelayMax`` | ``5000``       | maximum amount of time             |
|                          |                | to wait between                    |
|                          |                | reconnections                      |
|                          |                | (``5000``). Each                   |
|                          |                | attempt increases the              |
|                          |                | reconnection delay by              |
|                          |                | 2x along with a                    |
|                          |                | randomization as above             |
+--------------------------+----------------+------------------------------------+
| ``randomizationFactor``  | ``0.5``        | 0 <=                               |
|                          |                | randomizationFactor <=             |
|                          |                | 1                                  |
+--------------------------+----------------+------------------------------------+
| ``timeout``              | ``20000``      | connection timeout                 |
|                          |                | before a                           |
|                          |                | ``connect_error`` and              |
|                          |                | ``connect_timeout``                |
|                          |                | events are emitted                 |
+--------------------------+----------------+------------------------------------+
| ``autoConnect``          | ``true``       | by setting this false,             |
|                          |                | you have to call                   |
|                          |                | ``manager.open``                   |
|                          |                | whenever you decide                |
|                          |                | it’s appropriate                   |
+--------------------------+----------------+------------------------------------+
| ``query``                | ``{}``         | additional query                   |
|                          |                | parameters that are                |
|                          |                | sent when connecting a             |
|                          |                | namespace (then found              |
|                          |                | in                                 |
|                          |                | ``socket.handshake.quer            |
|                          |                | y``                                |
|                          |                | object on the                      |
|                          |                | server-side)                       |
+--------------------------+----------------+------------------------------------+
| ``parser``               | -              | the parser to use.                 |
|                          |                | Defaults to an instance            |
|                          |                | of the ``Parser`` that             |
|                          |                | ships with socket.io.              |
|                          |                | See                                |
|                          |                | `socket.io-parser                  |
|                          |                | <https://github.com/socketio       |
|                          |                | /socket.io-parser>`_.              |
+--------------------------+----------------+------------------------------------+

Available options for the underlying Engine.IO client:

+------------------------+------------------------------+---------------------------+
|         Option         |        Default value         |        Description        |
+========================+==============================+===========================+
| ``upgrade``            | ``true``                     | whether the client        |
|                        |                              | should try to upgrade     |
|                        |                              | the transport from        |
|                        |                              | long-polling to           |
|                        |                              | something better.         |
+------------------------+------------------------------+---------------------------+
| ``forceJSONP``         | ``false``                    | forces JSONP for          |
|                        |                              | polling transport.        |
+------------------------+------------------------------+---------------------------+
| ``jsonp``              | ``true``                     | determines whether to     |
|                        |                              | use JSONP when            |
|                        |                              | necessary for polling.    |
|                        |                              | If disabled (by           |
|                        |                              | settings to false) an     |
|                        |                              | error will be emitted     |
|                        |                              | (saying “No transports    |
|                        |                              | available”) if no other   |
|                        |                              | transports are            |
|                        |                              | available. If another     |
|                        |                              | transport is available    |
|                        |                              | for opening a             |
|                        |                              | connection                |
|                        |                              | (e.g. WebSocket) that     |
|                        |                              | transport will be used    |
|                        |                              | instead.                  |
+------------------------+------------------------------+---------------------------+
| ``forceBase            | ``false``                    | forces base 64 encoding   |
| 64``                   |                              | for polling transport     |
|                        |                              | even when XHR2            |
|                        |                              | responseType is           |
|                        |                              | available and WebSocket   |
|                        |                              | even if the used          |
|                        |                              | standard supports         |
|                        |                              | binary.                   |
+------------------------+------------------------------+---------------------------+
| ``enablesXDR``         | ``false``                    | enables XDomainRequest    |
|                        |                              | for IE8 to avoid          |
|                        |                              | loading bar flashing      |
|                        |                              | with click sound.         |
|                        |                              | default to ``false``      |
|                        |                              | because XDomainRequest    |
|                        |                              | has a flaw of not         |
|                        |                              | sending cookie.           |
+------------------------+------------------------------+---------------------------+
| ``timestampRequests``  | -                            | whether to add the        |
|                        |                              | timestamp with each       |
|                        |                              | transport request.        |
|                        |                              | Note: polling requests    |
|                        |                              | are always stamped        |
|                        |                              | unless this option is     |
|                        |                              | explicitly set to         |
|                        |                              | ``false``                 |
+------------------------+------------------------------+---------------------------+
| ``timestampParam``     | ``t``                        | the timestamp             |
|                        |                              | parameter                 |
+------------------------+------------------------------+---------------------------+
| ``policyPort``         | ``843``                      | port the policy server    |
|                        |                              | listens on                |
+------------------------+------------------------------+---------------------------+
| ``transports``         | ``['polling', 'websocket']`` | a list of transports to   |
|                        |                              | try (in order).           |
|                        |                              | ``Engine`` always         |
|                        |                              | attempts to connect       |
|                        |                              | directly with the first   |
|                        |                              | one, provided the         |
|                        |                              | feature detection test    |
|                        |                              | for it passes.            |
+------------------------+------------------------------+---------------------------+
| ``transportOptions``   | ``{}``                       | hash of options,          |
|                        |                              | indexed by transport      |
|                        |                              | name, overriding the      |
|                        |                              | common options for the    |
|                        |                              | given transport           |
+------------------------+------------------------------+---------------------------+
| ``rememberUpgrade``    | ``false``                    | If true and if the        |
|                        |                              | previous websocket        |
|                        |                              | connection to the         |
|                        |                              | server succeeded, the     |
|                        |                              | connection attempt will   |
|                        |                              | bypass the normal         |
|                        |                              | upgrade process and       |
|                        |                              | will initially try        |
|                        |                              | websocket. A connection   |
|                        |                              | attempt following a       |
|                        |                              | transport error will      |
|                        |                              | use the normal upgrade    |
|                        |                              | process. It is            |
|                        |                              | recommended you turn      |
|                        |                              | this on only when using   |
|                        |                              | SSL/TLS connections, or   |
|                        |                              | if you know that your     |
|                        |                              | network does not block    |
|                        |                              | websockets.               |
+------------------------+------------------------------+---------------------------+
| ``onlyBinaryUpgrades`` | ``false``                    | whether transport         |
|                        |                              | upgrades should be        |
|                        |                              | restricted to             |
|                        |                              | transports supporting     |
|                        |                              | binary data               |
+------------------------+------------------------------+---------------------------+
| ``requestTimeout``     | ``0``                        | timeout for xhr-polling   |
|                        |                              | requests in               |
|                        |                              | milliseconds (``0``)      |
|                        |                              | (*only for polling        |
|                        |                              | transport*)               |
+------------------------+------------------------------+---------------------------+
| ``protocols``          | -                            | a list of subprotocols    |
|                        |                              | (see `MDN                 |
|                        |                              | reference <https://deve   |
|                        |                              | loper.mozilla.org/en-US   |
|                        |                              | /docs/Web/API/WebSocket   |
|                        |                              | s_API/Writing_WebSocket   |
|                        |                              | _servers#Subprotocols>`_) |
|                        |                              | (*only for websocket      |
|                        |                              | transport*)               |
+------------------------+------------------------------+---------------------------+

Node.js-only options for the underlying Engine.IO client:

+------------------------+---------------+-------------------------+
|         Option         | Default value |       Description       |
+========================+===============+=========================+
| ``agent``              | ``false``     | the ``http.Agent`` to   |
|                        |               | use                     |
+------------------------+---------------+-------------------------+
| ``pfx``                | -             | Certificate, Private    |
|                        |               | key and CA certificates |
|                        |               | to use for SSL.         |
+------------------------+---------------+-------------------------+
| ``key``                | -             | Private key to use for  |
|                        |               | SSL.                    |
+------------------------+---------------+-------------------------+
| ``passphrase``         | -             | A string of passphrase  |
|                        |               | for the private key or  |
|                        |               | pfx.                    |
+------------------------+---------------+-------------------------+
| ``cert``               | -             | Public x509 certificate |
|                        |               | to use.                 |
+------------------------+---------------+-------------------------+
| ``ca``                 | -             | An authority            |
|                        |               | certificate or array of |
|                        |               | authority certificates  |
|                        |               | to check the remote     |
|                        |               | host against.           |
+------------------------+---------------+-------------------------+
| ``ciphers``            | -             | A string describing the |
|                        |               | ciphers to use or       |
|                        |               | exclude. Consult the    |
|                        |               | `cipher format          |
|                        |               | list <http://www.openss |
|                        |               | l.org/docs/apps/ciphers |
|                        |               | .html#CIPHER_LIST_FORMA |
|                        |               | T>`_                    |
|                        |               | for details on the      |
|                        |               | format.                 |
+------------------------+---------------+-------------------------+
| ``rejectUnauthorized`` | ``false``     | If true, the server     |
|                        |               | certificate is verified |
|                        |               | against the list of     |
|                        |               | supplied CAs. An        |
|                        |               | ‘error’ event is        |
|                        |               | emitted if verification |
|                        |               | fails. Verification     |
|                        |               | happens at the          |
|                        |               | connection level,       |
|                        |               | before the HTTP request |
|                        |               | is sent.                |
+------------------------+---------------+-------------------------+
| ``perMessageDeflate``  | ``true``      | parameters of the       |
|                        |               | WebSocket               |
|                        |               | permessage-deflate      |
|                        |               | extension (see `ws      |
|                        |               | module <https://github. |
|                        |               | com/einaros/ws>`_       |
|                        |               | api docs). Set to       |
|                        |               | ``false`` to disable.   |
+------------------------+---------------+-------------------------+
| ``extraHeaders``       | ``{}``        | Headers that will be    |
|                        |               | passed for each request |
|                        |               | to the server (via      |
|                        |               | xhr-polling and via     |
|                        |               | websockets). These      |
|                        |               | values then can be used |
|                        |               | during handshake or for |
|                        |               | special proxies.        |
+------------------------+---------------+-------------------------+
| ``forceNode``          | ``false``     | Uses NodeJS             |
|                        |               | implementation for      |
|                        |               | websockets - even if    |
|                        |               | there is a native       |
|                        |               | Browser-Websocket       |
|                        |               | available, which is     |
|                        |               | preferred by default    |
|                        |               | over the NodeJS         |
|                        |               | implementation. (This   |
|                        |               | is useful when using    |
|                        |               | hybrid platforms like   |
|                        |               | nw.js or electron)      |
+------------------------+---------------+-------------------------+
| ``localAddress``       | -             | the local IP address to |
|                        |               | connect to              |
+------------------------+---------------+-------------------------+

.. function:: manager.reconnection([value])

   Sets the ``reconnection`` option, or returns it if no parameters are passed.

   :param Boolean value:
   :Returns: ``Manager|Boolean``

.. function:: manager.reconnectionAttempts([value])

   Sets the ``reconnectionAttempts`` option, or returns it if no parameters are passed.

   :param Number value:
   :Returns: ``Manager|Number``

.. function:: manager.reconnectionDelay([value])

   Sets the ``reconnectionDelay`` option, or returns it if no parameters are passed.

   :param Number value:
   :Returns: ``Manager|Number``

.. function:: manager.reconnectionDelayMax([value])

   Sets the ``reconnectionDelayMax`` option, or returns it if no parameters are passed.

   :param Number value:
   :Returns: ``Manager|Number``

.. function:: manager.timeout([value])

   Sets the ``timeout`` option, or returns it if no parameters are passed.

   :param Number value:
   :Returns: ``Manager|Number``

.. function:: manager.open([callback])

   If the manager was initiated with ``autoConnect`` to ``false``, launch a new connection attempt.

   The ``callback`` argument is optional and will be called once the attempt fails/succeeds.

   :param Function callback:
   :Returns: ``Manager``

.. function:: manager.connect([callback])

   Synonym of `manager.open([callback]) <#manageropencallback>`_.

.. function:: manager.socket(nsp, options)

   Creates a new ``Socket`` for the given namespace.

   :param String nsp:
   :param Object options:
   :Returns: ``Socket``

.. function:: Event.connect_error(error)

   Fired upon a connection error.

   :param Object error: error object

.. function:: Event.connect_timeout

   Fired upon a connection timeout.

.. function:: Event.reconnect(attempt)

   Fired upon a successful reconnection.

   :param Number attempt: reconnection attempt number

.. function:: Event.reconnect_attempt(attempt)

   Fired upon an attempt to reconnect.

   :param Number attempt: reconnection attempt number

.. function:: Event.reconnecting(attempt)

   Fired upon an attempt to reconnect.

   :param Number attempt: reconnection attempt number

.. function:: Event.reconnect_error(error)

   Fired upon a reconnection attempt error.

   :param Object error: error object

.. function:: Event.reconnect_failed

   Fired when couldn’t reconnect within ``reconnectionAttempts``.

.. function:: Event.ping

   Fired when a ping packet is written out to the server.

.. function:: Event.pong(ms)

   Fired when a pong is received from the server.

   :param Number ms: number of ms elapsed since ``ping`` packet (i.e.: latency).
