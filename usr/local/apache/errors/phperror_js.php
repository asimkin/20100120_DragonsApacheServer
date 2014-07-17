<?
#######################################################
## Do not modify this line! It is updated automatically.
$show_tip = false;
#######################################################

if (isset($_GET['never'])) {
	$f = fopen(__FILE__, "rb"); $st = fread($f, 10000); fclose($f);
	$st = preg_replace('/(\$show_tip\s*=\s*)\w+/', '$1false', $st);
	$f = fopen(__FILE__, "wb"); fwrite($f, $st); fclose($f);
	exit;
}
Header("Content-type: application/x-javascript; charset=windows-1251");
?>

function denwer_element(name)
{
	if (document.all) return document.all[name];
	if (document.getElementById) return document.getElementById(name);
	return null;
}

function denwer_showTip(on)
{
	if (!denwer_element("denwer_onPhpErrorHelp")) {
		alert("Too old browser version!");
		return false;
	}
	if (!on) {
		denwer_element("denwer_onPhpErrorHelp").style.display="none"; 
		denwer_element("denwer_onPhpErrorHref").style.display="block";
	} else {
		denwer_element("denwer_onPhpErrorHelp").style.display="block"; 
		denwer_element("denwer_onPhpErrorHref").style.display="none";
	}
	return false;
}

function denwer_delTip()
{
	if (confirm("ѕодсказка больше никогда не по\€витс\€. ¬ы уверены?")) {
		denwer_element("denwer_onPhpErrorImg").src = "<?=$_SERVER['SCRIPT_NAME']?>?never";
		denwer_element("denwer_onPhpErrorHelp").style.display="none"; 
		denwer_element("denwer_onPhpErrorHref").style.display="none";
	}
	return false;
}

function denwer_onPhpError(obj)
{
	var d = document;

	if (d.countPhpErrors) return;

	var body = '' + (document.body && document.body.innerHTML? document.body.innerHTML : '');
	var p = body.lastIndexOf("<!--error-->");
	if (!p) return;

	var isNotice = body.indexOf('>Notice</') >= 0;
	if (!isNotice) return;

	d.write("<img id=denwer_onPhpErrorImg width=1 height=1 border=0>");
	d.write('<span id=denwer_onPhpErrorHelp style="background:#FFFFE1; display:none; font-size:10pt; padding:4; width:80%; border-width:1; border-style:solid;">');
	d.write(
		"<nobr style='float:right'>[ <a href='#' onclick='denwer_showTip(0)'><b>убрать подсказку</b></a> | "+
		"<a href='#' onclick='denwer_delTip()'><b>никогда больше не показывать</b></a> ]</nobr><br>"+
		"<p>Ёто предупреждение, веро\€тнее всего, возникает вследствие высокого уровн\€ "+
		"контрол\€ ошибок в PHP, по умолчанию установленного в php5.2.0 (<tt>E_ALL</tt>). "+
		"“акой режим вывода ошибок \€вл\€етс\€ рекомендуемым и сильно помогает при "+
		"отладке скриптов. ќднако множество готовых скриптов требуют более низкого "+
		"уровн\€ ошибок.</p> "+
		"<p>¬ы можете установить более слабый контроль ошибок одним из следующих способов:</p>"+
		"<ul>"+
		"<li>¬пишите в скрипты строчку: "+
			"<pre>Error_Reporting(E_ALL & ~E_NOTICE);</pre> "+
			"Ётот способ особенно удобен, если в скрипте есть один файл (конфигурационный), "+
			"который подключаетс\€ всеми остальными."+
		"<li><i>–екомендуемый способ</i>. —оздайте в директории со скриптом файл "+
			"<tt>.htaccess</tt> следующего содержани\€: "+ 
			"<pre>php_value error_reporting 7</pre>" +
		"<li>»справьте в <tt>/usr/local/php/php.ini</tt> значение <tt>error_reporting</tt> "+ 
			"на <nobr><tt>E_ALL & ~E_NOTICE</tt></nobr>. Ётот способ <i>не \€вл\€етс\€</i> рекомендуемым "+
			"и может привести к серьезным неудобствам при отладке!"+
		"</ul>"+
		""
	);
	d.write('</span>');
	d.write("<a id=denwer_onPhpErrorHref href='#' onclick='denwer_showTip(1)'><b><font color=red>[показать возможную причину ошибки]</font></b></a>");
	document.countPhpErrors = 1;
}

<?if (@$show_tip) {?>
	denwer_onPhpError();
<?}?>