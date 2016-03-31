-- setup I2c and connect display
function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     local sda = 5 -- GPIO14
     local scl = 6 -- GPIO12
     local sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
end
function prepare()
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end
function init_pms3003()
    PMset=7
    require('pms3003').init(PMset)
    pms3003.verbose=true -- verbose mode
end
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
      
    print("send data to Lewei",data)
    sk=net.createConnection(net.TCP,0)
    
    sk:dns("www.lewei50.com", function(conn,ip)
            sk:connect(80,ip)
            print(ip)
            end)
    sk:on("connection", function(conn)
          print("on connection");
          sk:send("POST /api/V1/gateway/UpdateSensors/02 HTTP/1.1\r\n"
                    .. "Host: www.lewei50.com\r\n"
                    .. "Content-Length: " .. string.len(data) .. "\r\n"
                    .. "userkey:e8228c92992b47b98617128b0a2a475e" .. "\r\n"
                    .. data .. "\r\n"
          )
     end)     
    
    sk:on("receive", function(sck, c)
           print("receive:", c)
           end)
end

function smartconfig()
    print("Smartconfig mode")
    wifi.setmode(wifi.STATION)
    wifi.startsmart(1,
        function(ssid, password)
            print(string.format("Success. SSID:%s ; PASSWORD:%s", ssid, password))
            wifi.sta.config(ssid, password)
        end
    )
end

function init_dht11(powerPin)
    gpio.mode(powerPin, gpio.OUTPUT)
    gpio.write(powerPin, gpio.LOW)
end

uart.setup(0, 9600, 8, 0 ,1, 0)
init_pms3003()
init_dht11(8)
init_i2c_display()
prepare()
gpio.mode(3,gpio.INT)
gpio.trig(3, "down", smartconfig)

local pm01, pm25, pm10, temp, humi
--tmr.alarm(0, 30000, 1, function() 
---- read pms3003          
--    pms3003.read()
--    pm01 = pms3003.pm01 or 'null'
--    pm25 = pms3003.pm25 or 'null'
--    pm10 = pms3003.pm10 or 'null'
---- read dht11
--    temp,humi = select(2,dht.read11(1))    
---- u8g draw data    
--    disp:firstPage()
--    repeat
--        disp:setColorIndex(0)
--        disp:drawBox(0,0,128,64)
--        disp:setColorIndex(1)
--        disp:drawVLine(64,0,64)
--        disp:drawStr(0,12,('PM1 %s'):format(pm01))
--        disp:drawStr(0,22,('PM2.5 %s'):format(pm25))
--        disp:drawStr(0,32,('PM10 %s'):format(pm10))
--        disp:drawStr(70,12,('Temp %s'):format(temp))
--        disp:drawStr(70,22,('Humi %s'):format(humi))
--    until disp:nextPage() == false
-- 
--end )

tmr.alarm(1, 30000, 1, function()
    print("tmr1: ", temp, humi, pm25)
    if wifi.sta.status() == 5 then
        dataPack = encodeData(temp, humi, pm25)
        sendData2Lewei(dataPack)
    end
end )
