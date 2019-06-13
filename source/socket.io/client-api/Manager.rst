
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
