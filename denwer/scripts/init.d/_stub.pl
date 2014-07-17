#!perl -w
##
## This file contains stub for creating custom starters.
## You may delete it if you want.
##

package Starters::???;
BEGIN { unshift @INC, "../lib"; }

use Tools;
use Installer;
use StartManager;


StartManager::action 
	$ARGV[0],
	PATH => [
	],
	start => sub {
		###
		### START.
		###
		print "Запускаем ???...\n";
	},
	stop => sub {
		###
		### STOP.
		###
		print "Завершаем ???...\n";
	},
	_middle => sub {
		###
		### MIDDLE: after "start" or "restart".
		###
	},
;

return 1 if caller;