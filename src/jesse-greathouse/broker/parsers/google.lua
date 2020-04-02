local helpers = require "helpers"

--
-- class GoogleParser
--
local GoogleParser = {
    parse_limit                     = 2000,
    url                             = "",
    parser                          = nil,
    data                            = "",
    filter                          = nil,
    root                            = nil,
    body                            = nil,
    head                            = nil,
    header                          = nil,
    title                           = nil,
    jsmodel                         = nil,
    meta                            = nil,
    head_js                         = nil,
    head_style                      = nil,
    header_js                       = nil,
    footer_js                       = nil,
    dimg                            = {},
    noscript                        = nil,
    main                            = nil,
    image_grid                      = nil,
    search_form                     = nil,
    search_results                  = nil,
    search_result_list              = nil,
    search_summarry                 = nil,
    search_summarry_header          = nil,
    search_summarry_sub_header      = nil,
    search_summarry_thumbnails      = nil,
    search_summarry_thumbnail_list  = nil,
    search_summarry_description     = nil,
    related_searches                = nil,
}

local function compose_element(e, no_content)
    local buf = {}
    buf[#buf+1] = "<"
    buf[#buf+1] = e.name
    buf[#buf+1] = " "
    for key, value in pairs(e.attributes) do
        buf[#buf+1] = key
        buf[#buf+1] = "=\""
        buf[#buf+1] = value
        buf[#buf+1] = "\" "
        buf[#buf+1] =  ">\n"
        if not no_content then
            buf[#buf+1] =  e:getcontent()
            buf[#buf+1] = "</"
            buf[#buf+1] = e.name
            buf[#buf+1] = ">\n"
        end
    end
    return table.concat(buf)
end

local function compose_thumbnail_table(img, dimg)
    local thumbnail = {}
    thumbnail.style = img.attributes["style"]
    thumbnail.alt = img.attributes["alt"]
    thumbnail.src = img.attributes["src"]
    thumbnail.id = img.attributes["id"]
    thumbnail.data_deferred = img.attributes["data-deferred"]
    if (dimg[thumbnail.id]) then
        thumbnail.js = dimg[thumbnail.id]
    end

    return thumbnail
end

local function compose_search_result_table(e, parser)
    local item = {}
    local content = parser.parser.parse(e:getcontent(), GoogleParser.parse_limit)
    local link = content:select("div.kCrYT > a")
    local a  = next(link)
    if a then
        item.url = parser.filter:get_linkurl(link[a].attributes["href"])
        local header = content:select("div.kCrYT > a > div.BNeawe.vvjwJb.AP7Wnd")
        local h  = next(header)
        if h then
            item.header = header[h]:getcontent()
        end
        local header_url = content:select("div.kCrYT > a > div.BNeawe.UPmit.AP7Wnd")
        local hu  = next(header_url)
        if hu then
            item.header_url = header_url[hu]:getcontent()
        end
    end

    local img = content:select("img.EYOsld")
    local i  = next(img)
    if i then
        item.thumbnail = compose_thumbnail_table(img[i], parser.dimg)
    end

    local description = content:select("div.kCrYT > div > div.BNeawe.s3v9rd.AP7Wnd > div > div > div.BNeawe.s3v9rd.AP7Wnd")
    local d  = next(description)
    if d then
        item.description = parser.filter:fix_description_urls(description[d]:getcontent())
    end

    return item
end


-- html parser does not select the script element
-- this function will handle javascript elements
function GoogleParser:parsejs(htmlstr)
    local scripts ={}
    local js = {}
    if not htmlstr then return "" end
    for nonce, content in string.gmatch(htmlstr, "<script nonce=\"(.-)\">(.-)</script>") do
        local s = {
            nonce = nonce,
            content = content
        }
        table.insert(scripts, s)
    end

    js[#js+1] = "<!-- Open Javascript -->\n"
    for _, script in pairs(scripts) do
        local buf = {}
        buf[#buf+1] = "<script nonce=\""
        buf[#buf+1] = script.nonce
        buf[#buf+1] =  "\">\n"
        buf[#buf+1] =  script.content
        buf[#buf+1] = " \n</script>\n"
        local script_tag =  table.concat(buf)
        js[#js+1] = script_tag

        -- if the script is an encoded image
        -- save it to the dimg table
        local dimg_id = string.match(script.content, "'dimg_([0-9]+)'")
        if dimg_id then
            self.dimg["dimg_" .. dimg_id] = script_tag
        end

    end
    js[#js+1] = "<!-- End Javascript -->\n"
    return table.concat(js)
end

-- this function will handle style elements
function GoogleParser:parsestyle(elements)
    local scr = {}
    scr[#scr+1] = "<!-- Open Style -->\n"
    for _, e in ipairs(elements) do
        scr[#scr+1] = compose_element(e)
    end
    scr[#scr+1] = "<!-- End Style -->\n"
    return table.concat(scr)
end

function GoogleParser:get_root()
    if not self.root then
        self.root = self.parser.parse(self.data, self.parse_limit)
    end

    return self.root
end

function GoogleParser:get_body()
    if not self.body then
        local root = self:get_root()
        local elements = root:select("body")
        local e = next(elements)
        if e then
            self.body = elements[e]:getcontent()
            self.jsmodel = elements[e].attributes.jsmodel
        end

        if self.filter and self.filter.body then
            self.body = self.filter:body(self.body)
        end
    end

    return self.body
end

function GoogleParser:get_head()
    if not self.head then
        local root = self:get_root()
        local elements = root:select("head")
        local e = next(elements)
        if e then
            self.head = elements[e]:getcontent()
        end
    end

    return self.head
end

function GoogleParser:get_header()
    if not self.header then
        local root = self.parser.parse(self:get_body(), self.parse_limit)
        local elements = root:select("header")
        local e = next(elements)
        if e then
            self.header = elements[e]:getcontent()
        end
    end

    return self.header
end

function GoogleParser:get_title()
    if not self.title then
        local root = self.parser.parse(self:get_head(), self.parse_limit)
        local elements = root:select("title")
        local e = next(elements)
        if e then
            self.title = elements[e]:getcontent()
        end
    end

    return self.title
end

function GoogleParser:get_jsmodel()
    if not self.jsmodel then
        local _ = self:get_body()
    end

    return self.jsmodel
end

function GoogleParser:get_main()
    if not self.main then
        local root = self.parser.parse(self:get_body(), self.parse_limit)
        local elements = root:select("#main")
        local e = next(elements)
        if e then
            self.main = elements[e]:getcontent()
        end

        if self.filter and self.filter.main then
            self.main = self.filter:main(self.main)
        end
    end

    return self.main
end

function GoogleParser:get_related_searches()
    if not self.related_searches then
        local _ = self:get_search_results()
    end

    return self.related_searches
end


function GoogleParser:get_search_summarry()
    if not self.search_summarry then
        local _ = self:get_search_results()
    end

    return self.search_summarry
end

function GoogleParser:get_search_summarry_header()
    if not self.search_summarry_header then
        local root = self.parser.parse(self:get_search_summarry(), self.parse_limit)
        local elements = root:select("div.kCrYT > span > div.BNeawe.deIvCb.AP7Wnd")
        local e = next(elements)
        if e then
            self.search_summarry_header = elements[e]:getcontent()

            if self.filter and self.filter.search_summarry_header then
                self.search_summarry_header = self.filter:search_summarry_header(self.search_summarry_header)
            end
        end
    end

    return self.search_summarry_header
end

function GoogleParser:get_search_summarry_sub_header()
    if not self.search_summarry_sub_header then
        local root = self.parser.parse(self:get_search_summarry(), self.parse_limit)
        local elements = root:select("div.kCrYT > span > div.BNeawe.tAd8D.AP7Wnd")
        local e = next(elements)
        if e then
            self.search_summarry_sub_header = elements[e]:getcontent()

            if self.filter and self.filter.search_summarry_sub_header then
                self.search_summarry_sub_header = self.filter:search_summarry_sub_header(self.search_summarry_sub_header)
            end
        end
    end

    return self.search_summarry_sub_header
end

function GoogleParser:get_search_summarry_details()
    if not self.search_summarry_details then
        local root = self.parser.parse(self:get_search_summarry(), self.parse_limit)
        local elements = root:select("div.xpc")
        local e = next(elements)
        if e then
            self.search_summarry_details = elements[e]:getcontent()

            if self.filter and self.filter.search_summarry_details then
                self.search_summarry_details = self.filter:search_summarry_details(self.search_summarry_details)
            end
        end
    end

    return self.search_summarry_details
end

function GoogleParser:get_search_summarry_thumbnails()
    if not self.search_summarry_thumbnails then
        local root = self.parser.parse(self:get_search_summarry(), self.parse_limit)
        local elements = root:select(".idg8be")
        local e = next(elements)
        if e then
            self.search_summarry_thumbnails = elements[e]:getcontent()

            if self.filter and self.filter.search_summarry_thumbnails then
                self.search_summarry_thumbnails = self.filter:search_summarry_thumbnails(self.search_summarry_thumbnails)
            end
        end
    end

    return self.search_summarry_thumbnails
end

function GoogleParser:get_search_summarry_thumbnail_list()
    if not self.search_summarry_thumbnail_list then
        -- first get the footer_js to index images encoded by js
        local _ = self:get_footer_js()

        local root = self.parser.parse(self:get_search_summarry_thumbnails(), self.parse_limit)
        local elements = root:select(".BVG0Nb")
        self.search_summarry_thumbnail_list = {}
        for _, e in ipairs(elements) do
            local thumbnail = {}
            local content = self.parser.parse(e:getcontent(), self.parse_limit)
            local img = content:select(".WddBJd")
            local i = next(img)
            if i then
                thumbnail = compose_thumbnail_table(img[i], self.dimg)
            end
            thumbnail.imgurl = self.filter:get_imgurl(e.attributes["href"])
            self.search_summarry_thumbnail_list[#self.search_summarry_thumbnail_list+1] = thumbnail
        end

    end

    return self.search_summarry_thumbnail_list
end


function GoogleParser:get_search_results()
    if not self.search_results then
        local root = self.parser.parse(self:get_main(), self.parse_limit)
        local elements = root:select("div > div.ZINbbc.xpd.O9g5cc.uUPGi:not(#st-card)")
        local length = helpers.tablelength(elements)

        if length > 0 then
            local count = 1
            local scr = {}
            for _, e in ipairs(elements) do
                local htmlstr = compose_element(e)

                -- if it's the first element it's the search_summarry
                -- if it's not the last 2 elements it's search_results
                -- ignore the last element it's not a result
                if count == 1 then
                    self.search_summarry = htmlstr

                    if self.filter and self.filter.search_summarry then
                        self.search_summarry  = self.filter:search_summarry(self.search_summarry)
                    end
                elseif count == (length - 1) then
                    self.related_searches = htmlstr

                    if self.filter and self.filter.related_searches then
                        self.related_searches  = self.filter:related_searches(self.related_searches)
                    end
                elseif count ~= length then
                    scr[#scr+1] = htmlstr
                end
                count = count + 1
            end

            self.search_results = table.concat(scr)

            if self.filter and self.filter.search_results then
                self.search_results = self.filter:search_results(self.search_results)
            end
        end
    end

    return self.search_results
end

function GoogleParser:get_search_result_list()
    if not self.search_result_list then
        -- first get the footer_js to index images encoded by js
        local _ = self:get_footer_js()

        local root = self.parser.parse(self:get_search_results(), self.parse_limit)
        local elements = root:select("div.ZINbbc.xpd.O9g5cc.uUPGi")
        self.search_result_list = {}
        for _, e in ipairs(elements) do
            local item = compose_search_result_table(e, self)
            self.search_result_list[#self.search_result_list+1] = item
        end
    end

    return self.search_result_list
end

function GoogleParser:get_image_grid()
    if not self.image_grid then
        local root = self.parser.parse(self:get_body(), self.parse_limit)
        local elements = root:select("table")
        local scr = {}
        for _, e in ipairs(elements) do
            scr[#scr+1] = compose_element(e)
        end
        self.image_grid = table.concat(scr)

        if self.filter and self.filter.image_grid then
            self.image_grid = self.filter:image_grid(self.image_grid)
        end
    end

    return self.image_grid
end

function GoogleParser:get_noscript()
    if not self.noscript then
        local root = self.parser.parse(self:get_header(), self.parse_limit)
        local elements = root:select("noscript")
        local scr = {}
        scr[#scr+1] = "<!-- Open Noscript -->\n"
        for _, e in ipairs(elements) do
            scr[#scr+1] = compose_element(e)
        end
        scr[#scr+1] = "<!-- End Noscript -->\n"
        self.noscript = table.concat(scr)
    end

    return self.noscript
end

function GoogleParser:get_meta()
    if not self.meta then
        local root = self.parser.parse(self:get_head(), self.parse_limit)
        local elements = root:select("meta")
        local scr = {}
        scr[#scr+1] = "<!-- Open Meta -->\n"
        for _, e in ipairs(elements) do
            scr[#scr+1] = compose_element(e)
        end
        scr[#scr+1] = "<!-- End Meta -->\n"
        self.meta = table.concat(scr)
    end

    return self.meta
end

function GoogleParser:get_head_style()
    if not self.head_style then
        local root = self.parser.parse(self:get_head(), self.parse_limit)
        self.head_style = self:parsestyle(root:select("style"))

        if self.filter and self.filter.head_style then
            self.head_style = self.filter:head_style(self.head_style)
        end
    end

    return self.head_style
end

function GoogleParser:get_head_js()
    if not self.head_js then
        self.head_js = self:parsejs(self:get_head())

        if self.filter and self.filter.head_js then
            self.head_js = self.filter:head_js(self.head_js)
        end
    end

    return self.head_js
end

function GoogleParser:get_header_js()
    if not self.header_js then
        self.header_js = self:parsejs(self:get_header())
    end

    return self.header_js
end

function GoogleParser:get_footer_js()
    if not self.footer_js then
        self.footer_js = self:parsejs(self:get_body())
    end

    return self.footer_js
end

function GoogleParser:get_search_form()
    if not self.search_form then
        local root = self.parser.parse(self:get_header(), self.parse_limit)
        local elements = root:select("#sf")
        local e = next(elements)
        if e then
            self.search_form = compose_element(elements[e])
        end
    end

    return self.search_form
end

function GoogleParser:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.parser = require "htmlparser"
    return o
end

return GoogleParser