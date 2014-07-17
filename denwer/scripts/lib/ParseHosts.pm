
package ParseHosts;
$VERSION = 3.00;
use Tools;
use Installer;
use VhostTemplate;

# ╘рщы ёю ёяшёъюь їюёЄют, фюсртыхээ√ї т яЁю°ы√щ Ёрч.
my $HOSTS_LOG   = dirname(__FILE__)."/AddedHosts.txt";

# IP-рфЁхё їюёЄют яю єьюыўрэш■
my $DEF_IP = $VhostTemplate::DEF_IP;

# Marker to disable some of hosts.
my $DISABLE_MARKER = "## Disabled by denwer: ";


# ▌ъёяюЁЄшЁєхЄ тёх ЇєэъЎшш т т√чтрт°шщ яръхЄ. ┬√ч√трхЄё  ртЄюьрЄшўхёъш.
sub import {
	while(my ($k,$v)=each(%{__PACKAGE__."::"})) { 
		next if substr($k,-1) eq ":" || grep { $k eq $_ } qw(BEGIN import);
		*{caller()."::".$k}=$v;
	}
}


# hash parseHosts($fname)
# ╫шЄрхЄ Їрщы hosts. ┬ючтЁр∙рхЄ ї¤° ё ъы■ўрьш - шьхэрьш їюёЄют 
# ш чэрўхэш ьш - шї ip-рфЁхёрьш.
sub parseHosts {	
	my ($fname)=@_;
	open(local *F, $fname) or return ();
	my %dom=();
	while(<F>) {
		s/#.*|^\s+|\s+$//sg; next if $_ eq "";
		my ($ip,$h)=split(/\s+/, $_, 2);
		if(!defined $h) { $h=$ip; $ip=$DEF_IP; }
		foreach (split /\s+/, $h) {
			$dom{$_}=$ip;
		}
	}
	return %dom;	
}



# hash readHostsLog()
# ╫шЄрхЄ Їрщы цєЁэрыр їюёЄют. ═р ёрьюь фхых, ЇюЁьрЄ цєЁэрыр 
# шфхэЄшўхэ ЇюЁьрЄє Їрщыр hosts.
sub readHostsLog {	
	return parseHosts($HOSTS_LOG);
}

sub cmpHost { 
	return -1 if $a eq "localhost";
	return 1 if $b eq "localhost";
	return length($b) <=> length($a);
} 



# hash writeHostsLog(%dom)
# ╟ряшё√трхЄ Їрщы цєЁэрыр їюёЄют.
sub writeHostsLog {	
	my (%dom)=@_;
	if(!scalar(keys %dom)) {
		unlink $HOSTS_LOG;
		return 1;
	}
	open(local *F, ">$HOSTS_LOG") or die "Could not create $HOSTS_LOG\n";
	print F "# This file is created by hosts update system\n";
	print F "# Please DO NOT modify and DO NOT delete it!\n";
	print F "# Following hosts will be deleted from 'hosts' on cleanup.\n\n";
	my @list=();
	my $ml=0;
	foreach my $k (sort cmpHost keys %dom) {
		push @list, "$dom{$k}	$k";
		$ml=length($k) if length($k)>$ml;
	}
	print F join("\n", @list, "");
	return 1;
}


# hash insertHosts(out string $hosts, %dom)
# ╠юфшЇшЎшЁєхЄё ёЄЁюъє $hosts (¤Єю ёюфхЁцшьюх Їрщыр c:/windows/hosts)
# Єръ, ўЄюс√ Єрь с√ыш фюсртыхэ√ їюёЄ√ %dom. ┼ёыш юфшэ шч їюёЄют єцх
# яЁшёєЄёЄтєхЄ т $hosts (эряЁшьхЁ, ё фЁєушь ip-рфЁхёюь), юэ эх ЄюЁюурхЄё .
# ┬ючтЁр∙рхЄ їюёЄ√, ъюЄюЁ√х с√ыш фюсртыхэ√.
sub insertHosts
{	local (*hosts, %dom)=(\$_[0], @_[1..$#_]);
	my %added=();
	foreach my $h (sort cmpHost keys %dom) {
		my $ip=$dom{$h};
		# ╨рсюЄрхь ё фюьхээ√ь шьхэхь $h.
		# ╤эрўрыр яЁютхЁ хь, хёЄ№ ыш єцх ¤ЄюЄ фюьхэ т $hosts.
		next if $hosts=~m{^ 
			[ \t]*                      # ═┼╦▄╟▀ шёяюы№чютрЄ№ \s!
			\d+ (\.\d+)+                # IP-рфЁхё
			[^\#\r\n]+                  # яЁюсхы√ ш эх-ъюььхэЄрЁшш
			(?<=\s) \Q$h\E (?=[#\s]|$)  # фюьхэ Ўхышъюь
		}mix;
		# ┼ёыш эхЄ, фюсрты хь хую т ъюэхЎ.
		$hosts=~s/\s*$//s;
		$hosts.="\r\n" if $hosts ne "";
		$hosts.="$ip	$h\r\n";
		$added{$h}=$ip;
	}
	# Remove Vista's "::1 localhost", because it conflicts with Denwer.
	$hosts=~s/^([ \t]* ::1 [ \t]* localhost)/$DISABLE_MARKER$1/mgx;
	return %added;
}


# hash deleteHosts(string $hosts, %dom)
# ╠юфшЇшЎшЁєхЄё ёЄЁюъє $hosts (¤Єю ёюфхЁцшьюх Їрщыр c:/windows/hosts)
# Єръ, ўЄюс√ Єрь с√ыш єфрыхэ√ їюёЄ√ %dom, эю Єюы№ъю т ёыєўрх 
# ёютярфхэш  ip-рфЁхёют. 
# ┬ючтЁр∙рхЄ їюёЄ√, ъюЄюЁ√х с√ыш єфрыхэ√.
sub deleteHosts
{	local (*hosts, %dom)=(\$_[0], @_[1..$#_]);
	my %del=();
	foreach my $h (keys %dom) {
		my $ip=$dom{$h};
		# ╙фры хь чряшё№ юс ¤Єюь їюёЄх.
		$hosts=~s{^
			(	[ \t]*             # эрўры№э√х яЁюсхы√ - \s ═┼╦▄╟▀!
				\Q$ip\E            # IP-рфЁхё
				[^\#\r\n]*         # яЁюсхы√ ш эх-ъюььхэЄрЁшш
			)
			(?<=\s) \Q$h\E ([ \t\r]+|$) # шь , юъЁєцхээюх яЁюсхырьш
		}{
			$del{$h}=$ip; 
			$1
		}gmixe;
	}
	# ╥хяхЁ№ єфры хь чряшёш, т√уы ф ∙шх ъръ 
	# "127.0.0.1    # яєёЄю"
	$hosts=~s{^ [ \t]* \d+(\.\d+)* [ \t]* (\#.*)? \r? \n}{}sgmx;
	# Restore bach Vista's "::1 localhost" if it was commented later.
	$hosts=~s/^[ \t]*\Q$DISABLE_MARKER\E//mg;
	return %del;
}


# string getHostsPath()
# ┬ючтЁр∙рхЄ яєЄ№ ъ ёшёЄхьэюьє Їрщыє hosts.
sub getHostsPath {
	my $path;
	if ($ENV{OS} && $ENV{OS}=~/NT|XP|2000|2003/) {
		$path = "system32/drivers/etc/hosts";
	} else {
		$path = "hosts";
	}
	my $windir = Installer::findWindows();
	return "$windir/$path";
}


# void makeHostsWritable(bool $batch = 0)
# Makes the hosts file writable if it is not yet.
# Used by hosts updater & Denwer installer.
sub makeHostsWritable {
	my ($batch) = @_;
	my $hostsPath = getHostsPath();
	chmod(0666, $hostsPath);

	# Check if we running under Administrator.
	if (!open(local *F, ">>$hostsPath")) {
		# Code for NT versions.
		if ($ENV{OS} =~ /NT/) {
			try qq{
				Установка прав на запись в файл $hostsPath...
				Это необходимо для работы системы множественных виртуальных хостов.
			};
			if (!$batch && getComOutput('VER') =~ /\[\S+\s+[6-9]/) {
				# Show this only in Vista.
				error qq{
					ВНИМАНИЕ!
					
					Сейчас Денвер попытается изменить права доступа для файла hosts так, 
					чтобы имелась возможность добавлять в него новые виртуальные хосты.
					
					Система запросит у вас подтверждение на выполнение этой операции, 
					т.к. файл hosts в Windows Vista относится к разряду защищенных. 
					
					Вы должны ответить утвердительно на запрос о разрешении действия, 
					чтобы продолжить работу.
					
					Hosts - это обычный текстовый файл в формате "ip-адрес имя-хоста".
					Его изменение не может повредить системе даже теоретически.
				};
				waitEnter();
			}
			system(getToolExePath('AllowToModifyVirtualHosts.exe'));
		}

		if (!open(local *F, ">>$hostsPath")) {
			error qq{
				Ошибка! Не удалось установить права на запись. Возможные причины:
				- Вы не обладаете привилегиями Администратора на данном компьютере.
				- Вы пытаетесь запустить инсталлятор Денвера с сетевого диска.
				- Для Windows Vista: вы не разрешили системе запустить утилиту, 
				  устанавливающую права на запись в файл hosts.
				- Файл открыт в монопольном режиме другой программой или антивирусом.
				Попробуйте перезагрузить компьютер.
			};
			return 0;
		}
	}
	return 1;
}


return 1;