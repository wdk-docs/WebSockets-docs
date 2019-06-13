.. _api_MessageEvent:

MessageEvent
==============

MessageEvent 是接口代表一段被目标对象接收的消息。

用来代表下列情况的消息

- Server-sent events (参见 :attr:`EventSource.onmessage`).
- Web sockets (参见 :attr:`WebSocket.onmessage` 属性).
- Cross-document messaging (参见 Window.postMessage() 和 Window.onmessage).
- Channel messaging (参见 MessagePort.postMessage() 和MessagePort.onmessage).
- Cross-worker/document messaging (参见上面两个入口, 还有 Worker.postMessage(), Worker.onmessage, ServiceWorkerGlobalScope.onmessage, 等等.)
- Broadcast channels (参见 Broadcastchannel.postMessage()) 和 BroadcastChannel.onmessage).
- WebRTC data channels (参见 RTCDataChannel.onmessage).

通过这个事件触发的动作被定义为一个函数，该函数作为相关message事件 (例如使用前文所列的onmessage 处理器)的事件处理器。

.. note:: 此特性在 Web Worker 中可用。

构造函数
-----------------

.. function:: MessageEvent()

   创建一个新的 **消息事件** 。

属性
--------------

继承其父类 Event 的属性。

.. attribute:: MessageEvent.data

   只读 返回 DOMString, Blob 或者 ArrayBuffer，包含来自发送者的数据。

.. attribute:: MessageEvent.origin

   返回一个表示消息发送者来源的USVString

.. attribute:: MessageEvent.lastEventId

   只读 DOMString representing a unique ID for the event.

.. attribute:: MessageEvent.source

   MessageEventSource (可以是 WindowProxy, MessagePort, 或 ServiceWorker 对象) 代表消息发送者.

.. attribute:: MessageEvent.ports

   MessagePort对象数组，表示消息正通过特定通道（数据通道）发送的相关端口（适用于通道消息传输或者向一个共享线程（shared work ）发送消息时）。

方法
---------------

继承父类 Event 的方法。

.. function:: MessageEvent.initMessageEvent()

   … 不要再使用: 使用 :func:`MessageEvent()`。


示例
-------------

在我们的基础共享线程示例 Basic shared worker example (run shared worker)中,我们有两个HTML页, 每一页都用简单的js代码去执行简单的计算. 不同的脚本使用同一个worker文件去执行计算 — 它们都可以访问那个worker文件，即使它们（scripts）运行在不同的窗口.

下面的代码片段展示了使用SharedWorker()构造器创建一个 SharedWorker对象。


.. code-block::

   var myWorker = new SharedWorker('worker.js');

接下来两份脚本通过一个SharedWorker.port方法创建的MessagePort对象访问worker。如果onmessage事件通过addEventListener被绑定，端口可以用start()方法手动开启：

.. code-block::

   myWorker.port.start();

当端口被打开，两份脚本各自都可用 port.postMessage() 向worker传消息并用  port.onmessage处理它（worker）传来的消息:

.. code-block::

   first.onchange = function() {
     myWorker.port.postMessage([first.value,second.value]);
     console.log('Message posted to worker');
   }
   second.onchange = function() {
     myWorker.port.postMessage([first.value,second.value]);
     console.log('Message posted to worker');
   }
   myWorker.port.onmessage = function(e) {
     result1.textContent = e.data;
     console.log('Message received from worker');
   }

在worker内部我们使用SharedWorkerGlobalScope.onconnect 处理器来连接前文说到相同端口. 与worker相关联的端口可以在connect事件的ports 属性中访问到 — 接着我们使用MessagePort start() 方法打开端口,  onmessage 处理器来处理主线程传来的消息。


.. code-block::

   onconnect = function(e) {
     var port = e.ports[0];

     port.addEventListener('message', function(e) {
       var workerResult = 'Result: ' + (e.data[0] * e.data[1]);
       port.postMessage(workerResult);
     });

     port.start(); // Required when using addEventListener. Otherwise called implicitly by onmessage setter.
   }

规范
-------------

+-----------------------------------+------------------------+---------+
|           Specification           |         Status         | Comment |
+===================================+========================+=========+
| HTML Living Standard MessageEvent | ``LS`` Living Standard |         |
+-----------------------------------+------------------------+---------+

浏览器兼容性

参见
---------

- ExtendableMessageEvent，与此接口类似，但适合用于更灵活的场景。
- WebSocket API
- WebRTC API
