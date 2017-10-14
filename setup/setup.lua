local lustache = require('lustache')
local lip = require('LIP')
io.stdout:write("\n\n\nPlease enter your MySQL root user password: ")
local pass = io.stdin:read()
io.stdout:write("Please enter the username of the user for your website: ")
local user = io.stdin:read()
io.stdout:write("Please enter the password of the user for your website: ")
local p2 = io.stdin:read()
io.stdout:write("Please enter the name for the database: ")
local dbname = io.stdin:read()
print("OK, writing databases...")
local fh = io.popen("mysql --user=root --password="..pass, "w")
fh:write(lustache:render(io.open("../setup/setup.sql"):read("*a"), {user=user, pass=pass, dbname=dbname}))
fh:write("exit\n")
if (fh ~= nil) then
	fh:close()
end
local cfg = lip.load("../config.ini")
cfg.MySQL.user = user
cfg.MySQL.db = dbname
cfg.MySQL.pass = pass
lip.save("../config.ini", cfg)
print("Initial setup complete.\n\n")
