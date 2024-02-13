fx_version 'cerulean'
game 'gta5'

name "Death screen"
description ""
author "UPCODE"
version "1.0.0"
lua54 'yes'
ui_page 'ui/index.html'

shared_scripts {'config.lua'}

client_scripts {'client/*.lua'}

server_scripts {'server/*.lua'}

files {
	'ui/index.html',
	'ui/global.css',
	'ui/style.css',
	'ui/main.js',
	'ui/assets/*.*'
}

