WebSockets
=============

WebSockets 是一种先进的技术。它可以在用户的浏览器和服务器之间打开交互式通信会话。
使用此API，您可以向服务器发送消息并接收事件驱动的响应，而无需通过轮询服务器的方式以获得响应。

接口
-----------

- :ref:`api_WebSocket` 用于连接WebSocket服务器的主要接口，之后可以在这个连接上发送 和接受数据。
- :ref:`api_CloseEvent` 连接关闭时WebSocket对象发送的事件。
- :ref:`api_MessageEvent` 当从服务器获取到消息的时候WebSocket对象触发的事件。

工具
----------

- `HumbleNet`_: 一个在浏览器中工作的跨平台网络库。它由一个围绕websocket和WebRTC的C包装器组成，抽象了跨浏览器的差异，方便了为游戏和其它应用程序创建多用户网络功能。
- `µWebSockets`_:由C++11和Node.js 实现的高度可扩展的WebSocket服务器和客户端.。
- `ClusterWS`_:  轻量级、快速和强大的框架，用于在Node.js.中构建可伸缩的WebSocket应用程序。
- `Socket.IO`_: 一个基于长轮询/WebSocket的Node.js第三方传输协议。
- `SocketCluster`_: 一个用于Node.js的pub/sub专注于可伸缩 WebSocket框架。
- `WebSocket-Node`_: 一个用 Node.js实现WebSocket服务器API。
- `Total.js`_:一个用Node.js 实现的的Web应用程序框架（例如:WebSocket聊天）。
- `Faye`_: 一个 Node.js的WebSocket (双向连接)和 EventSource (单向连接)的服务器和客户端。
- `SignalR`_: SignalR在可用时将隐藏使用WebSockets，在不可用时将优雅地使用其他技术和技术，而应用程序代码保持不变。
- `Caddy`_: 能够将任意命令(stdin/stdout)代理为websocket的web服务器。
- `ws`_: 一个流行的WebSocket客户端和服务器 Node.js库。
- `jsonrpc-bidirectional`_: 易于使用异步RPC库，通过单个WebSocket或RTCDataChannel (WebRTC)连接支持双向调用。TCP / SCTP /等。客户端和服务器可以各自承载自己的JSONRPC和服务器端点。
- `rpc-websockets`_: JSON-RPC 2.0在websocket上实现Node.js和JavaScript。

.. _HumbleNet: https://hacks.mozilla.org/2017/06/introducing-humblenet-a-cross-platform-networking-library-that-works-in-the-browser/
.. _µWebSockets: https://github.com/uWebSockets/uWebSockets
.. _ClusterWS:  https://github.com/ClusterWS/ClusterWS
.. _Socket.IO: https://github.com/socketio/socket.io
.. _SocketCluster: http://socketcluster.io/
.. _WebSocket-Node: https://github.com/Worlize/WebSocket-Node
.. _Total.js: https://github.com/totaljs/framework
.. _Faye: https://github.com/faye/faye-websocket-node
.. _SignalR: http://signalr.net/
.. _Caddy: https://github.com/mholt/caddy
.. _ws: https://github.com/websockets/ws
.. _jsonrpc-bidirectional: https://github.com/bigstepinc/jsonrpc-bidirectional
.. _rpc-websockets: https://github.com/elpheria/rpc-websockets

相关话题
--------------

- AJAX
- JavaScript

参见
--------------

- RFC 6455 — The WebSocket Protocol
- WebSocket API Specification
- Server-Sent Events
