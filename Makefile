install:
	rm -rf deps
	rm -rf temp
	rm -rf lustache
	curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
	chmod 755 luvit
	chmod 755 lit
	chmod 755 luvi
	chmod 775 run.sh
	mkdir deps
	luarocks install --tree=temp luasql-mysql MYSQL_INCDIR=/usr/include/mysql
	curl https://raw.githubusercontent.com/Dynodzzo/Lua_INI_Parser/master/LIP.lua > deps/LIP.lua
	curl https://raw.githubusercontent.com/Stepets/utf8.lua/master/utf8.lua > deps/utf8.lua
	git clone https://github.com/Olivine-Labs/lustache.git
	./lit install creationix/weblit
	cp -r temp/lib/lua/5.1/luasql deps/luasql
	cp -r lustache/src/lustache deps
	cp lustache/src/lustache.lua deps/lustache.lua
	chmod -R 755 deps
	cd deps && lua ../setup/setup.lua
	rm -rf temp
	rm -rf lustache
	useradd laine ||:
	usermod -a -G laine laine
	mkdir -p /opt/laine/
	cp -rv . /opt/laine/
	chown -R laine:laine /opt/laine
	cp laine.service /etc/systemd/laine.service
	systemctl daemon-reload
ubuntu-packages:
	apt install lua5.1
	apt install luarocks
	apt install curl
	apt install libmysqlclient-dev
	apt install mysql-server
	apt install mysql-client

#Include package setups for other distros pls.
