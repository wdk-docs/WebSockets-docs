WS API Document
=================

Class: WebSocketServer
----------------------

.. js:class:: WebSocket.Server({host,port,server,noServer...}[, callback])

   This class represents a WebSocket server. It extends the `EventEmitter`.

   new WebSocket.Server(options[, callback])

   Create a new server instance. One of `port`, `server` or `noServer` must be provided or an error is thrown.

   :param String host:  The hostname where to bind the server.
   :param Number port:  The port where to bind the server.
   :param Number backlog:  The maximum length of the queue of pending connections.
   :param server:  A pre-created Node.js HTTP/S server.
   :param Function verifyClient:  A function which can be used to validate incoming connections. See description below.
   :param Function handleProtocols:  A function which can be used to handle the WebSocket subprotocols. See description below.
   :param String path:  Accept only connections matching this path.
   :param Boolean noServer:  Enable no server mode.
   :param Boolean clientTracking:  Specifies whether or not to track clients.
   :param perMessageDeflate: Enable/disable permessage-deflate.

    `perMessageDeflate` can be used to control the behavior of `permessage-deflate extension <permessage-deflate>`_.
    he extension is disabled when `false` (default value).

    If an object is provided then that is extension parameters:

      - **serverNoContextTakeover**: (*Boolean*) - Whether to use context takeover or not.
      - **clientNoContextTakeover**: (*Boolean*) - Acknowledge disabling of client context takeover.
      - **serverMaxWindowBits**: (*Number*) - The value of `windowBits`.
      - **clientMaxWindowBits**: (*Number*) - Request a custom client window size.
      - **zlibDeflateOptions**: (*Object*) - Additional options <zlib-options>`_ to pass to zlib on deflate.
      - **zlibInflateOptions**: (*Object*) - Additional options <zlib-options>`_ to pass to zlib on inflate.
      - **threshold**: (*Number*) - Payloads smaller than this will not be compressed. Defaults to 1024 bytes.
      - **concurrencyLimit**: (*Number*) - The number of concurrent calls to zlib. Calls above this limit will be queued. Default 10. You usually won't need to touch this option. See `this issue <concurrency-limit>`_ for more details.

   :param Number maxPayload: The maximum allowed message size in bytes.
   :param Function callback:

    `callback` will be added as a listener for the `listening` event on the HTTP server when not operating in "noServer" mode.

   :type server: http.Server | https.Server
   :type perMessageDeflate: Boolean | Object

   An HTTP server is automatically created, started, and used if `port` is set.

   To use an external HTTP/S server instead, specify only `server` or `noServer`.
   In this case the HTTP/S server must be started manually. The "noServer" mode allows the WebSocket server to be completly detached from the HTTP/S server.
   This makes it possible, for example, to share a single HTTP/S server between multiple WebSocket servers.

   If `verifyClient` is not set then the handshake is automatically accepted.

.. js:autofunction:: verifyClient({origin,req,secure}[, cb])

   If it is provided with a single argument then that is:

   :param String origin: The value in the Origin header indicated by the client.
   :param http.IncomingMessage req: The client HTTP GET request.
   :param Boolean secure: `true` if `req.connection.authorized` or `req.connection.encrypted` is set.

   The return value (Boolean) of the function determines whether or not to accept the handshake.

.. js:autofunction:: verifyClient.cb(result,code,name,headers)

   if `verifyClient` is provided with two arguments then those are:

   A callback that must be called by the user upon inspection of the `info` fields.

   :param Boolean result: Whether or not to accept the handshake.
   :param Number code: When `result` is `false` this field determines the HTTP error status code to be sent to the client.
   :param String name: When `result` is `false` this field determines the HTTP reason phrase.
   :param Object headers: When `result` is `false` this field determines additional HTTP headers to be sent to the client. For example, `{ 'Retry-After': 120 }`.

.. js:function:: handleProtocols(protocols, request)

   :param Array protocols: The list of WebSocket subprotocols indicated by the client in the `Sec-WebSocket-Protocol` header.
   :param http.IncomingMessage request: The client HTTP GET request.

   The returned value sets the value of the `Sec-WebSocket-Protocol` header in the HTTP 101 response.

   If returned value is `false` the header is not added in the response.

   If `handleProtocols` is not set then the first of the client's requested subprotocols is used.


If a property is empty then either an offered configuration or a default value is used. When sending a fragmented message the length of the first fragment is compared to the threshold.

This determines if compression is used for the entire message.



.. js:function:: ws.onEvent.close

   Emitted when the server closes. This event depends on the `'close'` event of HTTP server only when it is created internally.

   In all other cases, the event is emitted independently.

.. js:function:: ws.onEvent.connection(socket,request)

   Emitted when the handshake is complete. 

   Useful for parsing authority headers, cookie headers, and other information.

   :param WebSocket socket:
   :param http.IncomingMessage request: the http GET request sent by the client.

   

.. js:function:: ws.onEvent.error

   :param Error error: Emitted when an error occurs on the underlying server.

.. js:function:: ws.onEvent.headers(headers,request)

   Emitted before the response headers are written to the socket as part of the handshake.

   This allows you to inspect/modify the headers before they are sent.

   :param Array headers:
   :param http.IncomingMessage request:

   

.. js:function:: ws.onEvent.listening

   Emitted when the underlying server has been bound.

.. js:method:: server.address()

   Returns an object with `port`, `family`, and `address` properties specifying the bound address, the address family name, and port of the server as reported by the operating system if listening on an IP socket.

   If the server is listening on a pipe or UNIX domain socket, the name is returned as a string.

.. js:attribute:: server.clients

   Please note that this property is only added when the `clientTracking` is truthy.

   :return: A set that stores all connected clients.
   :rtype: Set
   

    

.. js:method:: server.close([callback])

   Close the HTTP server if created internally, terminate all clients and call callback when done.

   If an external HTTP server is used via the `server` or `noServer` constructor options, it must be closed manually.

.. js:method:: server.handleUpgrade(request, socket, head, callback)

   :param http.IncomingMessage request:  The client HTTP GET request.
   :param net.Socket socket:  The network socket between the server and client.
   :param Buffer head: The first packet of the upgraded stream.
   :param Function(WebSocket) callback: If the upgrade is successful, the `callback` is called with a `WebSocket` object as parameter.

   Handle a HTTP upgrade request. 
   When the HTTP server is created internally or when the HTTP server is passed via the `server` option, this method is called automatically.

   When operating in "noServer" mode, this method must be called manually.

   

.. js:method:: server.shouldHandle(request)

   :param http.IncomingMessage request:  The client HTTP GET request.

   See if a given request should be handled by this server.

   By default this method validates the pathname of the request, matching it against the `path` option if provided.

   The return value, `true` or `false`, determines whether or not to accept the handshake.

   This method can be overridden when a custom handling logic is required.

Class: WebSocket
-------------------

This class represents a WebSocket. It extends the `EventEmitter`.

Ready state constants

+------------+-------+--------------------------------------------------+
|  Constant  | Value |                   Description                    |
+============+=======+==================================================+
| CONNECTING | 0     | The connection is not yet open.                  |
+------------+-------+--------------------------------------------------+
| OPEN       | 1     | The connection is open and ready to communicate. |
+------------+-------+--------------------------------------------------+
| CLOSING    | 2     | The connection is in the process of closing.     |
+------------+-------+--------------------------------------------------+
| CLOSED     | 3     | The connection is closed.                        |
+------------+-------+--------------------------------------------------+

.. js:class:: WebSocket(address[, protocols][, {followRedirects,...}])

   new WebSocket(address[, protocols][, options])

   :param address: The URL to which to connect.
   :type address: String | url.URL
   :param protocols: The list of subprotocols.
   :type protocols: String | Array
   :param Boolean followRedirects: Whether or not to follow redirects. Defaults to `false`.
   :param Number handshakeTimeout: Timeout in milliseconds for the handshake request. This is reset after every redirection.
   :param Number maxPayload: The maximum allowed message size in bytes.
   :param Number maxRedirects: The maximum number of redirects allowed. Defaults to 10.
   :param String origin: Value of the `Origin` or `Sec-WebSocket-Origin` header depending on the `protocolVersion`.
   :param perMessageDeflate: Enable/disable permessage-deflate. `perMessageDeflate` default value is `true`. When using an object, parameters are the same of the server.The only difference is the direction of requests. For example, serverNoContextTakeover can be used to ask the server to disable context takeover.
   :type perMessageDeflate: Boolean(true) | Object
   :param Number protocolVersion: Value of the `Sec-WebSocket-Version` header.
   :param Boolean skipUTF8Validation: Specifies whether or not to skip UTF-8 validation for text and close messages. Defaults to false. Set to true only if the server is trusted.
   :param other: Options given do not have any effect if parsed from the URL given with the address parameter.
   :type other: Any other option allowed in http.request() or https.request()
   

Create a new WebSocket instance.

**UNIX Domain Sockets**

`ws` supports making requests to UNIX domain sockets. To make one, use the following URL scheme:

.. code-block:: sh

   ws+unix:///absolute/path/to/uds_socket:/pathname?search_params

.. note:: that `:` is the separator between the socket path and the URL path. If the URL path is omitted

.. code-block:: sh

   ws+unix:///absolute/path/to/uds_socket

it defaults to `/`.

.. js:method:: ws.onEvent.close

   Emitted when the connection is closed. 

   :param Number code: a numeric value indicating the status code explaining why the connection has been closed.
   :param String reason: a human-readable string explaining why the connection has been closed.

.. js:method:: ws.onEvent.error

   :param Error error: Emitted when an error occurs.

.. js:method:: ws.onEvent.message

   :param data: Emitted when a message is received from the server.
   :type data: String|Buffer|ArrayBuffer|Buffer[]

.. js:method:: ws.onEvent.open

   Emitted when the connection is established.

.. js:method:: ws.onEvent.ping

   :param Buffer data: 

   Emitted when a ping is received from the server.

.. js:method:: ws.onEvent.pong

   :param Buffer data: 

   Emitted when a pong is received from the server.

.. js:method:: ws.onEvent.unexpected-response

   :param http.ClientRequest request: 
   :param http.IncomingMessage response: 

   Emitted when the server response is not the expected one, for example a 401 response.

   This event gives the ability to read the response in order to extract useful information.

   If the server sends an invalid response and there isn't a listener for this event, an error is emitted.

.. js:method:: ws.onEvent.upgrade

   :param http.IncomingMessage response: 

   Emitted when response headers are received from the server as part of the handshake.

   This allows you to read headers from the server, for example 'set-cookie' headers.

.. js:method:: websocket.addEventListener(type, listener)

   :param String type:  A string representing the event type to listen for.
   :param Function listener:  The listener to add.

   Register an event listener emulating the `EventTarget` interface.

.. js:attribute:: websocket.binaryType

   :return: A string indicating the type of binary data being transmitted by the connection.
   :rtype: String

   This should be one of "nodebuffer", "arraybuffer" or "fragments".

   Defaults to "nodebuffer".

   Type "fragments" will emit the array of fragments as received from the sender, 
   without copyfull concatenation, 
   which is useful for the performance of binary protocols transferring large messages with multiple fragments.

.. js:attribute:: websocket.bufferedAmount

   :return: The number of bytes of data that have been queued using calls to `send()` but not yet transmitted to the network.
   :rtype: Number

.. js:method:: websocket.close([code[, reason]])

   :param code: Number} A numeric value indicating the status code explaining why the connection is being closed.
   :param reason: String} A human-readable string explaining why the connection is closing.

   Initiate a closing handshake.

.. js:attribute:: websocket.extensions

   :rtype: Object
   :return: An object containing the negotiated extensions.

.. js:method:: websocket.onclose

   :rtype: Function
   :return: An event listener to be called when connection is closed.

   The listener receives a `CloseEvent` named "close".

.. js:method:: websocket.onerror

   :rtype: Function
   :return: An event listener to be called when an error occurs.

   The listener receives an `ErrorEvent` named "error".

.. js:method:: websocket.onmessage

   :rtype: Function
   :return: An event listener to be called when a message is received from the server.

   The listener receives a `MessageEvent` named "message".

.. js:method:: websocket.onopen

   :rtype: Function
   :return: An event listener to be called when the connection is established.

   The listener receives an `OpenEvent` named "open".

.. js:method:: websocket.ping([data[, mask]][, callback])

   :param Any data:  The data to send in the ping frame.
   :param Boolean mask:  Specifies whether `data` should be masked or not. Defaults to `true` when `websocket` is not a server client.
   :param Function callback:  An optional callback which is invoked when the ping frame is written out.

   Send a ping.

.. js:method:: websocket.pong([data[, mask]][, callback])

   :param Any data:  The data to send in the pong frame.
   :param Boolean mask:  Specifies whether `data` should be masked or not. Defaults to `true` when `websocket` is not a server client.
   :param Function callback:  An optional callback which is invoked when the pong frame is written out.

   Send a pong.

.. js:attribute:: websocket.protocol

   :return: The subprotocol selected by the server.
   :rtype: String

.. js:attribute:: websocket.readyState

   :rtype: Number
   :return: The current state of the connection. This is one of the ready state constants.

.. js:method:: websocket.removeEventListener(type, listener)


   :param String type:  A string representing the event type to remove.
   :param Function listener:  The listener to remove.

   Removes an event listener emulating the `EventTarget` interface.

.. js:method:: websocket.send(data[, options][, callback])


   :param Any data:  The data to send.
   :param Object options: 
   :param Boolean compress:  Specifies whether `data` should be compressed or not.Defaults to `true` when permessage-deflate is enabled.
   :param Boolean binary:  Specifies whether `data` should be sent as a binary or not. Default is autodetected.
   :param Boolean mask:  Specifies whether `data` should be masked or not. Defaults to `true` when `websocket` is not a server client.
   :param Boolean fin:  Specifies whether `data` is the last fragment of a message or not. Defaults to `true`.
   :param callback: Function An optional callback which is invoked when `data` is written out.

      Send `data` through the connection.

.. js:method:: websocket.terminate()

   Forcibly close the connection.

.. js:attribute:: websocket.url

   :rtype: String
   :return: The URL of the WebSocket server. Server clients don't have this attribute.

createWebSocketStream(websocket[, options])
------------------------------------------------

.. js:function:: createWebSocketStream(websocket[, options])

   :param WebSocket websocket: A WebSocket object.
   :param Object options: Options to pass to the Duplex constructor.
   :return: Returns a Duplex stream that allows to use the Node.js streams API on top of a given WebSocket.

WS Error Codes
--------------------

Errors emitted by the websocket may have a `.code` property, describing the specific type of error that has occurred:

.. js:data:: WS_ERR_EXPECTED_FIN

   A WebSocket frame was received with the FIN bit not set when it was expected.

.. js:data:: WS_ERR_EXPECTED_MASK

   An unmasked WebSocket frame was received by a WebSocket server.

.. js:data:: WS_ERR_INVALID_CLOSE_CODE

   A WebSocket close frame was received with an invalid close code.

.. js:data:: WS_ERR_INVALID_CONTROL_PAYLOAD_LENGTH

   A control frame with an invalid payload length was received.

.. js:data:: WS_ERR_INVALID_OPCODE

   A WebSocket frame was received with an invalid opcode.

.. js:data:: WS_ERR_INVALID_UTF8

   A text or close frame was received containing invalid UTF-8 data.

.. js:data:: WS_ERR_UNEXPECTED_MASK

   A masked WebSocket frame was received by a WebSocket client.

.. js:data:: WS_ERR_UNEXPECTED_RSV_1

   A WebSocket frame was received with the RSV1 bit set unexpectedly.

.. js:data:: WS_ERR_UNEXPECTED_RSV_2_3

   A WebSocket frame was received with the RSV2 or RSV3 bit set unexpectedly.

.. js:data:: WS_ERR_UNSUPPORTED_DATA_PAYLOAD_LENGTH

   A data frame was received with a length longer than the max supported length (2^53 - 1, due to JavaScript language limitations).

.. js:data:: WS_ERR_UNSUPPORTED_MESSAGE_LENGTH
   
A message was received with a length longer than the maximum supported length, as configured by the maxPayload option.


.. _concurrency-limit: https://github.com/websockets/ws/issues/1202
.. _permessage-deflate: https://tools.ietf.org/html/draft-ietf-hybi-permessage-compression-19
.. _zlib-options: https://nodejs.org/api/zlib.html#zlib_class_options
.. _http.request(): https://nodejs.org/api/http.html#http_http_request_options_callback
.. _https.request(): https://nodejs.org/api/https.html#https_https_request_options_callback
