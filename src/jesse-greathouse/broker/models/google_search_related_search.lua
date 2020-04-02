local helpers = require "helpers"

--
-- class GoogleSearchRelatedSearch
--
local GoogleSearchRelatedSearch = {}

local defaults = {
    url     = "",
    query   = "",
    text    = ""
}

function GoogleSearchRelatedSearch:new(o)
    o = o or {}
    o = helpers.model_set_defaults(o, defaults)
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleSearchRelatedSearch