使用 NestJs 和 Redis 实现 WebSocket 集群
=============================================

https://medium.com/@mohsenes/websocket-cluster-with-nestjs-and-redis-a18882d418ed

扩展是后端应用程序生活中不可避免的一部分，一旦你决定将你的应用程序扩展到多个实例，
你将面临处理多个客户端(手机、笔记本电脑等)的用户的问题，每个客户端都连接到你集群的一个随机实例。

在本文中，我们将定义这个问题，并使用NestJs和Redis围绕它制定解决方案。

要求
-----------------

- 有使用Nodejs和NestJs的经验
- 安装Nodejs
- 安装了NestJs CLI
- 安装Redis

存在的问题
-----------------

在WebSocket上发出的消息需要在连接到我们实例的接收方的每个设备上发送。

解决方案
-----------------

我们将处理消息到多个实例使用Redis PubSub流。
为了在NestJs上完成这一点，我们将创建一个名为socket module的模块。
我们将设置一个网关来处理套接字客户端，并设置一个服务来进行发现和连接到Redis并分发消息。

我们将用循序渐进的指南来介绍这一点。
将NestJs CLI安装为一个全局包

.. code:: sh

    # run with sudo if you are on ubuntu
    npm i -g @nestjs/cli

创建新的NestJS项目，依赖项也将通过此命令通过向导安装

.. code:: sh

    nest g socket-cluster-app

生成我们讨论的Socket模块

.. code:: sh

    # go into project folder
    cd socket-cluster-app/
    # generate socket module
    nest g module socket
    # generate socket service
    nest g service socket
    # generate socket gateway
    nest g gateway socket/socket

使用 `nest g` 命令会自动将你的服务和套接字添加到相应的模块中

安装WebSocket适配器

.. code:: sh

    npm i @nestjs/platform-ws
    npm i @nestjs/websockets

在 `main.ts` 文件中注册适配器

.. code-block:: ts
   :caption:  main.ts
    
    import { NestFactory } from '@nestjs/core';
    import { WsAdapter } from '@nestjs/platform-ws';
    import { AppModule } from './app.module';

    async function bootstrap() {
        const app = await NestFactory.create(AppModule);
        // register adapter
        app.useWebSocketAdapter(new WsAdapter(app) as any);
        await app.listen(parseInt(process.env['PORT'] , 10) || 3000);
    }
    bootstrap();

然后，我们将在 ``handleConnection`` 调用中标识每个套接字，并将 ``userId`` 属性放入每个客户机。
在本例中，我们将通过客户端发送的令牌 ``cookie`` 设置 ``userId``。
在实际示例中，您需要验证令牌并通过查询数据库或某些身份验证服务将 ``userId`` 分配给客户机。

.. code-block:: ts
   :caption: src/socket.gateway.ts

    import { OnGatewayConnection, OnGatewayDisconnect, WebSocketGateway } from '@nestjs/websockets';

    @WebSocketGateway()
    export class SocketGateway implements OnGatewayConnection, OnGatewayDisconnect {
    
        public connectedSockets: { [key: string]: any[] } = {};

        async handleConnection(client: any, req: Request) {
            try {
                const token = req.headers['cookie']
                    .split(';')
                    .map(p => p.trim())
                    .find(p => p.split('=')[0] === 'token')
                    .split('=')[1];

                // for this example, we simply set userId by token
                client.userId = token;

                if (!this.connectedSockets[client.userId])
                    this.connectedSockets[client.userId] = [];

                this.connectedSockets[client.userId].push(client);
            } catch (error) {
                client.close(4403, 'set JWT cookie to authenticate');
            }
        }

        handleDisconnect(client: any) {
            this.connectedSockets[client.userId] = this.connectedSockets[client.userId].filter(p => p.id !== client.id);
        }
    }


现在我们需要实现套接字服务，我们需要一个Redis包来在实例之间分发消息。

.. code:: sh

    npm i redis
    npm i --save-dev @types/redis

套接字服务将有多个功能

- ``constructor``, 第0步是在构造函数方法中为我们的服务分配一个随机id，并注入我们在最后一步中实现的“SocketGateWay”。

  .. code-block:: ts
     :caption: src/main.ts

     constructor(private readonly socketGateway: SocketGateway) {
        this.serviceId = 'SOCKET_CHANNEL_' + Math.random().toString(26).slice(2);
     }

- ``onModuleInit``: 此外，我们在套接字服务中实现 ``onModuleInit`` 功能，它将创建并连接到3个Redis客户端。

    - ``redisClient`` 用于通过发现通道更新服务密钥
    - ``subscriberClient`` 获取分布式消息
    - ``publisherClient`` 将消息分发到其他实例


    .. code-block:: ts
        :caption: src/socket/socket.service.ts

        async onModuleInit() {
            this.redisClient = await this.newRedisClient();
            this.subscriberClient = await this.newRedisClient();
            this.publisherClient = await this.newRedisClient();

            this.subscriberClient.subscribe(this.serviceId);

            this.subscriberClient.on('message', (channel, message) => {
                const { userId, payload } = JSON.parse(message);
                this.sendMessage(userId, payload, true);
            });

            await this.channelDiscovery();
        }
        
        private async newRedisClient() {
            return createClient({
                host: 'localhost',
                port: 6379,
            });
        }

    .. note::
        createClient从“redis”包中导入

- ``channelDiscovery``: 将在Redis上保存其serviceId，过期时间为3秒。
  它还将开始自重复超时，每2秒重新执行一次。
  这样，所有实例都可以访问更新后的套接字服务列表，以便分发消息。
  在测试此服务时，清除发现间隔超时是防止打开处理程序问题的好方法。

 
    .. code-block:: ts
        :caption: src/socket/socket.service.ts

        private async channelDiscovery() {
            this.redisClient.setex(this.serviceId, 3, Date.now().toString());
            this.discoveryInterval = setTimeout(() => {
                this.channelDiscovery();
            }, 2000);
        }

        async onModuleDestroy() {
            this.discoveryInterval && clearTimeout(this.discoveryInterval);
        }



- ``sendMessage`` 最后一步是向特定用户的每个连接的客户端发送消息。我们将消息发送到连接的客户端，并将此消息分发到其他实例。 ``if(!fromRedisChannel)`` 将阻止在消息已经被另一个实例分发的情况下分发。

    .. code-block:: ts
        :caption: src/socket/socket.service.ts

        async sendMessage(userId: string, payload: string,fromRedisChannel: boolean) {
            this.socketGateway.connectedSockets[userId]?.forEach(socket =>
                socket.send(payload),
            );
            if (!fromRedisChannel) {
                this.redisClient.keys('SOCKET_CHANNEL_', (err, ids) => {
                    ids.filter(p => p != this.serviceId).forEach(id => {
                        this.publisherClient.publish(
                            id,
                            JSON.stringify({
                                payload,
                                userId,
                            }),
                        );
                    });
                });
            }
        }

测试场景
----------

好了，我们完成了，现在我们可以设置我们的测试场景了。

首先，我们将创建一个简单的测试脚本，该脚本将连接到我们的一个实例并打印接收到的消息。

运行 ``npm i ws`` 安装 ``ws`` 包

.. code-block:: sh

    const ws = require('ws');
    const port = 3001;
    const socket = new ws(`ws://localhost:${port}`, {
        headers: { Cookie: 'token=user1' },
    });
    socket.on('message', data => {
        console.log(`Received message`, data);
    });
    socket.on('open', data => {
        console.log(`Connected to port ${port}`);
    });
    socket.on('close', data => {
        console.log(`Disconnected from port ${port}`);
    });

然后向套接字服务添加一个简单的间隔，用于向user1发送时间。

最后，依次运行以下命令

.. code:: sh

    PORT=3001 npm start
    PORT=3002 npm start
    node test-script.js

测试脚本应该每3秒记录一个来自两个实例的消息。

.. code:: sh

    # output
    Received message 8:21:55 AM | from server on port 3001
    Received message 8:21:57 AM | from server on port 3002

这表明，现在我们的服务能够将来自不同实例的WebSocket消息分发到特定的客户机。

我们在本文中所做的工作的完整示例可以在 https://github.com/m-esm/socket-cluster-app 上找到