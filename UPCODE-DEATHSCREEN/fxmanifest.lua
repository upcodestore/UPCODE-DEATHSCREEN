fx_version 'cerulean'
game 'gta5'

name "Voice Alert"
description "This resource provides the player with daily tasks"
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

