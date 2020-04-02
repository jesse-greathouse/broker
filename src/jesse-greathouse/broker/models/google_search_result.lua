local helpers = require "helpers"

--
-- class GoogleSearchResult
--
local GoogleSearchResult = {}

local function default_thumbnail(o)
    if o.thumbnail then
        return require "models.google_search_result_thumbnail":new()
    end

    return ""
end

local defaults = {
    url                     = "",
    header                  = "",
    header_url              = "",
    description             = "",
    thumbnail               = default_thumbnail
}

function GoogleSearchResult:new(o)
    o = o or {}
    o = helpers.model_set_defaults(o, defaults)
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleSearchResult