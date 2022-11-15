基于 ws.js 的 Websocket 多房间
==============================

> `多房间 <https://gist.github.com/Globik/5a63e8683ab1d1c2c72fd25a798ae2d8>`_


index.html

.. code-block:: html

    <html>
        <body>
            <h4>websocket</h4>
            <h5>Group: <span id="group">darwin</span></h5>
            <!-- a hardoced group name -->
            <button onclick="bjoin();">join group</button><br>
            <input id="text" type="text"/>
            <span id="out"></span>
            <script>
                var group=document.getElementById("group").textContent;

                var ws=new  WebSocket('ws://localhost:5000');
                ws.onerror=function(e){out.innerHTML=e;}
                ws.onclose=function(e){out.innerHTML='closed'+e;}
                ws.onopen=function(){
                    out.innerHTML='connected ';
                }
                ws.onmessage=function(ms){out.innerHTML+=ms.data+'<br>';}
                function send(msg){
                    ws.send(JSON.stringify({msg:msg}));
                }
                function broadcast(msg,room){
                    ws.send(JSON.stringify({room:room,msg:msg}))
                }
                function join(room){
                    ws.send(JSON.stringify({join:room}));
                }
                function bjoin(){
                    //alert(group);
                    join(group);
                }
                text.onchange=function(el){
                    //alert(el.target.value);
                    broadcast(el.target.value,group);
                }
            </script>
        </body>
    </html>

server.js

.. code-block:: js

    const WebSocket = require('ws');
    const http=require('http');

    const express = require('express');
    const app = express();

    app.use(express.static('public'));
    const bserver=http.createServer(app);
    const webPort = 5000;

    bserver.listen(webPort, function(){
        console.log('Web server start. http://localhost:' + webPort );
    });
    const wss=new WebSocket.Server({server:bserver});

    wss.on('connection',ws=>{
        ws.room=[];
        ws.send(JSON.stringify({msg:"user joined"}));
        console.log('connected');
        ws.on('message', message=>{
            console.log('message: ',message);
            //try{
            var messag=JSON.parse(message);
            //}catch(e){console.log(e)}
            if(messag.join){ws.room.push(messag.join)}
            if(messag.room){broadcast(message);}
            if(messag.msg){console.log('message: ',messag.msg)}
        })

        ws.on('error',e=>console.log(e))
        ws.on('close',(e)=>console.log('websocket closed'+e))
    })

    function broadcast(message){
        wss.clients.forEach(client=>{
            if(client.room.indexOf(JSON.parse(message).room)>-1){
                client.send(message)
            }
        })
    }