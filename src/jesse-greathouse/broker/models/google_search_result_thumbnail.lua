local helpers = require "helpers"

--
-- class GoogleSearchResultThumbnail
--
local GoogleSearchResultThumbnail = {}

local defaults = {
    style           = "",
    alt             = "",
    src             = "",
    id              = "",
    js              = "",
    data_deferred   = ""
}

function GoogleSearchResultThumbnail:new(o)
    o = o or {}
    o = helpers.model_set_defaults(o, defaults)
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleSearchResultThumbnail