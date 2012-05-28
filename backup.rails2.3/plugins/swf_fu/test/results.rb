DYNAMIC_RESULT = <<'EOS'
<script type="text/javascript">
//<![CDATA[
swfobject.embedSWF("/swfs/mySwf.swf","mySwf_div","456","123","7","/swfs/expressInstall.swf",{"myVar":"value 1 \u003E 2","id":"mySwf"},{"play":true},{"id":"mySwf"})
//]]>
</script><div id="mySwf_div">
<a href="http://www.adobe.com/go/getflashplayer">
<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
</a>
</div><script type="text/javascript">
//<![CDATA[
swfobject.addDomLoadEvent(function(){Object.extend($('mySwf'), SomeClass.prototype).initialize({"be":"good"})})
//]]>
</script>
EOS

STATIC_RESULT = <<'EOS'
<script type="text/javascript">
//<![CDATA[
swfobject.registerObject("mySwf_container", "7", "/swfs/expressInstall.swf");
//]]>
</script><div id="mySwf_div"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="456" height="123" id="mySwf_container" class="lots">
<param name="movie" value="/swfs/mySwf.swf" />
<param name="play" value="true"/>
<param name="flashvars" value="myVar=value+1+%3E+2&id=mySwf"/>
<!--[if !IE]>-->
<object type="application/x-shockwave-flash" data="/swfs/mySwf.swf" width="456" height="123" id="mySwf">
<param name="play" value="true"/>
<param name="flashvars" value="myVar=value+1+%3E+2&id=mySwf"/>
<!--<![endif]-->
<a href="http://www.adobe.com/go/getflashplayer">
<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
</a>
<!--[if !IE]>-->
</object>
<!--<![endif]-->
</object></div><script type="text/javascript">
//<![CDATA[
Object.extend($('mySwf'), SomeClass.prototype).initialize({"be":"good"})
//]]>
</script>
EOS