NestJS 使用 ws 模块的正确姿势
==================================

https://xknow.net/native-websock-in-nestjs/

最近在用 WebSocket 搞点事情，但是又不想用 socket.io，便决定用 ws 模块来实现后台的业务。无奈 NestJS 对 ws 模块的文档描述有限，结合 ws 模块的使用方式和 NestJS 提供的实例，整理了一份使用 ws 模块的正确姿势。同时，基于业务的需求，还对其进行了分布式的支持。

概念
-----------------

不得不说，在 NestJS 中，从接触之初，就有着太多的概念，比如一个中间件，划分出了守卫、管道、拦截器等等。在 NestJS 中使用 Websockets，也是有着几个概念，不过也比较简单，这里总结一下各自的内容。

Gateway
-----------------
在 Nest.js 中 WebSocket 的处理单元被称为 Gateway ，其实就是类似于普通 HTTP 模块中的 Controller。@SubscribeMessage() 装饰器可以看做是匹配响应用的 Pattern，或者当做 Router。

Gateway 本质上也是一个 Provider，经由 NestJS 实例化，并在实例化的时候依据元信息创建 Websocket Server。NestJS 支持两种平台，也就是 socket.io 和 ws，NestJS在 socket.io 平台下的功能多一些，也是倚赖 socket.io 所提供的高级特性。ws 模块与之比起来，功能性上逊色了不少。不过 NestJS 文档中讲，ws 模块比 socket.io 快很多，但是大部分时候没必要，用 socket.io 就挺好。

可是我还是用了，出于一些业务情景的考量，最后还是选了 ws 模块，所以接下来讲如何接入 ws 模块。

Adapter
-----------------
字面意思就叫适配器。在文档中，适配器相关的内容是放在了最后一个章节，这是因为以 socket.io 为主来讲解 Websocket 在 NestJS 中的用法的情况下，这个的确没那么重要。但我要着重写一下，是因为用 ws 模块的话，写一个合适的 Adapter 就至关重要了。

当然，可以直接复制文档中的 ws-adapter.ts 这个代码块的内容，作为适配器来使用。这里对一些关键的内容做一定的说明。

首先 WsAdapter 这个类是实现了 WebSocketAdapter 这个接口：

.. code-block:: ts
      
    import { Observable } from 'rxjs';

    export interface WsMessageHandler<T = string> {
      message: T;
      callback: (...args: any[]) => Observable<any> | Promise<any>;
    }

    export interface WebSocketAdapter<
      TServer = any,
      TClient = any,
      TOptions = any
    > {
      create(port: number, options?: TOptions): TServer;
      bindClientConnect(server: TServer, callback: Function): any;
      bindClientDisconnect?(client: TClient, callback: Function): any;
      bindMessageHandlers(
        client: TClient,
        handlers: WsMessageHandler[],
        transform: (data: any) => Observable<any>,
      ): any;
      close(server: TServer): any;
    }
    create()
    
这个方法会让 NestJS App 在使用 app.useWebSocketAdapter() 后被调用，来创建一个 WebSocket Server 对象。

bindClientConnect()
该方法会拿到 Gateway 类中的 handleConnection() 方法作为第二个 callback 参数。从示例代码中便能看出是拿到 callback 方法的引用后，与 WebSocket Server 的 connection 事件做了一个绑定。

bindClientDisconnect()
该方法与 bindClientConnect() 一样，不过对应的是 Gateway 类中的 handleDisconnect() 方法。

bindMessageHandlers()
该方法会拿到在 Gateway 类中通过 @SubscribeMessage() 装饰器标记的方法列表，并根据消息的主题进行路由。官方示例的方式，也是 @nestjs/common 包中提供的路由方式，是通过 payload 中的 event 字段实现的，在装饰器中所写的字符串，自然也就是用来匹配 event 字段所用。

当然，如果想实现更高级的特性，甚至可以写成常规意义上的路由格式甚至正则表达式，然后在此处自定义实现自己的路由机制。

close()
这个方法没有过多探究，盲猜是实例销毁前会执行的吧，我是照着文档写上把服务关闭即可。

其他东西
-----------------
剩下的诸如 Exception filters、Pipes、Guards 这些与 NestJS 中的概念基本一致，也是在消息到达真正的处理函数之前的一些中间件，来实现鉴权、数据转换、异常捕获等的处理。

实践
-----------------
如果使用 NestJS 所提供的 WebSocket Adapter，那么实际实现一个 WebSocket 服务端，只需要写一个 Gateway 即可，还是非常简单的：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
import { Server } from 'ws';
import {
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import * as WebSocket from 'ws';
import { IncomingMessage } from 'http';

@WebSocketGateway(4000)
export class TestGateway {

  async handleConnection(client: WebSocket, request: IncomingMessage) {
    console.log(request.url);
  }

  handleDisconnect(client: WebSocket) {
    console.log(client);
  }

  @SubscribeMessage('event')
  onEvent(client: any, data: any): any {
    console.log(data);
    return {
      event: 'event',
      response: 'text',
    };
  }

}
其中 handleConnection() 是定义在 OnGatewayConnection 接口中的方法，用来响应客户端连接到服务端的事件，在上文中的 Adapter 中有提到过。

handleDisconnect() 同上，响应客户端断开的事件。不过是定义在 OnGatewayDisconnect 接口中。这里不得不吐槽一下，加上一个 afterInit() 方法，NestJS 像是生怕人把三个方法一起写了似的，将之分散在三个接口里。

@SubscribeMessage() 标记的便是响应特定 Pattern 的方法了，正如前面所说，如果自己实现一个适配器的话，还可以用更复杂的表达式来实现这个效果了。

分布式
-----------------
除了简单的在一个实例中启动一个 WebSocket 服务端，考虑到多节点、多实例的情况下，再通过负载均衡的方式来使用各节点，要再加一点功能，来实现分布式的架构。

首先分析一下场景。我们可以使用 Nginx 来反代 WebSocket 请求，这样粗略均匀地将连接分配给了各个实例，如果是客户端发送了消息，会发送到建立连接的实例，处理请求的服务端拿到 socket 连接，再回应信息。如果说只是持有 socket 的服务端在做处理并且不断返回信息倒也还好，可是在我的实际使用中出现了另一种情况：HTTP 请求接口，然后再给指定的客户端发送消息，比如管理面板上，将某个客户端强制下线。

socket 不一定在同一个实例上，所以就需要找到正确的实例来发送此次请求。这就是做分布式的意义，除此之外，复杂的系统可能还要共享房间信息、跨服务的两个终端聊天等，这种需求建议可以直接 socket.io + Redis Adapter（逃。

利用一套发布订阅的机制，是较容易实现的方式，可选的方式包括 Redis 的发布订阅功能，或者使用分布式的消息队列，如 RabbitMQ 等。

我在这里的实现思路比较简单，简述一下给各位看官提供一些思路。依赖 Redis 的发布订阅功能，在客户端连接到服务器后，订阅一个 ClientID 的频道：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
class TestGateway {
  async handleConnection() {
    const redisClient = await this.redisService.getClient('WebSocketSubscriber');
    await redisClient.subscribe(clientId as string, err => {
      if (err) {
        console.log(`订阅到频道 ${clientId} 失败`, err.message);
        return;
      }
      console.log(`已订阅到频道 ${clientId}`);
    });

    redisClient.on('message', (channel, message) => {
      client.send(message);
    });
  }
}
发布消息的时候是发送到 Redis 中 ClientID 表示的频道:

1
2
3
4
5
export class TestService {
  async publish(clientId: string, data: any) {
    await redisClient.publish(clientId, JSON.stringify(data));
  }
}
用新建的 Golang WebSocket 客户端项目试了一下，舒畅。

哦对了，Redis 发布和订阅需要是两个连接，我太菜了，踩了坑。

小结
-----------------
迫于 NestJS 文档的零散，这里集中讲述了一下在 NestJS 中实现 WebSocket 的一些思路和注意事项，希望对看到文章的同学有所帮助。

在 NestJS 里用 WebSocket，只要理解了相应的概念，写起来还是很简单且舒适的，需要开发的代码量挺少，抽象的各种中间件也能清楚表达功能含义。

仔细想想，我在分布式章节用到的这个 ClientID 就是 MQTT 中的 Topic 的概念哦。那我为什么不直接用一个 MQTT Broker 来跟客户端通讯？

写都写了，好好用。 