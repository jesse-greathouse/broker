local helpers = require "helpers"

--
-- class GoogleSearchSummarryThumbnail
--
local GoogleSearchSummarryThumbnail = {}

local defaults = {
    imgurl          = "",
    style           = "",
    alt             = "",
    src             = "",
    id              = "",
    js              = "",
    data_deferred   = ""
}

function GoogleSearchSummarryThumbnail:new(o)
    o = o or {}
    o = helpers.model_set_defaults(o, defaults)
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleSearchSummarryThumbnail