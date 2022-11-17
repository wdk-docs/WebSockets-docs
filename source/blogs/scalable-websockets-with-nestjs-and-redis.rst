使用NestJS和Redis扩展WebSockets
================================================

`《Scalable WebSockets with NestJS and Redis》 <https://blog.logrocket.com/scalable-websockets-with-nestjs-and-redis/>`_


在开发相对年轻的应用程序时，为了更快地实现功能，人们通常倾向于忽略对可伸缩性的需求。
然而，我相信即使在项目的最初阶段，确保我们的代码尽可能的可扩展也是至关重要的。

最近，当我在做一个项目时，我遇到了一个挑战，就是将WebSockets添加到一个NestJS应用程序中。
尽管由于有出色的文档，这是一个相对简单的任务，但它有一个很大的缺点:它向以前的无状态应用程序引入了一种状态。

得益于Docker和Kubernetes等工具，如今的后端应用程序很容易扩展。
创建一个应用程序的多个实例的复杂性大大降低了——也就是说，只要应用程序保持无状态。
由于没有状态，应用程序可以被关闭和再次打开，而不会出现意外的行为。
换句话说，应用程序很容易丢弃。

WebSocket协议的每个实现都必须将当前打开的连接保持在某种形式的状态中。
这意味着，如果我们有两个应用程序实例，第二个实例分派的事件将永远无法到达连接到第一个实例的客户机。

也就是说，有一些方法可以在多个实例之间“共享”开放连接池。
一种方法是使用Redis的发布/订阅机制在应用程序的所有实例之间转发发出的事件，以确保每个打开的连接都接收到它们。

下面的实现完全包含了Nest生态系统，并涵盖了以下情况:
只向一个用户发送事件;
向所有打开的连接发送事件;
并向所有经过身份验证的用户发送事件。

.. note::

   在NestJS文档中，有一种非常简单的方法，用几行代码就可以添加Redis来在实例之间转发事件。
   如果你正在寻找一个简单但有限的解决方案，看看这里。
   如果您想亲自了解如何实现上述机制，请务必继续进行。
 
本文假设您对Docker、TypeScript和RxJS有基本的了解。

设置一个Nest应用程序
-----------------------------------------

我已经非常详细地描述了本文将使用的设置。
简而言之，我们使用Nest CLI为我们搭建应用程序，Docker使用Docker -compose添加Redis和Postgres进行本地开发。

我建议你下载这个存储库，然后跟着做，因为我只会解释相关的代码，而不会解释像模块这样的Nest样板文件。

添加Redis
-----------------------------------------

Redis是一个内存中的数据结构存储，可以用作数据库、缓存或发布/订阅客户端。
请注意，这些只是Redis的一些可能性。如果你有兴趣了解更多，给你。

通常情况下，你必须在你的电脑上安装Redis，但是多亏了Docker对应用程序进行了容器化，我们不需要这么做。Docker负责为我们安装和启动Redis。

要从Node运行时与Redis通信，有几个可用的库。我们将使用ioredis，因为它提供了大量的特性，同时保持了健壮的性能。

我们必须创建一个Nest模块来封装与Redis相关的代码。在RedisModule中，我们有providers数组，我们在其中创建ioredis客户端与Redis通信。我们还实现了RedisService，它抽象了监听和发送Redis消息。

如前所述，我们创建了两个Redis客户端，它们的用途不同:一个用于订阅，另一个用于发布消息。


.. code-block:: ts
   :caption: redis.providers.ts

    import { Provider } from '@nestjs/common';
    import Redis from 'ioredis';

    import { REDIS_PUBLISHER_CLIENT, REDIS_SUBSCRIBER_CLIENT } from './redis.constants';

    export type RedisClient = Redis.Redis;

    export const redisProviders: Provider[] = [
    {
      useFactory: (): RedisClient => {
        return new Redis({
          host: 'socket-redis',
          port: 6379,
        });
      },
      provide: REDIS_SUBSCRIBER_CLIENT,
    },
    {
      useFactory: (): RedisClient => {
        return new Redis({
          host: 'socket-redis',
          port: 6379,
        });
      },
      provide: REDIS_PUBLISHER_CLIENT,
    },
    ];

.. note:: 
   
   注意，主机和端口值通常通过某种形式的配置进行配置，比如ConfigService，但这里为了简单起见省略了它。

通过在RedisModule中注册这些提供者，我们可以将它们作为依赖项注入到服务中。

让我们创建一个RedisService。

.. code-block:: ts
   :caption: redis.service.ts

    import { REDIS_PUBLISHER_CLIENT, REDIS_SUBSCRIBER_CLIENT } from './redis.constants';
    import { RedisClient } from './redis.providers';

    export interface RedisSubscribeMessage {    readonly message: string;    readonly channel: string;    }

    @Injectable()
    export class RedisService {
    public constructor(
      @Inject(REDIS_SUBSCRIBER_CLIENT)
      private readonly redisSubscriberClient: RedisClient,
      @Inject(REDIS_PUBLISHER_CLIENT)
      private readonly redisPublisherClient: RedisClient,
    ) {}
    // ...
    }

在构造函数中，我们按照预期注入了两个Redis客户端。


然后定义两个方法:fromEvent和publish。让我们首先看一下fromEvent方法。

.. code-block:: ts
   :caption: redis.service.ts

    public fromEvent<T>(eventName: string): Observable<T> {
      this.redisSubscriberClient.subscribe(eventName);

      return Observable.create((observer: Observer<RedisSubscribeMessage>) =>
        this.redisSubscriberClient.on('message', (channel, message) => observer.next({ channel, message })),
      ).pipe(
        filter(({ channel }) => channel === eventName),
        map(({ message }) => JSON.parse(message)),
      );
    }

它告诉Redis使用redisSubscriberClient的subscribe方法来留意所提供的事件。
然后返回一个可观察对象，通过在消息事件上附加一个监听器来监听任何新消息。

当我们收到一个新消息时，我们首先检查通道(事件的Redis名称)是否等于提供的eventName。
如果是，我们使用JSON.parse将reddis发送的字符串转换为对象。

.. code-block:: ts
   :caption: redis.service.ts

    public async publish(channel: string, value: unknown): Promise<number> {
      return new Promise<number>((resolve, reject) => {
        return this.redisPublisherClient.publish(channel, JSON.stringify(value), (error, reply) => {
          if (error) {
            return reject(error);
          }

          return resolve(reply);
        });
      });
    }

publish方法接受一个通道和一个未知值，并使用redisPublisherClient发布它。
我们假设提供的值可以用JSON.stringify进行字符串化，因为Redis没有办法传输JavaScript对象。

有了这两个方法，我们成功地抽象出了连接到底层Redis客户端的所有麻烦代码，现在可以使用一个可靠的API通过RedisService在实例之间发送事件。

创建套接字的状态
-----------------------------------------

我们已经提到，当前打开的WebSocket连接必须保持在某种状态。
像socketio这样的库，我们将在这里使用它，为我们完成这一任务。

库提供了.send或.emit等有用的方法，这使得以指定格式实际获取当前活动的套接字(连接)非常困难。
为了更容易地检索和管理套接字，我们将实现自己的套接字状态。

在我们的状态实现中，我们感兴趣的是为指定的用户检索套接字。
这样，如果实例3分派了ID为1234的用户应该接收的事件，我们将能够轻松地检查所有实例，它们是否为ID为1234的用户提供任何套接字。

我们假设正在创建的应用程序支持某种身份验证。
如何验证传入的套接字将在后面讨论;现在，我们假设每个套接字都有一个可用的userId。

这非常简单。
我们将以以下格式存储套接字:Map<string, Socket[]>。
要将其放入单词中，键将是用户的id，对应的值将是他们所有的套接字。

让我们创建一个名为 ``SocketStateModule`` 的Nest模块和负责保持状态的服务。

.. code-block:: ts
   :caption: socket-state-service.ts

    @Injectable()
    export class SocketStateService {
      private socketState = new Map<string, Socket[]>()
      // ...
    }

首先，我们在映射中定义一个保存状态的私有属性，然后添加一些方法使使用服务更容易。

.. code-block:: ts
   :caption: socket-state-service.ts

    public add(userId: string, socket: Socket): boolean {
      const existingSockets = this.socketState.get(userId) || []

      const sockets = [...existingSockets, socket]

      this.socketState.set(userId, sockets)

      return true
    }

``add`` 方法以userId和socket作为参数，它们表示新打开的连接。
首先，它在existingSockets中为用户保存现有的套接字(如果没有现有的套接字，则保存空数组)。
然后，它在集合的末尾追加提供的套接字，并在状态下保存新的套接字集合。

.. code-block:: ts
   :caption: socket-state-service.ts

    public remove(userId: string, socket: Socket): boolean {
      const existingSockets = this.socketState.get(userId)

      if (!existingSockets) {
        return true
      }

      const sockets = existingSockets.filter(s => s.id !== socket.id)

      if (!sockets.length) {
        this.socketState.delete(userId)
      } else {
        this.socketState.set(userId, sockets)
      }

      return true
    }

``remove`` 方法从当前存在的套接字中为用户过滤出不需要的套接字。
每个套接字都有一个惟一的id，可用于检查是否相等。
如果在删除套接字后，用户的状态中没有任何套接字，则从映射中完全删除该数组以节省内存。
如果过滤后数组中还剩下一些套接字，我们只需将其设置回当前状态。

.. code-block:: ts
   :caption: socket-state-service.ts

    public get(userId: string): Socket[] {
      return this.socketState.get(userId) || []
    }

    public getAll(): Socket[] {
      const all = []

      this.socketState.forEach(sockets => all.push(sockets))

      return all
    }

还有另外两个方法: ``get`` 和 ``getAll``。
在get方法中，我们返回属于给定用户的所有套接字(如果没有则返回空数组)。

在 ``getAll`` 中，我们使用 ``Map`` 的 ``forEach`` 方法并获取每个用户的套接字并将它们合并到一个数组中。

创建适配器
------------------------

Nest最好的特性之一是，它允许开发人员通过定义良好、可靠的抽象来处理底层库——例如用于服务器的Express和Fastify，或用于套接字的 ``socket.io`` 和 ``ws``。

从开发人员的角度来看，通过这种方式，库可以很容易地进行交换，而无需对代码库进行任何重大更改。
为了使它工作，Nest有自己的一组适配器，可以将一个库的API“适合”到Nest所期望的API。
这使得Nest很容易支持许多具有不同api的库。

因为我们想要跟踪当前打开的套接字，所以我们必须为套接字扩展适配器。
适配器作为@nestjs/platform-socket.io包的一部分可用。
通过扩展现有的适配器，我们可以只覆盖我们需要的方法，而把其他一切都留给适配器。

在Nest的文档中，详细解释了自定义适配器是如何工作的，以及为什么它们如此强大。
我建议在进一步讨论之前先阅读它。

.. code-block:: ts
   :caption: socket.state.adapter.ts

    export class SocketStateAdapter extends IoAdapter implements WebSocketAdapter {
    public constructor(
      private readonly app: INestApplicationContext,
      private readonly socketStateService: SocketStateService,
    ) {
      super(app);
    }

    private server: socketio.Server;

    public create(port: number, options: socketio.ServerOptions = {}): socketio.Server {
      this.server = super.createIOServer(port, options);

      this.server.use(async (socket: AuthenticatedSocket, next) => {
        const token = socket.handshake.query?.token || socket.handshake.headers?.authorization;

        if (!token) {
          socket.auth = null;

          // not authenticated connection is still valid
          // thus no error
          return next();
        }

        try {
          // fake auth
          socket.auth = {
            userId: '1234',
          };

          return next();
        } catch (e) {
          return next(e);
        }
      });

      return this.server;
    }

    public bindClientConnect(server: socketio.Server, callback: Function): void {
      server.on('connection', (socket: AuthenticatedSocket) => {
        if (socket.auth) {
          this.socketStateService.add(socket.auth.userId, socket);

          socket.on('disconnect', () => {
            this.socketStateService.remove(socket.auth.userId, socket);
          });
        }

        callback(socket);
      });
    }
    }

我们的类扩展了IoAdapter并覆盖了两个方法:create和bindClientConnect。

create方法，顾名思义，负责创建WebSocket服务器的实例。
我们使用IoAdapter的createIOServer方法来尽可能重用代码，并确保所有内容都尽可能接近原始适配器。

然后我们为身份验证设置一个中间件——在我们的示例中，是一个假中间件。
我们假设身份验证是基于令牌的。

在中间件中，我们首先检查是否在我们预期的位置提供了令牌:授权头或查询的令牌参数。

如果没有提供令牌，我们将 `socket.auth` 设置为 `null` ，并调用next继续执行其他中间件。
如果存在令牌，我们通常会使用AuthService检查和验证它，但这超出了本文的范围。

相反，我们将模拟经过验证的令牌的有效负载，使其成为具有单一属性userId等于1234的对象。
令牌验证放置在 `try/catch` 块中，因为令牌验证方法可能抛出错误。
如果它发生了，我们应该捕获它，并使用error参数调用next，向socketio指示发生了错误。

第二种方法是 `bindClientConnect`，它负责在套接字服务器中注册连接侦听器。
在这里，我们可以访问服务器，在那里我们可以监听连接事件。
我们在 `create` 方法中定义的中间件将被预先执行，因此我们可以安全地检查套接字对象上的auth属性。

现在请记住:我们还允许存在未经身份验证的套接字，因此必须首先检查auth属性是否存在。
如果是，则使用前面定义的 `socketStateService` 方法将套接字添加到用户的套接字池中。

我们还为断开连接事件注册一个事件监听器，以便从状态中删除套接字。
为了完全确保没有任何内存泄漏，我们使用套接字对象的 `removeAllListeners` 方法来删除断开连接事件侦听器。

无论是否有auth属性，我们都必须调用作为第二个参数提供的回调函数，以让socketio适配器也保留对套接字的引用。

要注册我们的自定义适配器，我们必须使用Nest应用程序的useWebSocketAdapter方法:

.. code-block:: ts
   :caption: adapter.init.ts

    export const initAdapters = (app: INestApplication): INestApplication => {
      const socketStateService = app.get(SocketStateService);
      const redisPropagatorService = app.get(RedisPropagatorService);

      app.useWebSocketAdapter(new SocketStateAdapter(app, socketStateService, redisPropagatorService));

      return app;
    };

`redisPropagatorService` 将在下面解释。


.. code-block:: ts
   :caption: main.ts

    async function bootstrap(): Promise<void> {
      const app = await NestFactory.create(AppModule);

      initAdapters(app);

      await app.listen(3000, () => {
        console.log(`Listening on port 3000.`);
      });
    }

    bootstrap();

创建Redis事件传播器
--------------------------------------

有了Redis集成和我们自己的套接字状态和适配器之后，剩下要做的就是创建最后一个服务，用于跨应用程序的所有实例调度事件。

为此，我们必须再创建一个名为 `RedisPropagatorModule` 的Nest模块。

在 `RedisPropagatorService` 中，我们将监听来自其他实例的任何传入Redis事件，并将事件分派给它们。
瞧!我们自己的发布/订阅服务!

有三种类型的事件通过Redis:

- 向所有打开的连接发出事件
- 只向经过身份验证的用户发出事件
- 只向指定用户发出事件

在代码中，我们将这样定义它们:

.. code-block:: ts
      
    export const REDIS_SOCKET_EVENT_SEND_NAME = 'REDIS_SOCKET_EVENT_SEND_NAME';
    export const REDIS_SOCKET_EVENT_EMIT_ALL_NAME = 'REDIS_SOCKET_EVENT_EMIT_ALL_NAME';
    export const REDIS_SOCKET_EVENT_EMIT_AUTHENTICATED_NAME = 'REDIS_SOCKET_EVENT_EMIT_AUTHENTICATED_NAME';

现在让我们创建服务:

.. code-block:: ts
   :caption: redis.propagator.service.ts

    @Injectable()
    export class RedisPropagatorService {
      private socketServer: Server;

      public constructor(
        private readonly socketStateService: SocketStateService,
        private readonly redisService: RedisService,
      ) {}

      public propagateEvent(eventInfo: RedisSocketEventSendDTO): boolean {
        if (!eventInfo.userId) {
          return false;
        }

        this.redisService.publish(REDIS_SOCKET_EVENT_SEND_NAME, eventInfo);

        return true;
      }

      public emitToAuthenticated(eventInfo: RedisSocketEventEmitDTO): boolean {
        this.redisService.publish(
          REDIS_SOCKET_EVENT_EMIT_AUTHENTICATED_NAME,
          eventInfo,
        );

        return true;
      }

      public emitToAll(eventInfo: RedisSocketEventEmitDTO): boolean {
        this.redisService.publish(REDIS_SOCKET_EVENT_EMIT_ALL_NAME, eventInfo);

        return true;
      }

      // ...
    }

在构造函数中，我们使用前面创建的两个服务。
我们定义了三个有用的方法。
它们都做了一件简单的事情:它们用提供的信息分派预期的Redis事件。
唯一的区别是在propagateEvent方法中，在该方法中，除非提供了userId，否则我们不想发布事件。

除此之外，emitToAll和emitToAuthenticated方法都可以从代码库中的任何位置调用。
这不是' propagateEvent '的情况;每当套接字服务器将事件分派给前端客户端时，将调用此方法。

监听事件分派
---------------------------------

为了最大限度地利用Nest生态系统，我们将创建一个拦截器，它将访问每个套接字事件响应。
这样，我们就不必在每个网关中手动调用propagateEvent。

.. code-block:: ts
   :caption: redis-propagator.interceptor.ts

    @Injectable()
    export class RedisPropagatorInterceptor<T> implements NestInterceptor<T, WsResponse<T>> {
      public constructor(private readonly redisPropagatorService: RedisPropagatorService) {}

      public intercept(context: ExecutionContext, next: CallHandler): Observable<WsResponse<T>> {
        const socket: AuthenticatedSocket = context.switchToWs().getClient();

        return next.handle().pipe(
          tap((data) => {
            this.redisPropagatorService.propagateEvent({
              ...data,
              socketId: socket.id,
              userId: socket.auth?.userId,
            });
          }),
        );
      }
    }

拦截器可以订阅 `next.handle()` 方法返回的可观察对象。
服务器发送的每个WebSocket事件都会经过这里。
通过使用RxJS的tap方法，我们可以对响应做出反应而不改变它。

每个分派的事件，在返回到前端客户端之前，会在所有实例中传播，在这些实例中，我们将事件发送到属于用户的所有套接字。

请记住，auth对象是可选的，所以我们使用TypeScript新的可选链接语法来确保我们的代码在没有auth对象时不会中断。

在propagateEvent方法中，拒绝没有userId的事件。
这是因为这样的事件不希望跨实例传播—连接是惟一的。

记住，无论是否使用propagateEvent方法，事件都被发送到前端客户端。
因此，如果没有认证对象，网关发送的事件仍然会到达前端客户端。
我们只是确保它被发送到用户可能打开的所有其他套接字。

我们将在本文最后的示例中演示如何附加拦截器。

在RedisPropagatorService中创建事件监听器
--------------------------------------------------------

除了将事件分派到其他实例之外，我们还希望侦听来自其他实例的事件。

.. code-block:: ts
   :caption: redis.propagator.service.ts

    @Injectable()
    export class RedisPropagatorService {
    // ...

    private socketServer: Server;

    public constructor(
      private readonly socketStateService: SocketStateService,
      private readonly redisService: RedisService,
    ) {
      this.redisService
        .fromEvent(REDIS_SOCKET_EVENT_SEND_NAME)
        .pipe(tap(this.consumeSendEvent))
        .subscribe();

      this.redisService
        .fromEvent(REDIS_SOCKET_EVENT_EMIT_ALL_NAME)
        .pipe(tap(this.consumeEmitToAllEvent))
        .subscribe();

      this.redisService
        .fromEvent(REDIS_SOCKET_EVENT_EMIT_AUTHENTICATED_NAME)
        .pipe(tap(this.consumeEmitToAuthenticatedEvent))
        .subscribe();
    }

    public injectSocketServer(server: Server): RedisPropagatorService {
      this.socketServer = server;

      return this;
    }
    }

感谢redisService，我们可以很容易地订阅Redis事件。
使用RxJS的tap操作符，我们可以调用其中一个方法来对可观察对象的事件流做出适当的反应。

更改socketStateAdapter
-----------------------------------

我们还创建了一个injectSocketServer方法，它允许我们将WebSocket服务器实例注入到我们的服务中。
最好是通过依赖项注入来实现这一点，但在编写自定义适配器时，这实际上是不可能的。
尽管如此，有了这个方法，我们必须调整适配器的代码:

.. code-block:: ts
   :caption: socket.state.adapter.ts

    export class SocketStateAdapter extends IoAdapter implements WebSocketAdapter {
      public constructor(
        private readonly app: INestApplicationContext,
        private readonly socketStateService: SocketStateService,
        private readonly redisPropagatorService: RedisPropagatorService,
      ) {
        super(app);
      }

      public create(port: number, options: socketio.ServerOptions = {}): socketio.Server {
        const server = super.createIOServer(port, options);
        this.redisPropagatorService.injectSocketServer(server);
        // ...
      }
    }

我们已经使用了依赖注入来获得redisPropagatorService的实例，并且在创建WebSocket服务器期间，我们简单地将它注入到单例服务中。

解决了这些问题之后，让我们回到redisPropagatorService并定义用于监听事件的方法。

consumeSendEvent 方法
--------------------------

首先，我们将创建一个名为consumeSendEvent的方法来监听Redis事件，该事件告诉我们将事件发送给指定的用户。

.. code-block:: ts
   :caption: socket.state.adapter.ts

    private consumeSendEvent = (eventInfo: RedisSocketEventSendDTO): void => {
      const { userId, event, data, socketId } = eventInfo;

      return this.socketStateService
        .get(userId)
        .filter((socket) => socket.id !== socketId)
        .forEach((socket) => socket.emit(event, data));
    };

在eventInfo中，我们传递以下信息:

.. code-block:: ts
   :caption: redis.socket.event.send.dto.ts

    export class RedisSocketEventSendDTO {
      public readonly userId: string;
      public readonly socketId: string;
      public readonly event: string;
      public readonly data: unknown;
    }

知道在哪里发送事件(userId)，事件被称为什么(event)，它应该包含什么数据(data)，以及事件起源于哪个套接字(socketId)，我们就可以安全地将事件发送到现有用户的套接字。

为此，我们首先获取用户的套接字(通过提供的socketId筛选套接字，以确保不会两次发送相同的事件)，然后使用每个套接字的emit方法发送事件。

如果当前没有为用户打开套接字(如果用户在其他实例上只有一个打开的连接)，则socketStateService的get方法将返回一个空数组，并且不会执行以下所有方法。

在拦截器内部，我们使用propagateEvent方法跨所有实例发送事件。
然后将事件发送到前端客户端。
这就是为什么我们要跟踪事件产生的套接字:以确保我们不会在同一个套接字上两次发送相同的事件。


consumeEmitToAllEvent
--------------------------

.. code-block:: ts
   :caption: redis.service.ts

    private consumeEmitToAllEvent = (
      eventInfo: RedisSocketEventEmitDTO,
    ): void => {
      this.socketServer.emit(eventInfo.event, eventInfo.data);
    };

该方法非常简单—只需使用套接字服务器的emit方法将事件发送到当前打开的所有连接(无论是否经过身份验证)。

consumeEmitToAuthenticated
----------------------------------

.. code-block:: ts
      
    private consumeEmitToAuthenticatedEvent = (
      eventInfo: RedisSocketEventEmitDTO,
    ): void => {
      const { event, data } = eventInfo;

      return this.socketStateService
        .getAll()
        .forEach((socket) => socket.emit(event, data));
    };

在consumeEmitToAuthenticated方法中，我们使用socketStateService的getAll方法。
在获得所有经过身份验证的套接字之后，我们使用套接字的emit方法发送事件。

工作示例
-------------------

最后要做的事情是创建一个网关，该网关监听传入的事件并检查一切是否如预期的那样工作。

.. code-block:: ts
   :caption: redis.service.ts

    @UseInterceptors(RedisPropagatorInterceptor)
    @WebSocketGateway()
    export class EventsGateway {
    @SubscribeMessage('events')
    public findAll(): Observable<any> {
      return from([1, 2, 3]).pipe(
        map((item) => {
          return { event: 'events', data: item };
        }),
      );
    }
    }

通过使用@UseInterceptors装饰器，我们可以注册跨所有实例发出事件的拦截器。
如果希望传播事件，就必须在创建的每个网关上注册拦截器。

现在我们来看一个带有socket.io-client库的简单HTML文件:

.. code-block:: html
   :caption: socket.io-client.html

    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <meta http-equiv="X-UA-Compatible" content="ie=edge" />
      <title>Sockets test</title>
    </head>
    <body>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/2.3.0/socket.io.dev.js"></script>
      <script>
        window.s = io('http://localhost:3000', {
          query: {
            token: '123',
          },
        });

        s.emit('events', { event: 'events', data: { test: true } });
        s.on('events', (response) => {
          console.log(response);
        });
      </script>
    </body>
    </html>

提供的令牌显然是假的，我们只是想模拟存在一个令牌。

从库中获取代码后，为了启动应用程序，运行:

.. code-block:: sh
    docker-compose up

.. image:: https://blog.logrocket.com/wp-content/uploads/2020/02/compiling-app.png
   :alt: Compiling Our App In Watch Mode

一旦服务器启动并运行，打开文件并检查控制台:

.. image:: https://blog.logrocket.com/wp-content/uploads/2020/02/html-file-console.png
   :alt: Checking The Console In Our HTML File

知道这里提供了一个令牌，我们可以通过打开第二个选项卡来检查两个选项卡是否收到了相同的事件(因为它们是来自一个用户的两个会话):

.. image:: https://blog.logrocket.com/wp-content/uploads/2020/02/console-logs-two-sessions.png
   :alt: Console Reflecting Two Sessions

通过刷新一个选项卡，我们将使第二个选项卡也接收事件。
我们的事件通过Redis客户端，然后将它们转发到它们起源的同一个实例，但这一次，我们只将它发送到还没有接收到事件的套接字。

完整的代码在 `这里 <https://github.com/maciejcieslar/scalable-websocket-nestjs>`_ 。

总结
--------------

在向我们的应用程序添加WebSockets时，我们面临一个决定:我们的应用程序是否可伸缩。
一旦应用程序需要跨多个实例进行复制，预先决定采用可伸缩的解决方案将使我们受益匪浅。
由于Nest的模块化，一旦实现，解决方案可以很容易地复制到其他项目中。

确保我们的应用程序是可伸缩的是一项艰巨的工作。
在很大程度上，这需要我们彻底改变思维方式。
但这是值得的。
