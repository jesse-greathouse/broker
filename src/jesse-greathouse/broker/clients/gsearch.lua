-- The Google Search Client
local helpers = require "helpers"
local cjson = require "cjson"
local http = require "resty.http"
local httpc = http.new()

local BASE_URL = "https://www.google.com/search?"
local ERROR_001 = "No search string was provided for the search"
local ERROR_002 = "Problem with remote request"

local function new()
    local gsearch = {
        BASE_URL = BASE_URL
    }

    local function filter_args(args)
        local p = {}
        for key, val in pairs(args) do
            if type(val) == "table" then
                p[key] = table.concat(val, ",")
            else
                p[key] = val
            end
        end
        return p
    end

    function gsearch.search(args)
        local err = {}
        local params = filter_args(args)

        if not params.q then
            err.error = "ERROR_001"
            err.message = ERROR_001
        end

        local url = gsearch.BASE_URL .. helpers.format_query(filter_args(args))

        local res, error = httpc:request_uri(url, {
            method = "GET",
            ssl_verify = false
        })

        if not res then
            err.error = "ERROR_002"
            err.message = ERROR_002 .. " : " .. error
        end

        return res, err
    end

    return gsearch
end

return new()