koa-websocket
==============================

Koa v2 is now the default. For Koa v1 support install with koa-websocket@2 and see the `legacy` branch.

Supports `ws://` and `wss://`

Installation
------------------------------

.. code-block::

   npm install koa-websocket

Usage
------------------------------

.. code-block:: js

   const Koa = require('koa'),
     route = require('koa-route'),
     websockify = require('koa-websocket');

   const app = websockify(new Koa());

   // Regular middleware
   // Note it's app.ws.use and not app.use
   app.ws.use(function(ctx, next) {
     // return `next` to pass the context (ctx) on to the next ws middleware
     return next(ctx);
   });

   // Using routes
   app.ws.use(route.all('/test/:id', function (ctx) {
     // `ctx` is the regular koa context created from the `ws` onConnection `socket.upgradeReq` object.
     // the websocket is added to the context on `ctx.websocket`.
     ctx.websocket.send('Hello World');
     ctx.websocket.on('message', function(message) {
       // do something with the message from client
           console.log(message);
     });
   }));

   app.listen(3000);

Example with Let's Encrypt ([the Greenlock package](https://git.daplie.com/Daplie/greenlock-koa)):

.. code-block:: js

   const Koa = require('koa');
   const greenlock = require('greenlock-express');
   const websockify = require('koa-websocket');

   const le = greenlock.create({
     // all your sweet Let's Encrypt options here
   });

   // the magic happens right here
   const app = websockify(new Koa(), wsOptions, le.httpsOptions);

   app.ws.use((ctx) => {
      // the websocket is added to the context as `ctx.websocket`.
     ctx.websocket.on('message', function(message) {
       // do something
     });
   });

   app.listen(3000);

With custom websocket options.

.. code-block:: js

   const Koa = require('koa'),
     route = require('koa-route'),
     websockify = require('koa-websocket');

   const wsOptions = {};
   const app = websockify(new Koa(), wsOptions);

   app.ws.use(route.all('/', (ctx) => {
      // the websocket is added to the context as `ctx.websocket`.
     ctx.websocket.on('message', function(message) {
       // print message from the client
       console.log(message);
     });
   }));

   app.listen(3000);

Example
------------

koa router

.. code-block:: js

  const koa = require('koa');
  const router = require('koa-router');
  const websockify = require('koa-websocket');

  const app = koa();

  const api = router();

  websockify(app);

  api.get('/*', function* get(next) {
    this.websocket.send('Hello World');
    this.websocket.on('message', (message) => {
      console.log(message);
    });
    yield next;
  });

  app.ws.use(api.routes()).use(api.allowedMethods());
  app.listen(3000);

simple

.. code-block:: js

  const koa = require('koa');
  const route = require('koa-route');
  const websockify = require('koa-websocket');

  const app = websockify(koa());

  // Note it's app.ws.use and not app.use
  app.ws.use(route.all('/test/:id', function* all(next) {
    // `this` is the regular koa context created from the `ws`
    // onConnection `socket.upgradeReq` object.
    // The websocket is added to the context on `this.websocket`.
    this.websocket.send('Hello World');
    this.websocket.on('message', (message) => {
      // Do something with the message from client
      console.log(message);
    });
    // Yielding `next` will pass the context (this) on to the next ws middleware
    yield next;
  }));


  app.listen(3000);

Test
------

.. code-block:: js

  const assert = require('assert');
  const fs = require('fs');
  const WebSocket = require('ws');
  const Koa = require('koa');
  const route = require('koa-route');

  const koaws = require('koa-websocket');

  describe('should route ws messages seperately', () => {
    const app = koaws(new Koa());

    app.ws.use((ctx, next) => {
      ctx.websocket.on('message', (message) => {
        if (message === '123') {
          ctx.websocket.send(message);
        }
      });
      return next();
    });

    app.ws.use(route.all('/abc', (ctx) => {
      ctx.websocket.on('message', (message) => {
        ctx.websocket.send(message);
      });
    }));

    app.ws.use(route.all('/abc', (ctx) => {
      ctx.websocket.on('message', (message) => {
        ctx.websocket.send(message);
      });
    }));

    app.ws.use(route.all('/def', (ctx) => {
      ctx.websocket.on('message', (message) => {
        ctx.websocket.send(message);
      });
    }));

    let server = null;

    before((done) => {
      server = app.listen(done);
    });

    after((done) => {
      server.close(done);
    });

    it('sends 123 message to any route', (done) => {
      const ws = new WebSocket(`ws://localhost:${server.address().port}/not-a-route`);
      ws.on('open', () => {
        ws.send('123');
      });
      ws.on('message', (message) => {
        assert(message === '123');
        done();
        ws.close();
      });
    });

    it('sends abc message to abc route', (done) => {
      const ws = new WebSocket(`ws://localhost:${server.address().port}/abc`);
      ws.on('open', () => {
        ws.send('abc');
      });
      ws.on('message', (message) => {
        assert(message === 'abc');
        done();
        ws.close();
      });
    });

    it('sends def message to def route', (done) => {
      const ws = new WebSocket(`ws://localhost:${server.address().port}/def`);
      ws.on('open', () => {
        ws.send('def');
      });
      ws.on('message', (message) => {
        assert(message === 'def');
        done();
        ws.close();
      });
    });

    it('handles urls with query parameters', (done) => {
      const ws = new WebSocket(`ws://localhost:${server.address().port}/abc?foo=bar`);
      ws.on('open', () => {
        ws.send('abc');
      });
      ws.on('message', (message) => {
        assert(message === 'abc');
        done();
        ws.close();
      });
    });
  });

  describe('should support custom ws server options', () => {
    const app = koaws(new Koa(), {
      handleProtocols(protocols) {
        if (protocols.indexOf('bad_protocol') !== -1) { return false; }
        return protocols.pop();
      },
    });

    let server = null;

    before((done) => {
      server = app.listen(done);
    });

    after((done) => {
      server.close(done);
    });

    it('reject bad protocol use wsOptions', (done) => {
      const ws = new WebSocket(`ws://localhost:${server.address().port}/abc`, ['bad_protocol']);
      ws.on('error', () => {
        assert(true);
        done();
        ws.close();
      });
    });
  });

  describe('should support custom http server options', () => {
    // The cert is self-signed.
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

    const secureApp = koaws(new Koa(), {}, {
      key: fs.readFileSync('./test/key.pem'),
      cert: fs.readFileSync('./test/cert.pem'),
    });

    let server = null;

    before((done) => {
      server = secureApp.listen(done);
    });

    after((done) => {
      server.close(done);
    });

    it('supports wss protocol', (done) => {
      const ws = new WebSocket(`wss://localhost:${server.address().port}/abc`);
      ws.on('open', () => {
        assert(true);
        done();
        ws.close();
      });
    });
  });

Source
-------

.. code-block:: js
  
  const url = require('url');
  const https = require('https');
  const compose = require('koa-compose');
  const co = require('co');
  const ws = require('ws');

  const WebSocketServer = ws.Server;
  const debug = require('debug')('koa:websockets');

  function KoaWebSocketServer(app) {
    this.app = app;
    this.middleware = [];
  }

  KoaWebSocketServer.prototype.listen = function listen(options) {
    this.server = new WebSocketServer(options);
    this.server.on('connection', this.onConnection.bind(this));
  };

  KoaWebSocketServer.prototype.onConnection = function onConnection(socket, req) {
    debug('Connection received');
    socket.on('error', (err) => {
      debug('Error occurred:', err);
    });
    const fn = co.wrap(compose(this.middleware));

    const context = this.app.createContext(req);
    context.websocket = socket;
    context.path = url.parse(req.url).pathname;

    fn(context).catch((err) => {
      debug(err);
    });
  };

  KoaWebSocketServer.prototype.use = function use(fn) {
    this.middleware.push(fn);
    return this;
  };

  module.exports = function middleware(app, wsOptions, httpsOptions) {
    const oldListen = app.listen;
    app.listen = function listen(...args) {
      debug('Attaching server...');
      if (typeof httpsOptions === 'object') {
        const httpsServer = https.createServer(httpsOptions, app.callback());
        app.server = httpsServer.listen(...args);
      } else {
        app.server = oldListen.apply(app, args);
      }
      const options = { server: app.server };
      if (wsOptions) {
        Object.keys(wsOptions).forEach((key) => {
          if (Object.prototype.hasOwnProperty.call(wsOptions, key)) {
            options[key] = wsOptions[key];
          }
        });
      }
      app.ws.listen(options);
      return app.server;
    };
    app.ws = new KoaWebSocketServer(app);
    return app;
  };

FAQ
----

... Get total number of connected clients on each new connection

   > https://github.com/websockets/ws/issues/1087

   .. code-block:: js

      app.ws.clients.size

API
------------------------------

.. function:: websockify(KoaApp, [WebSocketOptions], [httpsOptions])

   The WebSocket options object just get passed right through to the `new WebSocketServer(options)` call.

   The optional HTTPS options object gets passed right into `https.createServer(options)`. If the HTTPS options are
   passed in, koa-websocket will use the built-in Node HTTPS server to provide support for the `wss://` protocol.

License
------------------------------

MIT
