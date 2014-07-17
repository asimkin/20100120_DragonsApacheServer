#!perl -w

package Starters::Apache;
BEGIN { unshift @INC, "../lib"; }

use Tools;
use Installer;
use ParseHosts;
use VhostTemplate;
use StartManager;

# Seconds to wait apache stop while restart is active.
my $timeout = 10;

# Get common pathes.
my $basedir     = $CNF{apache_dir};
my $exe         = fsgrep { /\Q$CNF{apache_exe}\E/i } $basedir;
die "  Could not find $CNF{apache_exe} inside $basedir\n" if !$exe;
my $httpd_conf  = "$basedir/conf/httpd.conf";
my $vhosts_conf = "$basedir/conf/vhosts.conf";
my $httpd_pid   = "$basedir/logs/httpd.pid";


# Additional PATH entries.
my @addPath = ();

# Autoconfigure PHP - detect basedir from LoadModule in httpd.conf file.
my $phpdir = undef;
my $httpdCont = readBinFile($httpd_conf) or die "  Could not read $httpd_conf\n";
if ($httpdCont =~ /^[ \t]* LoadModule [ \t]+ php\S*_module [ \t]+ (?: "([^"\r\n]*)" | (\S+) )/mix) {
  my $path = dirname($1 || $2);
  if (my $p1 = dirgrep { /^php.ts\.dll$/i } $path) {
    $phpdir = dirname($p1);
  } elsif (my $p2 = dirgrep { /^php.ts\.dll$/i } "$path/..") {
    $phpdir = dirname($p2);
  }
}
if ($phpdir) {
  # PHP configuration file location.
  $ENV{PHPRC} = $phpdir;
  # For OpenSSL module in PHP.
  if (my $p = fsgrep { /^openssl.cnf$/i } $phpdir) {
    $ENV{OPENSSL_CONF} = $p;
  }
  # Set PATH.
  push @addPath, ($phpdir, fsgrep { /^extensions$/i || /^dlls$/i } $phpdir);
  # Correct timezone.
  my $iniFile = "$phpdir/php.ini";
  my $ini = readBinFile($iniFile);
  if ($ini) {
    my $version = `$phpdir\\php.exe -n -v`;
    if ($version =~ /^PHP\s+5\.[3-9]/s) {
      if ($ini !~ m/^\s*date.timezone/m) {
        my $zone = `$phpdir\\php.exe -n -r "echo \@date_default_timezone_get();"`;
        $zone =~ s/\s+$//sg;
        $directive = "date.timezone = $zone";
        $ini =~ s/^\s*;\s*date.timezone\s*=[^\r\n]*/$directive/m
          or $ini .= "\r\n$directive\r\n";
      }
      $ini =~ s/^\s*register_long_arrays/;$&/mg;
      $ini =~ s/^\s*magic_quotes_gpc/;$&/mg;
      $ini =~ s/^\s*extension\s*=\s*php_pdo\.dll/;$&/mg;
      writeBinFile($iniFile, $ini);
    }
  }
}


StartManager::action 
  $ARGV[0],
  PATH => [
  	'\usr\local\ImageMagick',
  	@addPath,
  ],
  start => sub {
    ###
    ### START.
    ###
    processVHosts();
    print "Запускаем Apache...\n";
    if(checkApacheIfRunning()) {
      print "  Apache уже запущен.\n";
    } else {
      chdir($basedir);
      my $exe = $exe;
      if(!-f $exe) {
        die "  Не удается найти $exe.\n";
      } else {
        # Clean global error.log to avoid stupid PHP "C:\mysql" binding.
        unlink("$basedir/logs/error.log");
        # Start apache.
        system("start $exe -w");
        print "  Готово.\n";
      }
    }
  },
  stop => sub {
    ###
    ### STOP.
    ###
    print "Завершаем работу Apache...\n";
    if (!-f $exe) {
      print "  Не удается найти $exe.\n";
      return;
    }
    
    my $pid = trim(readTextFile($httpd_pid));
    if (!$pid || !checkApacheIfRunning()) {
      print "  Apache не запущен.\n";
      return;
    }
    
    my $sender = getToolExePath("apachesignal.exe");
    if (!-f $sender) {
      print "  Не удается найти $sender!\n";
      return;
    }
    
    my $result = getComOutput("$sender -p $pid -k stop");
    if ($? >> 8) {
      $result =~ s/^/  /mg;
      print "  Ошибка отправки сигнала завершения:\n";
      print $result;
      return;
    }
    print "  Готово.\n";
  },
  
  _middle => sub {
    ###
    ### MIDDLE: after "start" of "restart".
    ###
    if (checkApacheIfRunning()) {
      $| = 1;
      print "Ожидаем завершения Apache (максимум $timeout секунд) ";
      my $tm = time();
      while (time() - $tm < $timeout) {
        print ". ";
        if (!checkApacheIfRunning()) {
          print "\n";
          print "  Готово.\n";
          return;
        }
        sleep(1);
      }
      print "\n";
      print "  Не удается дождаться завершения!\n";
    }
  }
;


sub processVHosts {
  my $VHOSTS = $vhosts_conf;
  my $HTTPD = $httpd_conf;

  print "Создаем блоки виртуальных хостов...\n";

  if(!-e $HTTPD) {
    die "  Не удается найти $HTTPD\n";
  }

  # Add comments.
  my $vhosts = '';
  $vhosts .= clean qq{
    #
    # ┬═╚╠└═╚┼!
    #
    # ─рээ√щ Їрщы с√ы ёухэхЁшЁютрэ ртЄюьрЄшўхёъш. ╦■с√х шчьхэхэш , тэхёхээ√х т 
    # эхую, яюЄхЁ ■Єё  яюёых яхЁхчряєёър ─хэтхЁр. ┼ёыш т√ їюЄшЄх шчьхэшЄ№
    # ярЁрьхЄЁ√ ъръюую-Єю юЄфхы№эюую їюёЄр, трь эхюсїюфшью яхЁхэхёЄш 
    # ёююЄтхЄёЄтє■∙шщ сыюъ <VirtualHost> т httpd.conf (Єрь эряшёрэю, ъєфр шьхээю).
    #
    # ╧юцрыєщёЄр, эх шчьхэ щЄх ¤ЄюЄ Їрщы.
    #
  };

  # Read Vhost template
  my $num = 1;
  foreach my $host (VhostTemplate::getAllVHosts($HTTPD)) {
#    use Data::Dumper; print Dumper($host);
    $vhosts .= "\n\n# Host ".$host->{path}." ($num): \n";

    my $s = $host->{vhost};
    # Delete comments.
    $s=~s/#.*//mg if $num!=1;
    $s=~s/^[ \t]*[\r\n]+//mg;    # delete empty lines

    # Вставляем букву диска - проклятые разработчики PHP без этого не могут никак!
    $s=~s{^(\s* DocumentRoot \s+ "?)(/)}{$1 . Installer::getSubstDriveConfig() . $2}mgxie;

    $vhosts .= $s;
  } continue {
    $num++;
  }

  # Remove duplicate Listen directives.
  my %dup = ();
  $vhosts =~ s{^\s* Listen \s+ "? ([^\s"]+) "?}{ ($dup{lc $1}++)? '#'.$& : $& }megx;

  # Remove duplicate NameVirtualHost.
  %dup = ();
  $vhosts =~ s{^\s* NameVirtualHost \s+ "? ([^\s"]+) "?}{ ($dup{lc $1}++)? '#'.$& : $& }megx;
  
  # Open output file.
  if(!open(local *F, ">$VHOSTS")) {
    out qq{
      ВНИМАНИЕ!
      Не удается открыть файл $VHOSTS на запись. 
      Продолжение работы невозможно.
    };
    waitEnter();
    die "\n";
  }
  print F $vhosts;
  close F;
  
  print "  Добавлено хостов: ".($num-1)."\n";
}

sub checkApacheIfRunning {
  return !open(local *F, ">>$exe");
}

return 1 if caller;
