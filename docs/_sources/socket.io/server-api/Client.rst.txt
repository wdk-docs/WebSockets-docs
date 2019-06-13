Client
======

The ``Client`` class represents an incoming transport (engine.io)
connection. A ``Client`` can be associated with many multiplexed
``Socket``\ s that belong to different ``Namespace``\ s.

client.conn
-----------

-  *(engine.Socket)*

A reference to the underlying ``engine.io`` ``Socket`` connection.

client.request
--------------

-  *(Request)*

A getter proxy that returns the reference to the ``request`` that
originated the engine.io connection. Useful for accessing request
headers such as ``Cookie`` or ``User-Agent``.
