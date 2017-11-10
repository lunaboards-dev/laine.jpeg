local ip = {}

ip.setConnection = function(c)
	ip.con = c
end

ip.get = function(ip)
	local r = assert(ip.con:execute("SELECT * FROM bans WHERE ip='"..ip.con:escape(ip).."'"))
	local d = r:fetch({}, "a")
	if (d == nil) then
		assert(ip.con:execute("INSERT INTO bans (ip) DATA ('"..ip.con:escape(ip).."')"))
		r = assert(ip.con:execute("SELECT * FROM bans WHERE ip='"..ip.con:escape(ip).."'"))
		d = r:fetch({}, "a")
	end
	return d
end