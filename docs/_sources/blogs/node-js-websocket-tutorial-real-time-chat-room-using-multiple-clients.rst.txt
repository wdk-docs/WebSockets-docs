Node.js WebSocket Tutorial — Real-Time Chat Room using Multiple Clients
============================================================================

> https://karlhadwen.medium.com/node-js-websocket-tutorial-real-time-chat-room-using-multiple-clients-44a8e26a953e


Karl Hadwen
Karl Hadwen

May 29·6 min read






WebSockets don’t have to be scary! Let’s create a multi-client real-time chat room together!
We are going to be using the following packages for this tutorial:
WS: https://github.com/websockets/ws
Express: https://github.com/expressjs/express
WS is simple to use, blazing fast and thoroughly tested WebSocket client and server for Node.js — their words, not mine…although I am partial to agree as it works fantastically!
Install our dependencies
yarn add express ws
If you are using npm, you can install the dependencies that we need for this tutorial by using npm install express ws

.. code:: json

    {
      "name": "rtm",
      "version": "0.0.1",
      "scripts": {
        "start": "node server.js"
      },
      "dependencies": {
        "express": "^4.17.1",
        "ws": "^7.2.5"
      }
    }

Don’t worry if your version numbers on the dependencies are different, the authors of the packages could have updated the modules and thus resulting in the version numbers increasing.
Creating our server.js file


.. code:: js

    const express = require('express');
    const http = require('http');
    const WebSocket = require('ws');

    const port = 6969;
    const server = http.createServer(express);
    const wss = new WebSocket.Server({ server })

    wss.on('connection', function connection(ws) {
      ws.on('message', function incoming(data) {
        wss.clients.forEach(function each(client) {
          if (client !== ws && client.readyState === WebSocket.OPEN) {
            client.send(data);
          }
        })
      })
    })

    server.listen(port, function() {
      console.log(`Server is listening on ${port}!`)
    })
There isn’t that much going on here, but it would be great to walk through the code line by line to figure out how this works exactly. If you get the idea as to what’s going on here, great! If not, check the detailed overview below 👇
Creating our index.html file


.. code:: html
      
    <h1>Real Time Messaging</h1>
    <pre id="messages" style="height: 400px; overflow: scroll"></pre>
    <input type="text" id="messageBox" placeholder="Type your message here" style="display: block; width: 100%; margin-bottom: 10px; padding: 10px;" />
    <button id="send" title="Send Message!" style="width: 100%; height: 30px;">Send Message</button>

    <script>
      (function() {
        const sendBtn = document.querySelector('#send');
        const messages = document.querySelector('#messages');
        const messageBox = document.querySelector('#messageBox');

        let ws;

        function showMessage(message) {
          messages.textContent += `\n\n${message}`;
          messages.scrollTop = messages.scrollHeight;
          messageBox.value = '';
        }

        function init() {
          if (ws) {
            ws.onerror = ws.onopen = ws.onclose = null;
            ws.close();
          }

          ws = new WebSocket('ws://localhost:6969');
          ws.onopen = () => {
            console.log('Connection opened!');
          }
          ws.onmessage = ({ data }) => showMessage(data);
          ws.onclose = function() {
            ws = null;
          }
        }

        sendBtn.onclick = function() {
          if (!ws) {
            showMessage("No WebSocket connection :(");
            return ;
          }

          ws.send(messageBox.value);
          showMessage(messageBox.value);
        }

        init();
      })();
    </script>

How does the code work?
--------------------------

Showing the final code is great, but how exactly does it all connect and work together? Fine, you win! Let’s go ahead and dissect the server.js file!

.. code:: js

      const express = require('express');
      const http = require('http');
      const WebSocket = require('ws');

      const port = 6969;
      const server = http.createServer(express);
      const wss = new WebSocket.Server({ server })
      So here what’s going on is we are just doing the usual requires, we pull in express, ws and you might have spotted http as well. We use http so we can initialise a server, and we pass express in there like so: const server = http.createServer(express); along with setting the port to 6969. Lastly, we assign the new WebSocket to wss.
      wss.on('connection', function connection(ws) {
        ws.on('message', function incoming(data) {
          wss.clients.forEach(function each(client) {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
              client.send(data);
            }
          })
        })
      })
Next, we listen for a connection on our newly initialised WebSocket by doing wss.on('connection', function connection(ws) { - I named this wss to remind myself that this is the WebSocket Server, but feel free to name this as you like.
Once we have the connection, we listen for a message from the client, next, you’ll see that we have a function called incoming, this function gives us data which is the users' messages from the front-end (we will come to the front-end part shortly); we will use data later on to send it to all the connected clients.
So now we have the data (the messages), sent from the clients, we want to broadcast that message to each client (apart from the sending client). Next, we run a forEach loop over each connected client, and then we use an if statement to make sure that the client is connected and the socket is open--an important aspect of this if statement is that we are also checking that we are not sending the message back to the client who sent the message!. If that statement comes back as true, we then broadcast the message using: client.send(data);.

.. code:: js

          
    server.listen(port, function() {
      console.log(`Server is listening on ${port}!`)
    })

Lastly, for the server.js file, we just listen on our port that we set above--this is just standard Express!
Okay, phew we’re done with the server.js file, now onto the index.html file.

.. code:: js

    <h1>Real Time Messaging</h1>
    <pre id="messages" style="height: 400px; overflow: scroll"></pre>
    <input type="text" id="messageBox" placeholder="Type your message here" style="display: block; width: 100%; margin-bottom: 10px; padding: 10px;" />
    <button id="send" title="Send Message!" style="width: 100%; height: 30px;">Send Message</button>

Here we’re creating a box so we can see our messages that are sent from the clients (as well as our own sent messages), secondly, we then create an input that allows the user to input a message, and finally…we create a button that allows a user to send a message!
I’m going to presume you already know what the script tags do, but what does (function() {})() do? Well, that's an immediately invoked function! An immediately invoked function expression just runs as soon as it's defined. So as soon as we call define this function, we invoke the function--basically we run it.

.. code:: js

        
    const sendBtn = document.querySelector('#send');
    const messages = document.querySelector('#messages');
    const messageBox = document.querySelector('#messageBox');
    Here, we’re just selecting our button, messages, and input DOM elements. Once we've got those selected, we go ahead and create an empty expression let ws; we need this later on.
    function showMessage(message) {
      messages.textContent += `\n\n${message}`;
      messages.scrollTop = messages.scrollHeight;
      messageBox.value = '';
    }

Here what we’re doing is just having a function that we can call when we pass it a message, it just goes in and uses the messages selector, adds the text and then we clear the sent message from the user's message box.


.. code:: js

        
    function init() {
      if (ws) {
        ws.onerror = ws.onopen = ws.onclose = null;
        ws.close();
      }

      ws = new WebSocket('ws://localhost:6969');
      ws.onopen = () => {
        console.log('Connection opened!');
      }
      ws.onmessage = ({ data }) => showMessage(data);
      ws.onclose = function() {
        ws = null;
      }
    }
The init function is basically built so that we can separate out our implementation of the connection to the server. What we do is we check if there's a connection already for the user if there is a connection, we go ahead and null the connection and then close it. Following that, if the user doesn't have a connection, we initialise a new connection to the server ws = new WebSocket('ws://localhost:6969');.
Once we have a connection to the server, we simply console.log a message that states we have successfully connected to the server.


.. code:: js

        
    ws.onopen = () => {
      console.log('Connection opened!');
    }

Following the above, we then proceed to check for a message. 

If there’s a message we pass it to showMessage, and we then add it to the chatbox by using our function that we created earlier. Lastly, if the connection closes, we just null that particular connection by using ws = null;.

Furthermore, we then find ourselves at the sendBtn part of the code, now this is quite self-explanatory, but let's make sure we fully understand what is going on here.

So we have sendBtn.onclick, which is our trigger to send a message. 
We first check if there's currently not an active web socket connection by checking if (!ws). The reason we do this is that we don't want to try to send a message if there's no web socket connection. If there isn't a web socket connection, we just return No WebSocket connection :(. If there is a web socket connection, we fire the message to the server with ws.send(messageBox.value), we then show the message in our message box.

And lastly, the most important part, we run our init function by invoking it with init();.

And we are done!

To run the server, just use yarn start and you should see Server is listening on 6969!. Then if you go ahead and open up index.html in your browser (try it in 2 different browsers), you'll see that if you send a message in one of the windows, you'll get the sent messages to appear in all your open browser connections!

—
🎥 If you enjoyed this little tip, subscribe to my YouTube channel where I post React, JavaScript, GraphQL videos — and of course quick tips! I’m also on Twitter — feel free to @ me with any questions!