��    *      l              �     �     �  �   �      f  �   �     .  <   M      �     �  (   �  %   �  #     6   :  .   q     �  @   �  *   �     (  +   C  j   o  �   �     �  w   �       ,     *   <  K   g  �   �  5   g	  :   �	     �	     �	  2   �	     )
  !   C
     e
  M   ~
  j   �
     7     M     U  �  Z     �     �  �   �      �  �   �     L  <   k      �     �  (   �  %     #   4  6   X  .   �     �  @   �  *        F  +   a  j   �  �   �     �  w   �     &  ,   -  *   Z  K   �  �   �  5   �  :   �     �       2        G  !   a     �  M   �  j   �     U     k     s   *(Boolean)* **Returns** ``Socket`` An unique identifier for the socket session. Set after the ``connect`` event is triggered, and updated after the ``reconnect`` event. Disconnects the socket manually. Emits an event to the socket identified by the string name. Any other parameters can be included. All serializable datastructures are supported, including ``Buffer``. Fired upon a connection error. Fired upon a connection including a successful reconnection. Fired upon a connection timeout. Fired upon a disconnection. Fired upon a reconnection attempt error. Fired upon a successful reconnection. Fired upon an attempt to reconnect. Fired when a ping packet is written out to the server. Fired when a pong is received from the server. Fired when an error occurs. Fired when couldn’t reconnect within ``reconnectionAttempts``. It can also be used to manually reconnect: Manually opens the socket. Register a new handler for the given event. Sends a ``message`` event. See `socket.emit(eventName[, …args][,ack]) <#socketemiteventname-args-ack>`_. Sets a modifier for a subsequent event emission that the event data will only be *compressed* if the value is ``true``. Defaults to ``true`` when you don’t call the method. Socket Specifies whether the emitted data contains binary. Increases performance when specified. Can be ``true`` or ``false``. String Synonym of `socket.close() <#socketclose>`_. Synonym of `socket.open() <#socketopen>`_. The ``ack`` argument is optional and will be called with the server answer. The socket actually inherits every method of the `Emitter <https://github.com/component/emitter>`_ class, like ``hasListeners``, ``once`` or ``off`` (to remove an event listener). Whether or not the socket is connected to the server. Whether or not the socket is disconnected from the server. ``ack`` *(Function)* ``args`` ``attempt`` *(Number)* reconnection attempt number ``callback`` *(Function)* ``error`` *(Object)* error object ``eventName`` *(String)* ``ms`` *(Number)* number of ms elapsed since ``ping`` packet (i.e.: latency). ``reason`` *(String)* either ‘io server disconnect’, ‘io client disconnect’, or ‘ping timeout’ ``value`` *(Boolean)* example type Project-Id-Version: WebSockets Docs 
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2019-06-17 11:04+0800
PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language: zh_CN
Language-Team: zh_CN <LL@li.org>
Plural-Forms: nplurals=1; plural=0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Generated-By: Babel 2.6.0
 *(Boolean)* **Returns** ``Socket`` An unique identifier for the socket session. Set after the ``connect`` event is triggered, and updated after the ``reconnect`` event. Disconnects the socket manually. Emits an event to the socket identified by the string name. Any other parameters can be included. All serializable datastructures are supported, including ``Buffer``. Fired upon a connection error. Fired upon a connection including a successful reconnection. Fired upon a connection timeout. Fired upon a disconnection. Fired upon a reconnection attempt error. Fired upon a successful reconnection. Fired upon an attempt to reconnect. Fired when a ping packet is written out to the server. Fired when a pong is received from the server. Fired when an error occurs. Fired when couldn’t reconnect within ``reconnectionAttempts``. It can also be used to manually reconnect: Manually opens the socket. Register a new handler for the given event. Sends a ``message`` event. See `socket.emit(eventName[, …args][,ack]) <#socketemiteventname-args-ack>`_. Sets a modifier for a subsequent event emission that the event data will only be *compressed* if the value is ``true``. Defaults to ``true`` when you don’t call the method. Socket Specifies whether the emitted data contains binary. Increases performance when specified. Can be ``true`` or ``false``. String Synonym of `socket.close() <#socketclose>`_. Synonym of `socket.open() <#socketopen>`_. The ``ack`` argument is optional and will be called with the server answer. The socket actually inherits every method of the `Emitter <https://github.com/component/emitter>`_ class, like ``hasListeners``, ``once`` or ``off`` (to remove an event listener). Whether or not the socket is connected to the server. Whether or not the socket is disconnected from the server. ``ack`` *(Function)* ``args`` ``attempt`` *(Number)* reconnection attempt number ``callback`` *(Function)* ``error`` *(Object)* error object ``eventName`` *(String)* ``ms`` *(Number)* number of ms elapsed since ``ping`` packet (i.e.: latency). ``reason`` *(String)* either ‘io server disconnect’, ‘io client disconnect’, or ‘ping timeout’ ``value`` *(Boolean)* example type 