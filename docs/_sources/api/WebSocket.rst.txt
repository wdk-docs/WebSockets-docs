.. _api_WebSocket:

WebSocket
==============

WebSocket 对象提供了用于创建和管理 WebSocket 连接，以及可以通过该连接发送和接收数据的 API。

构造函数
------------------

.. function:: WebSocket(url[, protocols])

   :returns: 返回一个 WebSocket 对象

常量
------------------

.. data:: WebSocket.CONNECTING

   0

.. data:: WebSocket.OPEN

   1

.. data:: WebSocket.CLOSING

   2

.. data:: WebSocket.CLOSED

   3

以上是WebSocket 构造函数的原型中存在的一些常量，可通过 WebSocket.readyState 对照上述常量判断 WebSocket 连接 当前所处的状态

属性
------------------

.. attribute:: WebSocket.binaryType

   使用二进制的数据类型连接

.. attribute:: WebSocket.bufferedAmount

   只读 未发送至服务器的字节数

.. attribute:: WebSocket.extensions

   只读 服务器选择的扩展

.. attribute:: WebSocket.onclose

   用于指定连接关闭后的回调函数

.. attribute:: WebSocket.onerror

   用于指定连接失败后的回调函数

.. attribute:: WebSocket.onmessage

   用于指定当从服务器接受到信息时的回调函数

.. attribute:: WebSocket.onopen

   用于指定连接成功后的回调函数

.. attribute:: WebSocket.protocol

   只读 服务器选择的下属协议

.. attribute:: WebSocket.readyState

   只读 当前的链接状态

.. attribute:: WebSocket.url

   只读

.. attribute:: WebSocket

   的绝对路径

方法
------------------

.. function:: WebSocket.close([code[, reason]])

   关闭当前链接

.. function:: WebSocket.send(data)

   向服务器发送数据

示例

.. code-block:: js

    // Create WebSocket connection.
    const socket = new WebSocket('ws://localhost:8080');

    // Connection opened
    socket.addEventListener('open', function (event) {
        socket.send('Hello Server!');
    });

    // Listen for messages
    socket.addEventListener('message', function (event) {
        console.log('Message from server ', event.data);
    });

规范
------------------

+--------------------------------+-----------------+----------+
|              规范              |      状态       |   注释   |
+================================+=================+==========+
| HTML Living Standard WebSocket | Living Standard | 初始定义 |
+--------------------------------+-----------------+----------+

浏览器兼容性
------------------

Update compatibility data on GitHub

另见
------------------

Writing WebSocket client applications
