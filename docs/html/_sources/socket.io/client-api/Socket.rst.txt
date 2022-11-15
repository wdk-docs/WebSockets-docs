
Socket
======

.. attribute:: socket.id

   An unique identifier for the socket session. Set after the ``connect``
   event is triggered, and updated after the ``reconnect`` event.

   :type: String
   :example:
    .. code:: js

      const socket = io('http://localhost');

      console.log(socket.id); // undefined

      socket.on('connect', () => {
        console.log(socket.id); // 'G5p5...'
      });

.. attribute:: socket.connected

   -  *(Boolean)*

   Whether or not the socket is connected to the server.

   .. code:: js

      const socket = io('http://localhost');

      socket.on('connect', () => {
        console.log(socket.connected); // true
      });

   .. attribute:: socket.disconnected

   -  *(Boolean)*

   Whether or not the socket is disconnected from the server.

   .. code:: js

      const socket = io('http://localhost');

      socket.on('connect', () => {
        console.log(socket.disconnected); // false
      });

.. function:: socket.open()

   -  **Returns** ``Socket``

   Manually opens the socket.

   .. code:: js

      const socket = io({
        autoConnect: false
      });

      // ...
      socket.open();

   It can also be used to manually reconnect:

   .. code:: js

      socket.on('disconnect', () => {
        socket.open();
      });

.. function:: socket.connect()

   Synonym of `socket.open() <#socketopen>`_.

.. function:: socket.send([…args][, ack])

   -  ``args``
   -  ``ack`` *(Function)*
   -  **Returns** ``Socket``

   Sends a ``message`` event. See `socket.emit(eventName[, …args][,ack]) <#socketemiteventname-args-ack>`_.

.. function:: socket.emit(eventName[, …args][, ack])

   -  ``eventName`` *(String)*
   -  ``args``
   -  ``ack`` *(Function)*
   -  **Returns** ``Socket``

   Emits an event to the socket identified by the string name. Any other
   parameters can be included. All serializable datastructures are
   supported, including ``Buffer``.

   .. code:: js

      socket.emit('hello', 'world');
      socket.emit('with-binary', 1, '2', { 3: '4', 5: new Buffer(6) });

   The ``ack`` argument is optional and will be called with the server
   answer.

   .. code:: js

      socket.emit('ferret', 'tobi', (data) => {
        console.log(data); // data will be 'woot'
      });

      // server:
      //  io.on('connection', (socket) => {
      //    socket.on('ferret', (name, fn) => {
      //      fn('woot');
      //    });
      //  });

.. function:: socket.on(eventName, callback)

   -  ``eventName`` *(String)*
   -  ``callback`` *(Function)*
   -  **Returns** ``Socket``

   Register a new handler for the given event.

   .. code:: js

      socket.on('news', (data) => {
        console.log(data);
      });

      // with multiple arguments
      socket.on('news', (arg1, arg2, arg3, arg4) => {
        // ...
      });
      // with callback
      socket.on('news', (cb) => {
        cb(0);
      });

   The socket actually inherits every method of the `Emitter <https://github.com/component/emitter>`_ class, like ``hasListeners``, ``once`` or ``off`` (to remove an event listener).

.. function:: socket.compress(value)

   -  ``value`` *(Boolean)*
   -  **Returns** ``Socket``

   Sets a modifier for a subsequent event emission that the event data will
   only be *compressed* if the value is ``true``. Defaults to ``true`` when
   you don’t call the method.

   .. code:: js

      socket.compress(false).emit('an event', { some: 'data' });

.. function:: socket.binary(value)

   Specifies whether the emitted data contains binary. Increases
   performance when specified. Can be ``true`` or ``false``.

   .. code:: js

      socket.binary(false).emit('an event', { some: 'data' });

.. function:: socket.close()

   -  **Returns** ``Socket``

   Disconnects the socket manually.

.. function:: socket.disconnect()

   Synonym of `socket.close() <#socketclose>`_.

.. function:: Event: ‘connect’

   Fired upon a connection including a successful reconnection.

   .. code:: js

      socket.on('connect', () => {
        // ...
      });

      // note: you should register event handlers outside of connect,
      // so they are not registered again on reconnection
      socket.on('myevent', () => {
        // ...
      });

.. _event-connect_error-1:

.. function:: Event: ‘connect_error’

   -  ``error`` *(Object)* error object

   Fired upon a connection error.

   .. code:: js

      socket.on('connect_error', (error) => {
        // ...
      });

.. _event-connect_timeout-1:

.. function:: Event: ‘connect_timeout’

   Fired upon a connection timeout.

   .. code:: js

      socket.on('connect_timeout', (timeout) => {
        // ...
      });

.. function:: Event: ‘error’

   -  ``error`` *(Object)* error object

   Fired when an error occurs.

   .. code:: js

      socket.on('error', (error) => {
        // ...
      });

.. function:: Event: ‘disconnect’

   -  ``reason`` *(String)* either ‘io server disconnect’, ‘io client disconnect’, or ‘ping timeout’

   Fired upon a disconnection.

   .. code:: js

      socket.on('disconnect', (reason) => {
        if (reason === 'io server disconnect') {
          // the disconnection was initiated by the server, you need to reconnect manually
          socket.connect();
        }
        // else the socket will automatically try to reconnect
      });

.. _event-reconnect-1:

.. function:: Event: ‘reconnect’

   -  ``attempt`` *(Number)* reconnection attempt number

   Fired upon a successful reconnection.

   .. code:: js

      socket.on('reconnect', (attemptNumber) => {
        // ...
      });

.. _event-reconnect_attempt-1:

.. function:: Event: ‘reconnect_attempt’

   -  ``attempt`` *(Number)* reconnection attempt number

   Fired upon an attempt to reconnect.

   .. code:: js

      socket.on('reconnect_attempt', (attemptNumber) => {
        // ...
      });

.. _event-reconnecting-1:

.. function:: Event: ‘reconnecting’

   -  ``attempt`` *(Number)* reconnection attempt number

   Fired upon an attempt to reconnect.

   .. code:: js

      socket.on('reconnecting', (attemptNumber) => {
        // ...
      });

.. _event-reconnect_error-1:

.. function:: Event: ‘reconnect_error’

   -  ``error`` *(Object)* error object

   Fired upon a reconnection attempt error.

   .. code:: js

      socket.on('reconnect_error', (error) => {
        // ...
      });

.. _event-reconnect_failed-1:

.. function:: Event: ‘reconnect_failed’

   Fired when couldn’t reconnect within ``reconnectionAttempts``.

   .. code:: js

      socket.on('reconnect_failed', () => {
        // ...
      });

.. _event-ping-1:

.. function:: Event.ping

   Fired when a ping packet is written out to the server.

   .. code:: js

      socket.on('ping', () => {
        // ...
      });

.. _event-pong-1:

.. function:: Event.pong

   -  ``ms`` *(Number)* number of ms elapsed since ``ping`` packet (i.e.: latency).

   Fired when a pong is received from the server.

   .. code:: js

      socket.on('pong', (latency) => {
        // ...
      });
