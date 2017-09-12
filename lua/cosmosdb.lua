--[[
#CosmosDB tiny client

Uses HMAC/sha256 to retrieve documents from Azure Cosmosdb

]]


local hmac = require "resty.nettle.hmac"
local gsub = string.gsub
local byte = string.byte
local format = string.format

local masterKey = "aEgL5VpsobIllPTHDK0XMmXZzzk5itw9lH5ZWizQAiTeunA0LyNMiHfV0dTKz7T71o656UFfMaaNaztH5yKXPw==";

local _date = os.date("!%a, %d %b %Y")
local _time = os.date("!*t")
local utc_date = string.format("%s %02d:%02d:%02d GMT", _date, _time.hour, _time.min , _time.sec)
utc_date = string.lower(utc_date)
--print (utc_date)
--utc_date = "mon, 11 sep 2017 23:53:38 gmt"

ngx.req.set_header("x-ms-date", utc_date)
ngx.req.set_header("x-ms-version", "2015-08-06")
--ngx.req.set_header("x-ms-partitionkey", "/apikey")
--ngx.req.set_header("x-ms-documentdb-partitionkey", "/apikey")

local function hex(str,spacer)
	return (gsub(str,"(.)", function (c)
		return format("%02X%s", byte(c), spacer or "")
	end))
end

local function GenerateMasterKeyAuthorizationSignature(verb, resourceId, resourceType, masterKey, keyType, tokenVersion)

	local key = ngx.decode_base64(masterKey)
	local payload = string.format("%s\n%s\n%s\n%s\n%s\n", string.lower(verb), string.lower(resourceType), resourceId, utc_date, "")
	
	local hash = hmac.sha256.new(key)
	hash:update(payload)
	local dgst = hash:digest()
	--print("hmac sha256", #dgst, hex(dgst), dgst)
	
	signature = ngx.encode_base64(dgst)
	--print ('signature ' .. signature);
	
	UrlEncodedString = ngx.escape_uri(string.format("type=%s&ver=%s&sig=%s", keyType, tokenVersion, signature))
	return UrlEncodedString
end

--TODO grab this param from header
local documentId = "1";

--Get document from database
local verb = "GET";
local resourceType = "docs";
local databaseId = "VistaMXTProxy";
local collectionId = "Users2";


local resourceType = "docs";
local resourceLink = string.format("dbs/%s/colls/%s/docs/%s", databaseId, collectionId, documentId);


authHeader = GenerateMasterKeyAuthorizationSignature(verb, resourceLink, resourceType, masterKey, "master", "1.0");
--print ('authHeader ' .. authHeader);


ngx.req.set_header("authorization", authHeader)

local res = ngx.location.capture("/" .. resourceLink, { method = ngx.HTTP_GET })
if res then
	 --ngx.log(ngx.WARN, "SET VARIABLE " .. documentId .. " IN CACHE")
	 value = cjson.decode(res.body)
     cache:set("authtoken" .. documentId, value.authtoken)
end		

ngx.req.clear_header("authorization")	

--[[
#redis tiny client
Uses cache to set bearer
]]

local red = redis:new()
                
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
	ngx.say("failed to connect: ", err)
	return
end

ngx.log(ngx.WARN, "SET VARIABLE authtoken" .. value.authtoken .. " REDIS  CACHE")
ok, err = red:set("authtoken" .. documentId, value.authtoken)
if not ok then
	ngx.say("failed to set authtoken: ", err)
	return
end

--ngx.say("set result: ", ok)
