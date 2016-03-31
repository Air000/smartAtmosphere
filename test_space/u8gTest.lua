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

init_i2c_display()
prepare()
strPM1 = ('PM1 %s'):format(100)
strPM25 = ('PM2.5 %s'):format(123)
strPM10 = ('PM10 %s'):format(111)
disp:firstPage()
repeat
    disp:setColorIndex(0)
    disp:drawBox(0,0,128,64)
    disp:setColorIndex(1)
    disp:drawStr(0,12,strPM1)
    disp:drawStr(0,22,strPM25)
    disp:drawStr(0,32,strPM10)
until disp:nextPage() == false

--disp:setColorIndex(0)
--disp:drawBox(0,0,128,64)
--disp:drawStr(0,20,'Hello')