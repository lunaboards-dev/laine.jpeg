local lu = {}

local b64 = require("base64_laine")
local crand = io.open("/dev/urandom")
local bit = require("bit")

lu.explode = function(d,p)
   local t, ll
   t={}
   ll=0
   if(#p == 1) then
      return {p}
   end
   while true do
      l = string.find(p, d, ll, true) -- find the next d in the string
      if l ~= nil then -- if "not not" found then..
         table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
         ll = l + 1 -- save just after where we found it for searching next time.
      else
         table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
         break -- Break at end, as it should be, according to the lua manual.
      end
   end
   return t
end

--Used in purpletext
local function split(inputstr)
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^\r\n]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end
--Used in purpletext
local startsWith = function(self, str)
    return self:find('^' .. str) ~= nil
end
--Escape HTML
lu.escape_html = function(post)
    return post:gsub("<", "&lt;"):gsub(">", "&gt;")
end
--Scan and put our purpletext in.
lu.ptext = function(post)
    local p_ = split(post)
    for i=1,#p_ do
        if (startsWith(p_[i], "&gt;")) then
            p_[i] = "<span style=\"color:#A229FF\">"..p_[i].."</span>"
        end
    end
    return table.concat(p_, "<br>\r\n")
end
--Generate a session token
lu.generate_session = function(con, user, pass)
    p(con)
    local r = assert(con:execute("SELECT * FROM admins WHERE name='"..con:escape(user).."' AND phash='"..con:escape(pass).."'"))
    local f = r:fetch({}, "a")
    if (f == nil) then
        return false
    end
    local sk = b64.encode(crand:read(32))
    con:execute("UPDATE admins SET k='"..con:escape(sk).."' WHERE name='"..con:escape(user).."' AND phash='"..con:escape(pass).."'")
    return sk
end
--Check if admin table has permission to do x
lu.has_perm = function(c, a, s)
    if (a == nil) then return false end
    local p = c["role_"..a.perm]
    return p[s]
end

lu.detect_img_type = function(data)
  if (data:sub(1,4) == string.char(0x89, 0x50, 0x4e, 0x47)) then return "png" end
  if (data:sub(1,3) == string.char(0xff, 0xd8, 0xff)) then return "jpeg" end
  if (data:sub(1, 6) == "GIF87a" or data:sub(1,6) == "GIF89a") then return "gif" end
  return "not img"
end

lu.true_rand = function()
  local r = crand:read(1):byte()
  r=r+bit.lshift(crand:read(1):byte(), 8)
  r=r+bit.lshift(crand:read(1):byte(), 16)
  r=r+bit.lshift(crand:read(1):byte(), 24)
  r=r+bit.lshift(1, 33)
  return math.abs(r)
end

lu.get_multiform_data = function(req)
  local body = req.body
  --p(body)
  local ctype = req.headers["Content-Type"]
  --Find boundry
  --p(ctype)
  local s, e = ctype:find("boundary=.+")
  --p(s, e)
  local boundry = "--"..ctype:sub(s, e):gsub("boundary=", ""):gsub(";", ""):gsub("%-", "%-")
  s, e = body:find(boundry.."\r\n")
  local t = {}
  local eor_reached = false
  while (not eor_reached and s ~= nil) do
    local ss, se = string.find(body, boundry, e)
    se = se+2
    if (body:sub(se-1,se) == "--") then
      eor_reached = true
    end
    local cont_disp = body:match("Content%-Disposition:.-\r\n", e-1):sub(33):gsub("[\r\n]+.+", "")
    local cont_type = body:match("Content%-Type:.-\r\n", e-1)
    if (cont_type ~= nil) then
      cont_type = cont_type:sub(15, -3)
      p(cont_type)
    end
    local sm = cont_disp:find(";")
    if (sm ~= nil) then
      cont_disp = cont_disp:sub(1,sm-1)..cont_disp:sub(sm+1)
    end
    local _, cont_end = body:find("Content%-Disposition:.-\r\n\r\n", e-1)
    --p(cont_end)
    local ct = {}
    local cs, ce = cont_disp:find(".-=\".-\"")
    --p(cont_disp)
    while (cs) do
      local cb = cont_disp:sub(cs, ce)
      local cd_key = cb:match(".-=\""):sub(1, -3)
      local cd_value = cb:match("=\".-\""):sub(3, -2)
      ct[cd_key] = cd_value
      cs, ce = cont_disp:find(".-=\".-\"", ce)
      if (cs ~= nil) then cs = cs + 2 end
    end
    if (ct.filename ~= nil) then
      t[ct.name] = {
        data = body:sub(cont_end+1, ss-3),
        headers = ct,
        mime = cont_type
      }
    else
      t[ct.name] = body:sub(cont_end+1, ss-3);
    end
    s, e = ss, se
  end
  return t
end

return lu
