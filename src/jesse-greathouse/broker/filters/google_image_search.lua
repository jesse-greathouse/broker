-- methods for fixing parsed content on the front end
local helpers = require "helpers"

local GoogleImageSearchFilter = {
    url = nil
}

local function remove_guser(htmlstr)
    return string.gsub(htmlstr, "<div id=guser (.-)>(.-)</div>", "")
end

local function remove_center(htmlstr)
    return string.gsub(htmlstr, "<center>(.-)</center>", "")
end

local function remove_logo_padding(htmlstr)
    return string.gsub(htmlstr, "style=\"padding:28px 0 14px\"", "")
end

local function replace_uri(htmlstr)
    return string.gsub(htmlstr, "\"/search", "\"/google/search")
end

local function replace_google_urls(htmlstr)
    return string.gsub(htmlstr, "https://(.-).google.com/", "/google/")
end

local function replace_google_links(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "href=\"\\/url\\?q=([\\%\\--\\/0-9\\:A-Z_a-z]+)(&amp;[a-z]+=[\\-0-9A-Z_a-z]+)+", "href=\"$1", "i")
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "GoogleImageSearchFilter replace_google_links: ", err)
        return htmlstr
    end
end

local function remove_search_tips(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "<br><font size=\"-1\"><nobr><a href=\"\\/intl\\/en\\/help.html\">Search&nbsp;Tips<\\/a><\\/nobr><\\/font>", "", "U")
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "GoogleImageSearchFilter remove_search_tips: ", err)
        return htmlstr
    end
end

local function remove_advanced_search(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "<font size=\"-2\"><a href=\"\\/advanced_search\\?.*Preferences<\\/a><\\/font>", "", "U")
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "GoogleImageSearchFilter remove_advanced_searchs: ", err)
        return htmlstr
    end
end

function GoogleImageSearchFilter:get_url()
    if not GoogleImageSearchFilter.url then
        local protocol = ngx.var.protocol
        local domain = ngx.var.hostname
        local uri = ngx.var.uri
        GoogleImageSearchFilter.url = table.concat({protocol, "://", domain, uri})
    end

    return GoogleImageSearchFilter.url
end

function GoogleImageSearchFilter:head_js(head_js)
    head_js = replace_uri(head_js)

    return head_js
end

function GoogleImageSearchFilter:head_style(head_style)

    return head_style
end

function GoogleImageSearchFilter:body(body)
    body = remove_search_tips(body)
    body = remove_advanced_search(body)
    body = remove_guser(body)
    body = remove_center(body)
    body = remove_logo_padding(body)
    body = replace_uri(body)
    body = replace_google_links(body)
    body = replace_google_urls(body)

    return body
end


function GoogleImageSearchFilter:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleImageSearchFilter