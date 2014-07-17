#!perl -w

package Starters::Mysql;
BEGIN { @INC = "../lib" }
use Net::MySQL8;

my $mysql = Net::MySQL->new(
      hostname => '127.0.0.1',
      database => 'mysql',
      user     => 'root',
      password => '',
      debug    => 1
);
$mysql->_execute_command(Net::MySQL::COMMAND_SHUTDOWN, "");
