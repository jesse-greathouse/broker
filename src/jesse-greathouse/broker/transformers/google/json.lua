--
-- class GoogleJsonTransformer
--
local GoogleJsonTransformer = {
    parser              = nil,
    s                   = nil,
    summarry            = nil,
    summarry_thumbnails = nil,
    results             = nil,
}

local function get_query_from_url(url)
    return string.match(url, ".*q=([0-9A-Za-z_%%,%-%+:;=%?@]+)[&|$]?.*")
end

local function get_start_from_url(url)
    return string.match(url, ".*start=([0-9]+)[&|$]?.*")
end

function GoogleJsonTransformer:get_summarry_thumbnails()
    if not self.summarry_thumbnails then
        self.summarry.thumbnails = {}
        local GoogleSearchSummarryThumbnail = require "models.google_search_summarry_thumbnail"
        local list = self.parser:get_search_summarry_thumbnail_list()
        for _, item in ipairs(list) do
            self.summarry.thumbnails[#self.summarry.thumbnails+1] = GoogleSearchSummarryThumbnail:new(item)
        end
    end

    return self.summarry.thumbnails
end

function GoogleJsonTransformer:get_summarry()
    if not self.summarry then
        self.summarry = require "models.google_search_summarry":new()
        self.summarry.header = self.parser:get_search_summarry_header()
        self.summarry.sub_header = self.parser:get_search_summarry_sub_header()
        self.summarry.description = self.parser:get_search_summarry_details()
        self.summarry.thumbnails = self:get_summarry_thumbnails()
    end

    return self.summarry
end

function GoogleJsonTransformer:get_results()
    if not self.results then
        self.results = {}
        
        local GoogleSearchResult = require "models.google_search_result"
        local list = self.parser:get_search_result_list()
        for _, item in ipairs(list) do
            self.results[#self.results+1] = GoogleSearchResult:new(item)
        end
    end

    return self.results
end

function GoogleJsonTransformer:search()
    if not self.s then
        self.s = require "models.google_search":new()
        self.s.summarry = self:get_summarry()
        self.s.url = self.parser.url
        self.s.query = get_query_from_url(self.s.url)
        self.s.start = get_start_from_url(self.s.url)
        self.s.summarry = self:get_summarry()
        self.s.results = self:get_results()
    end

    return self.s
end

function GoogleJsonTransformer:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return GoogleJsonTransformer