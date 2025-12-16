function split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function containsValue(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function Srv(uri)
    -- 按'/'分割URI
    local pathArr = split(uri, '/')
    if pathArr[2] == nil then
        return json.encode({
            code = 0,
            msg = "参数错误"
        })
    else
        local ordertype = pathArr[2]
        if ordertype == 'setgpio' then
            if pathArr[3] == nil or pathArr[4] == nil then
                return json.encode({
                    code = 0,
                    msg = "参数错误-GPIO PIN NIL"
                })
            else
                local pinid = tonumber(pathArr[3])
                local pinvalue = tonumber(pathArr[4])
                if not containsValue(PINS, pinid) then
                    return json.encode({
                        code = 0,
                        msg = "参数错误-GPIO PIN ERROR"
                    })
                end
                if setGPIO(pinid, pinvalue) then
                    if pathArr[5] then
                        local closetime = tonumber(pathArr[5])*1000
                        if(closetime > 0 and closetime < 11*1000) then
                            sys.timerStart(function()
                                setGPIO(pinid, 0)
                            end, closetime)
                        end
                    end 
                    return json.encode({
                        code = 1,
                        msg = "success",
                        data = gpiocondition
                    })
                end
                return json.encode({
                    code = 0,
                    msg = "FAILED"
                })
            end
        elseif ordertype == "gpiocondition" then
            return json.encode({
                code = 1,
                msg = "success",
                data = gpiocondition
            })
        elseif ordertype == 'readgpio' then
            if pathArr[3] == nil then
                return json.encode({
                    code = 0,
                    msg = "参数错误-GPIO PIN NIL"
                })
            else
                local pinid = tonumber(pathArr[3])
                if (pinid < 0 or pinid > 1) then
                    return json.encode({
                        code = 0,
                        msg = "参数错误-GPIO PIN ERROR"
                    })
                else
                    return json.encode({
                        code = 1,
                        msg = "success",
                        data = gpio.get(pinid)
                    })
                end
            end
        else
            return json.encode({
                code = 0,
                msg = "操作类型错误"
            })
        end
    end
end
