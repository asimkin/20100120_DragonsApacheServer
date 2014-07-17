<?php
$TITLE = preg_replace("/^[\s\d]+/", "", @$TITLE? $TITLE : @$_REQUEST["TITLE"]);
$USE_HEAD = @$USE_HEAD? $USE_HEAD : @$_REQUEST["USE_HEAD"];
$ISMAIN = @$ISMAIN? $ISMAIN : @$_REQUEST["ISMAIN"];
?>
<html>
<head>
  <title><?=strip_tags($TITLE)?></title>
  <meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />
  <style type="text/css">
  <!--
    html, body { padding: 4px; margin: 4px; }
    .menu { padding: 4px 10px 4px 10px; border-bottom: 3px double #999999; background: #FFFFFF; font-size: 85%; font-weight: bold; }
    p { text-align: justify }
    h1 { font-size: 150%; }
    h2 { font-size: 130%; }
  -->
  </style>
</head>

<body bgcolor="white" text="#000000" link="#00639C" alink="#ffaa00" vlink="#00437C">

