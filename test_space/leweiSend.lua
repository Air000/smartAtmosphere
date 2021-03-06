function encodeData(temp, humi, dust)
    postData = { {Name="humidity", Value = humi}, 
                {Name="dust", Value = dust},  
                {Name="temperature", Value = temp} }
                
    ok, postDataJson = pcall(cjson.encode, postData)
    if ok then
        return postDataJson
    else
        print("failed to encode JSON!")
        return nil
    end
end
function sendData2Lewei(data)
      
    print("send data to Lewei")
    sk=net.createConnection(net.TCP,0)
    
    sk:dns("www.lewei50.com", function(conn,ip)
            sk:connect(80,ip)
            print("ip:", ip)
            end)
    sk:on("connection", function(conn)
          print("on connection")  
          sk:send("POST /api/V1/gateway/UpdateSensors/02 HTTP/1.1\r\n"
                    .. "Host: www.lewei50.com\r\n"
                    .. "Content-Length: " .. string.len(data) .. "\r\n"
                    .. "userkey:e8228c92992b47b98617128b0a2a475e" .. "\r\n\r\n"
                    .. data .. "\r\n"
          )
     end)     
    
    sk:on("receive", function(sck, c)
           print("recv:", c)
           end)
end
temp = 100
humi = 100
pm25 = 100

tmr.alarm(1, 10000, 1, function()
    dataPack = encodeData(temp, humi, pm25)
    print("dataPack:", dataPack)
    sendData2Lewei(dataPack)
end)