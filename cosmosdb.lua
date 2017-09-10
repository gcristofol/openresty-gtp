-- This is a one-line comment that ends at the end of the line
--[[ This a multi-line (long) [comment](http://www.lua.org/manual/5.1/manual.html#2.1)
     that ends with this closing bracket --> ]]
--[=[ This is also a long comment ]=]

crypto = require("crypto")

function GenerateMasterKeyAuthorizationSignature(verb, resourceId, resourceType, masterKey, master, version)
      --var hmacSha256 = new System.Security.Cryptography.HMACSHA256 { Key = Convert.FromBase64String(key) };

         

             hashPayLoad = crypto.hmac.digest("sha256", "full payload URL to be hashed", "")
  return hashPayLoad
end

--LIST all databases
local verb = "GET";
local resourceType = "dbs";
local resourceId = "";
local resourceLink = "dbs";

authHeader = GenerateMasterKeyAuthorizationSignature(verb, resourceId, resourceType, masterKey, "master", "1.0");
print ('authHeader ' .. authHeader);