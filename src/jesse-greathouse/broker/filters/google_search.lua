-- methods for fixing parsed content on the front end
local helpers = require "helpers"

local GoogleSearchFilter = {
    url = nil
}

local function fix_search_sbc_style(htmlstr)
    return string.gsub(htmlstr, ".sbc{display:flex;", ".sbc{background:#fff;border-radius:8px 0px 0px 8px;display:flex;")
end

local function replace_google_links(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "href=\"\\/url\\?q=([\\%\\--\\/0-9\\:A-Z_a-z]+)(&amp;[a-z]+=[\\-0-9A-Z_a-z]+)+", "href=\"$1", "i")
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "filter replace_google_links: ", err)
        return htmlstr
    end
end

local function fix_images(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr
        , "(?<=<a class=\"BVG0Nb\" href=\"\\/imgres\\?imgurl=)([\\%\\,\\--\\/0-9\\:\\;\\=\\?\\@A-Z_a-z]+)(&amp;.*\"><div><img class=\"WddBJd\" .* )src=(\"([\\%\\,\\--\\/0-9\\:\\;\\=\\@A-Z_a-z]+)\")(?= id.*><\\/div><\\/a>)"
        , "$1$2src=\"$1\""
        , "U"
    )
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "filter replace_google_links: ", err)
        return htmlstr
    end
end

local function fix_navigation_links(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr
        , "href=\"(\\/google\\/search)\\?((.*)(tbm=([a-z]+)&amp;)(.*))\""
        , "href=\"$1/$5?$2\""
        , "U"
    )
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "filter replace_google_links: ", err)
        return htmlstr
    end
end


local function replace_uri(htmlstr)
    return string.gsub(htmlstr, "\"/search", "\"/google/search")
end

local function replace_google_urls(htmlstr)
    return string.gsub(htmlstr, "href=\"https://www.google.com/", "href=\"/google/")
end

local function replace_image_urls(htmlstr)
    htmlstr = string.gsub(htmlstr, "href=\"/imgres\\?", "href=\"/google/search?tbm=isch&")
    return string.gsub(htmlstr, "href=\"/google/imgres\\?", "href=\"/google/search?tbm=isch&")
end

local function remove_mCljob(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "<footer>(.*)(<div id=\"mCljob\">.*<\\/div>) <\\/footer>", "<footer>$1</footer>", "i")
    if newstr then
        return newstr
    else
        ngx.log(ngx.ERR, "GoogleSearchFilter remove_mCljob: ", err)
        return htmlstr
    end
end

local function fix_search_uri(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "href=\"\\/search\\?", "href=\"/google/search?", "i")
    if newstr then
        return newstr
    else
        ngx.log(ngx.ERR, "GoogleSearchFilter remove_mCljob: ", err)
        return htmlstr
    end
end

local function remove_search_tools(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "<div class=\"FElbsf\"><a href=\"\\/advanced_search\" .*>Search tools<\\/a><\\/div>", "", "U")
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "GoogleSearchFilter remove_search_tools: ", err)
        return htmlstr
    end
end

function GoogleSearchFilter:get_url()
    if not GoogleSearchFilter.url then
        local protocol = ngx.var.protocol
        local domain = ngx.var.hostname
        local uri = ngx.var.uri
        GoogleSearchFilter.url = table.concat({protocol, "://", domain, uri})
    end

    return GoogleSearchFilter.url
end

function GoogleSearchFilter:head_js(head_js)
    head_js = replace_uri(head_js)

    return head_js
end

function GoogleSearchFilter:head_style(head_style)
    head_style = fix_search_sbc_style(head_style)

    return head_style
end

function GoogleSearchFilter:body(body)
    -- body = replace_uri(body)

    return body
end

function GoogleSearchFilter:main(main)
    main = remove_search_tools(main)
    main = replace_google_links(main)
    main = remove_mCljob(main)
    main = fix_search_uri(main)
    main = replace_google_urls(main)
    main = replace_image_urls(main)

    return main
end


function GoogleSearchFilter:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleSearchFilter