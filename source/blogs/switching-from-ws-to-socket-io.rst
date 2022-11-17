从ws切换到socket.io
====================================

`Switching from ws to socket.io <https://medium.com/@toshvelaga/switching-from-ws-to-socket-io-d66343ca900d>`_

.. image:: https://miro.medium.com/max/1400/1*ZWJXXd2QmNltOWbILH32mg.webp
   :alt: stock image from unsplash on ws

我最初在Node服务器上使用ws和React前端的原生websockets实现构建了我的SaaS应用程序。
我这么做是因为我有在初创公司使用原生实现的经验，所以我认为使用我最舒服的方式会更快。
本机实现工作得很好，但问题是，我可以在网上找到的每个例子都使用socket.io。
事实是 *socket.io* 仍然非常受欢迎，几乎每个在线的开源webRTC项目都使用socket.io。
我没有从头开始构建所有的东西，而是决定构建这个优秀的 `开源回购 <https://github.com/0x5eba/Video-Meeting>`_，它使用 *socket.io* 来加快开发时间。
此外， *socket.io* 还有一些优点，比如很棒的文档、大型社区、检查连接是否完好的 `心跳 <https://stackoverflow.com/questions/7061362/advantage-disadvantage-of-using-socketio-heartbeats>`_，以及在需要创建房间并向连接的客户端 `发送消息 <https://socket.io/docs/v3/broadcasting-events/>`_ 时可以加快开发速度的内置方法。

移植我的应用并不困难，我遇到的唯一问题是，我的应用再次在本地运行，但在生产环境中无法运行。
我必须做一些配置才能让它在生产环境中工作，这涉及到编辑我的Nginx配置。

在服务器端，设置非常简单。
下面是我在服务器上的新套接字设置:

.. code-block:: ts
   :caption: OLD WS INITIALIZATION 

    
    const wss = new WebSocket.Server({ port: WS_PORT }, () => {
        console.log(`Listening on PORT ${WS_PORT} for websockets`)
    })

.. code-block:: ts
   :caption: NEW SOCKET.IO INITIALIZATION

    const io = new Server(WS_PORT, {
        /* options */
        cors: {
            origin: '*',
        },
    })

在客户端这里是我的主要逻辑发生在一个useEffect钩子。
socket.io的一个独特之处在于，它首先通过HTTP长轮询建立连接，然后升级到websocket连接。
从 `文档 <https://socket.io/docs/v3/how-it-works/>`_ 中可以更详细地了解它是如何工作的。
所以我不能让它像这样工作，所以我添加了一个选项，只使用websockets，不使用任何HTTP长轮询。
这就是为什么你会在代码中看到 ``{transports: [' websocket ']}``。

.. image:: https://miro.medium.com/max/1400/1*vVSMG1rcwhmw1Ze6W8HOwg.webp
   :alt: From the socket.io docs. HTTP long polling → websockets

.. code-block:: js

    useEffect(() => {
    socket.current =
      process.env.NODE_ENV === 'production'
        ? io(productionWsUrl + streamUrlParams, { transports: ['websocket'] })
        : io(developmentWsUrl + streamUrlParams, { transports: ['websocket'] })

    socket.current.on('connect', () => {
      // either with send()
      console.log('WebSocket Open')
    })

    return () => {
      socket.current.on('disconnect', () => {
        console.log('close the socket') // undefined
      })
    }
  }, [
    facebookUrl,
    youtubeUrl,
    twitchStreamKey,
    customRtmpServer,
    customRtmpStreamKey,
  ])

我必须做的最后一件事是更改我的Nginx配置，因为我在AWS EC2上运行我的服务器。
这是我更新的Nginx服务器块。

.. code-block:: Nginx

    # Requests for socket.io are passed on to Node on port 3001
    location ~* \.io {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy false;

        proxy_pass http://localhost:3001;
        proxy_redirect off;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

总的来说，从ws切换到套接字io是相当容易的。
*socket.io* 显然增加了更多的开销，但是它有很棒的文档和社区支持。
此外， *socket.io* 比普通的websockets更容易水平扩展，并且有一些内置的方法可以使向每个连接的客户端广播消息更简单。
尽管如此，还是有 `明显的缺点 <https://dzone.com/articles/socketio-the-good-the-bad-and-the-ugly>`_。
要了解更详细的对比，请查看这篇优秀的 `博客文章 <https://itnext.io/differences-between-websockets-and-socket-io-a9e5fa29d3dc>`_。
至于我的项目，我希望使用 *socket.io* 继续加速开发。
希望这篇文章对你有帮助。
如果是这样，就鼓掌吧:)