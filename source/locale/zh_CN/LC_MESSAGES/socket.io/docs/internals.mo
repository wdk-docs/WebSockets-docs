��    5      �              l  �   m  T   ^  
   �     �  ,   �     �  	   |  T   �  �   �  h   f  h   �  �   8  �   ,  1  �  =   �	  F   
     d
  d   �
  �   �
  �   �  �   @  �   +  6     �   F          )  @   1  �   r  >     	   R     \     m  %   ~  ,   �  ,   �  %   �  -   $  ,   R  ,     +   �  B   �  	        %     7     H     Y  L   i  '   �  6   �  J     r   `  �   �  �  U  �   �  X   �       	     (   (  S   Q     �  ;   �  �   �  g   m  g   �  �   =  n   	  �   x  .   o  +   �     �  T   �  �   3  r   �  �   b  �   '  +   �  �        �     �  8   �  �   !   5   �   	   �      �      !  %   !  ,   9!  ,   f!  %   �!  -   �!  ,   �!  ,   "  +   A"  >   m"  	   �"     �"     �"     �"     �"  @   �"      ;#  )   \#  8   �#  W   �#  a   $   A socket.io encoder and decoder written in JavaScript complying with version 3 of `socket.io-protocol <>`_. Used by `socket.io <https://github.com/socketio/socket.io>`_ and `socket.io-client <https://github.com/socketio/socket.io-client>`_. By default, it exposes a browser build of the client at ``/socket.io/socket.io.js``. Connection Dependency graph Each project brings its own set of features: Engine.IO is the implementation of transport-based cross-browser/cross-device bi-directional communication layer for Socket.IO. Internals It handles reconnection automatically, in case the underlying connection is severed. It runs in both the browser (including HTML5 `WebWorker <https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API>`_) and Node.js. It uses the `engine.io-parser <https://github.com/socketio/engine.io-parser>`_ to encode/decode packets. It uses the `socket.io-parser <https://github.com/socketio/socket.io-parser>`_ to encode/decode packets. Its main feature is the ability to swap transports on the fly. A connection (initiated by an `engine.io-client <https://github.com/socketio/engine.io-client>`_ counterpart) starts with XHR polling, but can then switch to WebSocket if possible. Once all the buffers of the existing transport (XHR polling) are flushed, an upgrade gets tested on the side by sending a probe. Socket.IO brings some *syntactic sugar* over the Engine.IO “raw” API. It also brings two new concepts, ``Rooms`` and ``Namespaces``, which introduce a separation of concern between communication channels. Please see the associated documentation `there <https://socket.io/docs/rooms-and-namespaces/>`_. The Socket.IO codebase is split accross several repositories: The following diagram displays the relationships between each project: The following steps take place: The specification for the protocol can be found here: https://github.com/socketio/engine.io-protocol This is the JavaScript parser for the engine.io protocol encoding, shared by both `engine.io-client <https://github.com/socketio/engine.io-client>`_ and `engine.io <https://github.com/socketio/engine.io>`_. This is the adapter using the Redis `Pub/Sub <https://redis.io/topics/pubsub>`_ mechanism to broadcast messages between multiple nodes. This is the client for `Engine.IO <https://github.com/socketio/engine.io>`_, the implementation of transport-based cross-browser/cross-device bi-directional communication layer for `Socket.IO <https://github.com/socketio/socket.io>`_. This is the client for `Socket.IO <https://github.com/socketio/socket.io>`_. It relies on `engine.io-client <https://github.com/socketio/engine.io-client>`_, which manages the transport swapping and the disconnection detection. This is the default Socket.IO in-memory adapter class. This module is not intended for end-user usage, but can be used as an interface to inherit from from other adapters you might want to build, like `socket.io-redis <https://github.com/socketio/socket.io-redis>`_. Under the hood Upgrade a ``connect`` event is emitted at the ``socket.io-client`` level a “ping” packet is sent by the client in a WebSocket frame, encoded as ``2probe`` by the ``engine.io-parser``, with ``2`` being the “ping” message type. an ``open`` event is emitted at the ``engine.io-client`` level engine.io engine.io-client engine.io-parser https://github.com/socketio/engine.io https://github.com/socketio/engine.io-client https://github.com/socketio/engine.io-parser https://github.com/socketio/socket.io https://github.com/socketio/socket.io-adapter https://github.com/socketio/socket.io-client https://github.com/socketio/socket.io-parser https://github.com/socketio/socket.io-redis on the client-side, a new ``engine.io-client`` instance is created socket.io socket.io-adapter socket.io-client socket.io-parser socket.io-redis the ``engine.io-client`` instance tries to establish a ``polling`` transport the ``engine.io`` server responds with: the content is encoded by the ``engine.io-parser`` as: the content is then decoded by the ``engine.io-parser`` on the client-side the server responds with a “pong” packet, encoded as ``3probe``, with ``3`` being the “pong” message type. upon receiving the “pong” packet, the upgrade is considered complete and all following messages go through the new transport. Project-Id-Version: WebSockets Docs 
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2019-06-14 12:18+0800
PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language: zh_CN
Language-Team: zh_CN <LL@li.org>
Plural-Forms: nplurals=1; plural=0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Generated-By: Babel 2.6.0
 用JavaScript编写的socket.io编码器和解码器,符合 `socket.io-protocol <>`_ 的版本3.由 `socket.io <https://github.com/socketio/socket.io>`_ 和 `socket.io-client <https://github.com/socketio/socket.io-client>`_ 使用. 默认情况下,它在 ``/socket.io/socket.io.js`` 中公开客户端的浏览器版本. 连接 依赖图 每个项目都有自己的一套功能: Engine.IO是为Socket.IO实现基于传输的跨浏览器/跨设备双向通信层. 内幕 它会自动处理重新连接,以防底层连接被切断. 它在浏览器中运行（包括HTML5 `WebWorker <https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API>`_）和Node.js. 它使用 `engine.io-parser <https://github.com/socketio/engine.io-parser>`_ 来编码/解码数据包. 它使用 `socket.io-parser <https://github.com/socketio/socket.io-parser>`_ 来编码/解码数据包. 它的主要特点是能够即时交换传输.连接(由 `engine.io-client <https://github.com/socketio/engine.io-client>`_ 对应方启动)以XHR轮询开始,但如果可能,则可以切换到WebSocket. 一旦刷新了现有传输的所有缓冲区（XHR轮询）,就会通过发送探测器在侧面测试升级. Socket.IO为Engine.IO“raw”API带来了一些*语法糖*.它还带来了两个新概念, ``Rooms`` 和 ``Namespaces``,它们引入了沟通渠道之间的关注点.请参阅相关文档 `那里 <https://socket.io/docs/rooms-and-namespaces/>`_. Socket.IO代码库分布在几个存储库中: 下图显示了每个项目之间的关系: 执行以下步骤: 协议的规范可以在这里找到: https://github.com/socketio/engine.io-protocol 这是engine.io协议编码的JavaScript解析器,由 `engine.io-client <https://github.com/socketio/engine.io-client>`_ 和 `engine.io <https：/共享/github.com/socketio/engine.io>`_ . 这是使用Redis `Pub/Sub <https://redis.io/topics/pubsub>`_ 机制在多个节点之间广播消息的适配器. 这是 `Engine.IO <https://github.com/socketio/engine.io>`_ 的客户端,用于 `Socket.IO的基于传输的跨浏览器/跨设备双向通信层的实现 <https://github.com/socketio/socket.io>`_ 这是 `Socket.IO <https://github.com/socketio/socket.io>`_ 的客户端.它依赖于 `engine.io-client <https://github.com/socketio/engine.io-client>`_ ,它管理传输交换和断开连接检测. 这是默认的Socket.IO内存适配器类. 此模块不适合最终用户使用,但可以用作从您可能要构建的其他适配器继承的接口,例如 `socket.io-redis <https://github.com/socketio/socket. IO-redis的>`_. 在引擎盖下 升级 在 ``socket.io-client`` 级别发出 ``connect`` 事件 客户端在WebSocket框架中发送“ping”数据包,由 ``engine.io-parser`` 编码为 ``2probe``,其中 ``2`` 为 “ping” 消息类型. 在 ``engine.io-client`` 级别发出 ``open`` 事件 engine.io engine.io-client engine.io-parser https://github.com/socketio/engine.io https://github.com/socketio/engine.io-client https://github.com/socketio/engine.io-parser https://github.com/socketio/socket.io https://github.com/socketio/socket.io-adapter https://github.com/socketio/socket.io-client https://github.com/socketio/socket.io-parser https://github.com/socketio/socket.io-redis 在客户端,创建了一个新的 ``engine.io-client`` 实例 socket.io socket.io-adapter socket.io-client socket.io-parser socket.io-redis ``engine.io-client`` 实例尝试建立一个 ``polling`` 传输 ``engine.io`` 服务器响应： 内容由 ``engine.io-parser`` 编码为: 然后,内容由客户端的 ``engine.io-parser`` 解码 服务器以“pong”包响应,编码为“3probe”,“3”为“pong”消息类型. 收到“pong”数据包后,升级将被视为已完成,所有后续消息都将通过新传输. 