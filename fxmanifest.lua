fx_version 'cerulean'
game 'gta5'

name 'blash-game'
description 'blash-game'
author 'boppe'
version '1.0.0'

dependency 'oxmysql'
lua54 'yes'

client_scripts { 'client/*.lua' }
server_scripts { 'server/*.lua' }
shared_scripts { 'shared/*.lua' }