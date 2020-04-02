-- The Google Search Client
local b64 = require "ngx.base64"
local helpers = require "helpers"
local cjson = require "cjson"

local GoogleClient = {
    base_url            = "www.google.com",
    protocol            = "https",
    cache_expire        = 60,
    keepalive_timeout   = 60,
    keepalive_pool      = 10,
    bad_args            = {
        'iflsig', 'oq', 'gs_l', 'aqs', 'biw',
         'bih', 'source', 'gbv', 'sa', 'ei', 'ved'
    }
}

local function filter_args(args)
    local p = {}

    for key, val in pairs(args) do
        if not helpers.in_array(GoogleClient.bad_args, key) then
            if type(val) == "table" then
                p[key] = table.concat(val, ",")
            else
                p[key] = val
            end
        end
    end

    return p
end

function GoogleClient:get_cache(uri, args)
    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect(ngx.var.REDIS_HOST, 6379)
    if not ok or ok == ngx.null then
        return nil, err
    end
    local res, e = red:get(self:get_cache_key(uri, args))
    if not res or res == ngx.null then
        return nil, e
    end
    -- decode and deserlalize the object
    res = cjson.decode(b64.decode_base64url(res))
    return res, err
end

function GoogleClient:save_cache(uri, args, data)
    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect(ngx.var.REDIS_HOST, 6379)
    if not ok or ok == ngx.null then
        return nil, err
    end
    local cache_key = self:get_cache_key(uri, args)
    -- convert data table into a saveable string
    local res = b64.encode_base64url(cjson.encode(data))
    res, err = red:set(cache_key, res)
    red:expire(cache_key, GoogleClient.cache_expire)
    return res, err
end

function GoogleClient:compose_url(uri, args)
    local url = { GoogleClient.protocol, "://", GoogleClient.base_url, uri, "?" }
    url[#url+1] = helpers.format_query(filter_args(args))
    return table.concat(url)
end

function GoogleClient:get_cache_key(uri, args)
    local url = GoogleClient.base_url .. uri
    local base = string.gsub(url, "/", ":")
    local query = helpers.format_query(filter_args(args), ":")
    return base .. ":" .. query
end

function GoogleClient:search(args)
    return self:request("/search", args)
end

function GoogleClient:home(args)
    return self:request("/", args)
end

function GoogleClient:request(uri, args)
    local http = require "resty.http"
    local httpc = http.new()
    local err = {}
    args = filter_args(args)

    local response, _ = self:get_cache(uri, args)
    if not response then
        local url = self:compose_url(uri, args)

        local ok, res = pcall(httpc.request_uri, httpc, url, {
            method = "GET",
            ssl_verify = false,
            keepalive_timeout = GoogleClient.keepalive_timeout,
            keepalive_pool = GoogleClient.keepalive_pool
        })

        if not ok then
            err.error = "Request failed: (" .. url .. ")"
            err.message = res
            ngx.log(ngx.ERR, err.message)
            error(err.message)
        else
            response = {
                body        = res.body,
                has_body    = res.has_body,
                headers     = res.headers,
                reason      = res.reason,
                status      = res.status,
                url         = url
            }

            self:save_cache(uri, args, response)
        end
    end

    return response, err
end

function GoogleClient:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleClient