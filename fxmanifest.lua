fx_version 'cerulean'
game 'gta5'

name "nakres_barbecue"
description "Barbecue make and sales "
author "NakreS"
version "1.0.0"

shared_scripts {
	'shared/*.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

lua54 "yes"
