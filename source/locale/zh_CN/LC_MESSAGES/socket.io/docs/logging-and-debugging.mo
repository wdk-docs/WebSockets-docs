��          t               �   �   �      �  �   �     �  �   �  2  z  F   �  :   �  5   /     e  �  x  �   �     �  �   �     �  �   �    V	  3   _
  =   �
  9   �
        And then filter by the scopes you’re interested in. You can prefix the ``*`` with scopes, separated by comma if there is more than one. For example, to only see debug statements from the socket.io client on Node.js try this: Available debugging scopes Before 1.0, the Socket.IO server would default to logging everything out to the console. This turned out to be annoyingly verbose for many users (although extremely useful for others), so now we default to being completely silent by default. Logging and debugging Socket.IO is now completely instrumented by a minimalistic yet tremendously powerful utility called `debug <https://github.com/visionmedia/debug>`_ by TJ Holowaychuk. The basic idea is that each module used by Socket.IO provides different debugging scopes that give you insight into the internals. By default, all output is suppressed, and you can opt into seeing messages by supplying the ``DEBUG`` env variable (Node.JS) or the ``localStorage.debug`` property (Browsers). The best way to see what information is available is to use the ``*``: To see all debug messages from the engine *and* socket.io: You can see it in action for example on our homepage: or in the browser: Project-Id-Version: WebSockets Docs 
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2019-06-13 20:53+0800
PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE
Last-Translator: FULL NAME <EMAIL@ADDRESS>
Language: zh_CN
Language-Team: zh_CN <LL@li.org>
Plural-Forms: nplurals=1; plural=0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Generated-By: Babel 2.6.0
 然后按照你感兴趣的范围进行过滤.你可以在 ``*`` 前加上范围,如果有多个则用逗号分隔.例如,要仅从Node.js上的socket.io客户端查看调试语句,请尝试以下操作： 可用的调试范围 在1.0之前,Socket.IO服务器将默认将所有内容记录到控制台.对于许多用户来说这很烦人(尽管对其他用户非常有用),所以现在我们默认默认情况下是完全无声的. 记录和调试 Socket.IO现在完全由一个名为 `debug <https://github.com/visionmedia/debug>`_ 的简约但功能强大的实用工具配备,由TJ Holowaychuk提供. 基本思想是Socket.IO使用的每个模块都提供不同的调试范围,使您可以深入了解内部.默认情况下,所有输出都被抑制,您可以通过提供 ``DEBUG`` env变量(Node.JS)或 ``localStorage.debug`` 属性(浏览器)来选择查看消息. 查看可用信息的最佳方法是使用 ``*``： 要查看来自引擎 *和* socket.io的所有调试消息： 您可以在我们的主页上看到它的实际效果： 或在浏览器中： 