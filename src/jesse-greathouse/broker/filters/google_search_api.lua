-- methods for fixing parsed content on the front end
local helpers = require "helpers"
local GoogleSearchApiFilter = {
    url = nil
}

function GoogleSearchApiFilter:get_url()
    if not GoogleSearchApiFilter.url then
        local protocol = ngx.var.protocol
        local domain = ngx.var.hostname
        local uri = ngx.var.uri
        GoogleSearchApiFilter.url = table.concat({protocol, "://", domain, uri})
    end

    return GoogleSearchApiFilter.url
end


function GoogleSearchApiFilter:get_imgurl(htmlstr)
    local m, err = ngx.re.match(htmlstr, "\\/imgres\\?imgurl=([\\%\\,\\--\\/0-9\\:\\;\\=\\?\\@A-Z_a-z]+)&?.+")
    if m then
        return helpers.urldecode(m[1])
    elseif err then
        ngx.log(ngx.ERR, "GoogleSearchApiFilter get_imgurl: " .. err)
        return ""
    end
end

function GoogleSearchApiFilter:fix_description_urls(htmlstr)
    local newstr, n, err = ngx.re.gsub(htmlstr, "href=\"\\/url\\?q=([\\%\\--\\/0-9\\:A-Z_a-z]+)(&amp;[a-z]+=[\\-0-9A-Z_a-z]+)+", "href=\"$1", "iU")
    if newstr then
        return helpers.urldecode(newstr)
    else
        ngx.log(ngx.ERR, "GoogleSearchApiFilter fix_description_urls: ", err)
        return htmlstr
    end
end

function GoogleSearchApiFilter:get_linkurl(htmlstr)
    local m, err = ngx.re.match(htmlstr, "\\/url\\?q=([\\%\\,\\--\\/0-9\\:\\;\\=\\?\\@A-Z_a-z]+)&?.+")
    if m then
        return helpers.urldecode(m[1])
    elseif err then
        ngx.log(ngx.ERR, "GoogleSearchApiFilter get_linkurl: " .. err)
        return ""
    end
end

function GoogleSearchApiFilter:body(body)
    return body
end

function GoogleSearchApiFilter:main(main)
    return main
end


function GoogleSearchApiFilter:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

return GoogleSearchApiFilter