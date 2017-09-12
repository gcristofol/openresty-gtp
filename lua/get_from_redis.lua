--[[
#redis tiny client
Uses cache to retrive bearer
]]

local red = redis:new()
                
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
	ngx.say("failed to connect: ", err)
	return
end

--TODO grab this param from header
local documentId = "1";

local res, err = red:get("authtoken" .. documentId)
--ngx.say("set result: ", res)
--ngx.var.foo = res
ngx.log(ngx.WARN, "GET VARIABLE " .. res)
ngx.var.foo = res
