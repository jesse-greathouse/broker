-- methods for fixing parsed content on the front end

local GoogleFilter = {
    url = nil
}

local function remove_mngb(htmlstr)
    return string.gsub(htmlstr, "<div id=\"mngb\">(.-)</div>", "")
end

local function remove_guser(htmlstr)
    return string.gsub(htmlstr, "<div id=guser (.-)>(.-)</div>", "")
end

local function remove_advanced_search(htmlstr)
    return string.gsub(htmlstr, "<td class=\"fl sblc\" (.-)>(.-)</td>", "")
end

local function remove_footer(htmlstr)
    return string.gsub(htmlstr, "<span id=\"footer\">(.-)</span>", "")
end

local function remove_logo_padding(htmlstr)
    return string.gsub(htmlstr, "style=\"padding:28px 0 14px\"", "")
end

local function replace_uri(htmlstr)
    return string.gsub(htmlstr, "\"/search", "\"".. ngx.var.uri .. "/search")
end

function GoogleFilter:get_url()
    if not GoogleFilter.url then
        local protocol = ngx.var.protocol
        local domain = ngx.var.hostname
        local uri = ngx.var.uri
        GoogleFilter.url = table.concat({protocol, "://", domain, uri})
    end

    return GoogleFilter.url
end

function GoogleFilter:head_js(head_js)
    head_js = replace_uri(head_js)

    return head_js
end

function GoogleFilter:body(body)
    body = remove_mngb(body)
    body = remove_guser(body)
    body = remove_advanced_search(body)
    body = remove_footer(body)
    body = remove_logo_padding(body)
    body = replace_uri(body)

    return body
end

function GoogleFilter:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleFilter