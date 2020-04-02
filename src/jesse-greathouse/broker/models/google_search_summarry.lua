local helpers = require "helpers"

--
-- class GoogleSearchSummarry
--
local GoogleSearchSummarry = {}

local defaults = {
    header      = "",
    sub_header  = "",
    thumbnails  = {},
    description = ""
}

function GoogleSearchSummarry:new(o)
    o = o or {}
    o = helpers.model_set_defaults(o, defaults)
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleSearchSummarry