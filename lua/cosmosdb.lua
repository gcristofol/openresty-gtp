--[[
#CosmosDB tiny client
Uses HMAC/sha256 to retrieve documents from Azure Cosmosdb
]]



local gsub = string.gsub
local byte = string.byte
local format = string.format


--[[
#globals
]]

local masterKey = os.getenv ('COSMOSDB_MASTERKEY');

local _date = os.date("!%a, %d %b %Y")
local _time = os.date("!*t")
local utc_date = string.format("%s %02d:%02d:%02d GMT", _date, _time.hour, _time.min , _time.sec)
utc_date = string.lower(utc_date)


--[[
#Functions
]]

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
	signature = ngx.encode_base64(dgst)
	UrlEncodedString = ngx.escape_uri(string.format("type=%s&ver=%s&sig=%s", keyType, tokenVersion, signature))
	return UrlEncodedString
end

local function FetchDocumentById(documentId)
	ngx.req.set_header("x-ms-date", utc_date)
	ngx.req.set_header("x-ms-version", "2015-08-06")
	--ngx.req.set_header("x-ms-partitionkey", "/apikey")
	--ngx.req.set_header("x-ms-documentdb-partitionkey", "/apikey")

	--Get document from database
	local verb = "GET";
	local resourceType = "docs";
	local databaseId = "VistaMXTProxy";
	local collectionId = "Users2";

	local resourceType = "docs";
	local resourceLink = string.format("dbs/%s/colls/%s/docs/%s", databaseId, collectionId, documentId);

	--[[
	#call azure cosmosdb for this resource link
	]]
	authHeader = GenerateMasterKeyAuthorizationSignature(verb, resourceLink, resourceType, masterKey, "master", "1.0");
	ngx.req.set_header("authorization", authHeader)
	local res = ngx.location.capture("/" .. resourceLink, { method = ngx.HTTP_GET })
	if res then
		 value = cjson.decode(res.body)
		 ngx.log(ngx.WARN, "retrieved value  " .. res.body )
		 return value.authtoken, value.clientSecret
	end		
end

--[[
#Main script
]]

--Grab tocken that identifies the document param from header
local documentId = ngx.req.get_headers()["X-My-Header"]
ngx.log(ngx.WARN, "Document id header: ", documentId)

 if documentId == nil then
	ngx.log(ngx.WARN, "No token in the headers ")
	ngx.exit(ngx.HTTP_FORBIDDEN)
 end

local memcache = ngx.shared.memcache
local authtoken = memcache:get("authtoken" .. documentId)
if authtoken == nil then
	authtoken, clientSecret = FetchDocumentById(documentId)
	ngx.log(ngx.WARN, "Populate memcache with " .. documentId .. " document")
	memcache:set("authtoken" .. documentId, authtoken)
	memcache:set("clientSecret" .. documentId, clientSecret)
else
	ngx.log(ngx.WARN, "authtoken already in cache ")
end
-- populate variables and headers
ngx.req.set_header("MX-Api-Client-Secret", memcache:get("clientSecret" .. documentId))
ngx.var.authtoken = authtoken
