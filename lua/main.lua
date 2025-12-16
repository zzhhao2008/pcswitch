-- LuaTools需要PROJECT和VERSION这两个信息
PROJECT = "PCSwitch"
VERSION = "1.0.0"

-- sys库是标配
_G.sys = require("sys")
-- 初始化LED灯, 开发板上左右2个led分别是gpio12/gpio13
local LEDA = gpio.setup(12, 0, gpio.PULLUP)
local LEDB = gpio.setup(13, 0, gpio.PULLUP)

gpiocondition = {0, 0, 0, 0, 0, 0}

PINS = {2, 3, 12, 13}

require("func")
require("secrets")

gpio.debounce(1, 100)
gpio.debounce(0, 100)

function setGPIO(pinid, pinvalue)
    if (pinvalue == 0 or pinvalue == 1) then
        gpio.set(pinid, pinvalue)
        gpiocondition[pinid] = pinvalue
        return true
    end
    return false
end

sys.taskInit(function()
    local i = 2
    while i <= 3 do
        gpio.setup(i, 0, gpio.PULLUP)
        i = i + 1
    end
    sys.wait(1000)
    wlan.init()

    if MASK and IP and GATEWAY then
        wlan.staIp(false, IP, MASK, GATEWAY)
    end

    wlan.connect(WLAN_SSID, WLAN_PASS)
    log.info("wlan", "wait for IP_READY")

    while not wlan.ready() do
        local ret, ip = sys.waitUntil("IP_READY", 30000)
        -- wlan连上之后, 这里会打印ip地址
        log.info("ip", ret, ip)
        if ip then
            _G.wlan_ip = ip
        end
    end

    log.info("wlan", "ready !!", wlan.getMac())
    sys.wait(1000)
    httpsrv.start(80, function(fd, method, uri, headers, body)
        log.info("httpsrv", method, uri, json.encode(headers), body)
        -- meminfo()
        local result = Srv(uri)
        return 200, {}, result
    end)
    log.info("web", "pls open url http://" .. _G.wlan_ip .. "/")
end)

-- 用户代码已结束---------------------------------------------
-- 结尾总是这一句
sys.run()
-- sys.run()之后后面不要加任何语句!!!!!
