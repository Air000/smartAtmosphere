
function smartconfig()
    print("Smartconfig mode")
    wifi.setmode(wifi.STATION)
    wifi.stopsmart()
    wifi.startsmart(1,
        function(ssid, password)
            print(string.format("Success. SSID:%s ; PASSWORD:%s", ssid, password))
            wifi.sta.config(ssid, password)
            wifi.sta.connect()
        end
    )
end

uart.setup(0, 9600, 8, 0 ,1, 1)
wifi.sta.autoconnect(1)
gpio.mode(3,gpio.INT)
gpio.trig(3, "down", smartconfig)

wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("STATION_IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)
wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("STATION_GOT_IP") end)
