<%--
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp"%>
<tag:page dwr="ViewDwr"
	js="view,dygraphs/dygraph-dev,dygraph-extra,dygraphsSplineUtils,dygraphsCharts"
	css="jQuery/plugins/jquery-ui/css/south-street/jquery-ui-1.10.3.custom.min,jQuery/plugins/datetimepicker/jquery-ui-timepicker-addon,jQuery/plugins/jpicker/css/jPicker-1.1.6.min"
	jqplugins="jquery-ui/js/jquery-ui-1.10.3.custom.min,jpicker/jpicker-1.1.6.min,datetimepicker/jquery-ui-timepicker-addon" >
  <script type="text/javascript" src="resources/wz_jsgraphics.js"></script>
  <script type="text/javascript" src="resources/shortcut.js"></script>
  <script type="text/javascript" src="resources/customClientScripts/customView.js"></script>
  <script>
  var MyIcon
  function placeAsImpeller(evt)
  {
      if(iconG.childNodes.length==1)
      iconG.removeChild(iconG.lastChild)
      var myIcon=evt.target.cloneNode(true)
      myIcon.setAttribute("x",187)
      myIcon.setAttribute("y",223)
      myIcon.setAttribute("font-size",123)
      myIcon.removeAttribute("onclick")
      myIcon.setAttribute("dy",+myIcon.getAttribute("font-size")/2-4)
      myIcon.setAttribute("text-anchor","middle")
      myIcon.setAttribute("id","myIcon")
      iconG.appendChild(myIcon)
      MyIcon=SVG.adopt(myIcon)
      if(MySpeed)
          MyIcon.animate(MySpeed,"-").rotate(360).loop(true)
  }

  function replaceIcon()
  {
      var myIcon=document.getElementById("myIcon").cloneNode(true)

      MyIcon.remove()

      myIcon.setAttribute("x",187)
      myIcon.setAttribute("y",223)
      myIcon.setAttribute("font-size",123)
      myIcon.removeAttribute("onclick")
      myIcon.setAttribute("dy",+myIcon.getAttribute("font-size")/2-4)
      myIcon.setAttribute("text-anchor","middle")
      myIcon.setAttribute("id","myIcon")

      iconG.appendChild(myIcon)
      MyIcon=SVG.adopt(myIcon)
  }

  var MySpeed
  function speedSelected(myValue)
  {
      if(speedSelect.selectedIndex!=0)
      {
          MySpeed=+speedSelect.options[speedSelect.selectedIndex].value

          if(MyIcon)
          {
              replaceIcon()
              MyIcon.animate(MySpeed,"-").rotate(360).loop(true) //---loop(continuous)---
          }
      }
  }


  var Unicodes=["2720","2722","2723","2724","2725","2726","2727","2729","272D","272E","272F","2731","2732","2733","2735","2736","2737","2738","273A","273B","273C","273D","273E","2742","2743","2744","2745","2746","2747","2748","2749","274A","274B","279B","27A2","27A3","27A4","27B3","27B5","27B8","27BA","27BB","27BC","25C6","25C7","25C8","21BB","21DC","21DD","290F","2915","2933","2B27","2BCC","2BCD","2BCE","2BCF","2BD0"]
      //---random color---
  	function rcolor()
  	{
  		var letters = '0123456789ABCDEF'.split('');
  		var color = '#';
  		for (var i = 0; i < 6; i++ )
  		{
  			color += letters[Math.round(Math.random() * 15)];
  		}
  		return color;
  	}

  	function randomPoints(elems,svgWidth,svgHeight,elemSize)
  	{
  		//--return format:[ [x,y],[x,y],,, ]
  		//---Generate  random points---
  		function times(n, fn)
  		{
  			var a = [], i;
  			for (i = 0; i < n; i++) {
  			a.push(fn(i));
  			}
  			return a;
  		}
  		var width=svgWidth-2*elemSize
  		var height=svgHeight-2*elemSize

  		return 	RandomPnts = times(elems, function() { return [Math.floor(width * Math.random()) + elemSize, Math.floor(height * Math.random()) + elemSize] });
  	}

    // var randPoints=randomPoints(Unicodes.length,400,400,40)

  //---onload---
  function buildUnicodeTable()
  {
      var fontSize = 30
      var strokeFactor = .02
      var strokeWidth = strokeFactor*fontSize

      var svg = d3.select("#sizerSVG")
      for(var k = 0; k<Unicodes.length; k++)
      {
          var unicode = Unicodes[k]

          var code = parseInt(unicode, 16)
          var icon = svg.append("text")
          .attr("id", "icon_"+unicode)
          .attr("font-size", fontSize)
          .attr("font-family", "Arial Unicode MS")
          .attr("stroke-width", strokeWidth)
          .attr("fill", rcolor())
          .attr("stroke", "black")
          .text(String.fromCharCode(code))

          var sizeMe = document.getElementById("icon_"+unicode)
          var bb = sizeMe.getBBox()
          var centerX = bb.x+.5*bb.width
          var centerY = bb.y+.5*bb.height

          icon.attr("centerX", centerX)
          icon.attr("centerY", centerY)

          var row = unicodeTable.insertRow(k)
          var svgCell = row.insertCell(0)
          svgCell.style.width = "30px"
          svgCell.style.height = "30px"
          svgCell.style.overflow = "hidden"

          svgCell.innerHTML = '<svg  width=30 height=30 overflow="hidden" xmlns="http://www.w3.org/2000/svg"  ><text cursor="default" pointer-events="visible" onclick=placeAsImpeller(evt) font-size="'+fontSize+'" font-family="Arial Unicode MS" stroke-width="'+strokeWidth+'" fill="'+rcolor()+'" stroke="black" unicode="'+unicode+'" x="'+(-bb.x)+'" y="'+(-bb.y)+'">'+String.fromCharCode(code)+'</text></svg>'

          var unicodeCell = row.insertCell(1)
          unicodeCell.innerHTML = unicode
      }
  }
  </script>
  <link
	href="resources/app/bower_components/sweetalert2/dist/sweetalert2.min.css"
	rel="stylesheet" type="text/css">

    <script type="text/javascript" src="resources/app/bower_components/sweetalert2/dist/sweetalert2.min.js"></script>


		<script type="text/javascript">
		jQuery.noConflict();
		shortcut.add("Ctrl+Shift+F",function() {



			setCookie("fullScreen","no");

			document.getElementById('mainHeader').style.display = "compact";
	  	  	document.getElementById('subHeader').style.display = "compact";
	  	  	document.getElementById('graphical').style.display = "compact";

	  		location.reload(true);


		});

		<c:if test="${!empty currentView}">
	      mango.view.initNormalView();
	    </c:if>

	    var nVer = navigator.appVersion;
	    var nAgt = navigator.userAgent;
	    var browserName  = navigator.appName;
	    var fullVersion  = ''+parseFloat(navigator.appVersion);
	    var majorVersion = parseInt(navigator.appVersion,10);
	    var nameOffset,verOffset,ix;

	    // In Opera, the true version is after "Opera" or after "Version"
	    if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
	     browserName = "Opera";
	     fullVersion = nAgt.substring(verOffset+6);
	     if ((verOffset=nAgt.indexOf("Version"))!=-1)
	       fullVersion = nAgt.substring(verOffset+8);
	    }
	    // In MSIE, the true version is after "MSIE" in userAgent
	    else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
	     browserName = "Microsoft Internet Explorer";
	     fullVersion = nAgt.substring(verOffset+5);
	    }
	    // In Chrome, the true version is after "Chrome"
	    else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
	     browserName = "Chrome";
	     fullVersion = nAgt.substring(verOffset+7);
	    }
	    // In Safari, the true version is after "Safari" or after "Version"
	    else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
	     browserName = "Safari";
	     fullVersion = nAgt.substring(verOffset+7);
	     if ((verOffset=nAgt.indexOf("Version"))!=-1)
	       fullVersion = nAgt.substring(verOffset+8);
	    }
	    // In Firefox, the true version is after "Firefox"
	    else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
	     browserName = "Firefox";
	     fullVersion = nAgt.substring(verOffset+8);
	    }
	    // In most other browsers, "name/version" is at the end of userAgent
	    else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) <
	              (verOffset=nAgt.lastIndexOf('/')) )
	    {
	     browserName = nAgt.substring(nameOffset,verOffset);
	     fullVersion = nAgt.substring(verOffset+1);
	     if (browserName.toLowerCase()==browserName.toUpperCase()) {
	      browserName = navigator.appName;
	     }
	    }
	    // trim the fullVersion string at semicolon/space if present
	    if ((ix=fullVersion.indexOf(";"))!=-1)
	       fullVersion=fullVersion.substring(0,ix);
	    if ((ix=fullVersion.indexOf(" "))!=-1)
	       fullVersion=fullVersion.substring(0,ix);

	    majorVersion = parseInt(''+fullVersion,10);
	    if (isNaN(majorVersion)) {
	     fullVersion  = ''+parseFloat(navigator.appVersion);
	     majorVersion = parseInt(navigator.appVersion,10);
	    }

	    function unshare() {
	        ViewDwr.deleteViewShare(function() { window.location = 'views.shtm'; });
	    }

	    function setCookie(c_name,value)
	    {
	    	var exdate=new Date();
	    	exdate.setDate(exdate.getDate() + 365);
	    	var c_value=escape(value) + ("; expires="+exdate.toUTCString());
	    	document.cookie=c_name + "=" + c_value;
	    }

	    function getCookie(c_name)
	    {
	    	var i,x,y,ARRcookies=document.cookie.split(";");

	    	for (i=0;i<ARRcookies.length;i++)
	    	{
	      		x=ARRcookies[i].substr(0,ARRcookies[i].indexOf("="));
	      		y=ARRcookies[i].substr(ARRcookies[i].indexOf("=")+1);
	      		x=x.replace(/^\s+|\s+$/g,"");

	      		if (x==c_name)
	        	{
	        		return unescape(y);
	        	}
	      	}

	    }

		function toggleDisplay(){

			document.getElementById('mainHeader').style.display = "none";
	  	  	document.getElementById('subHeader').style.display = "none";
	  	  	document.getElementById('graphical').style.display = "none";
	  	  	jQuery('#fsOut').fadeOut(10000, function(){});

		}

		function fullScreen(){

			document.getElementById('fsOut').style.display = "block";
			document.getElementById('mainHeader').style.display = "none";
	  	  	document.getElementById('subHeader').style.display = "none";
	  	  	document.getElementById('graphical').style.display = "none";
			jQuery('#fsOut').fadeOut(10000, function(){});

	  	  	setCookie("fullScreen","yes");

		}

		function checkFullScreen(){

			var check = getCookie("fullScreen");

			if(check!=null && check!=""){

				if(check=="yes"){
					toggleDisplay();
	 				//document.getElementById('fsOut').style.display = "block";
				}

				if(check=="no"){
					document.getElementById('fsOut').style.display = "none";
				}
			}

		}

		function keyListen(e) {
	        var keycode = e.keyCode;

	        if(keycode == '116') {
	        	e.returnValue=false;
	        	e.keyCode=false;
	        	return false;
	        };
		}

		function callkeydownhandler(evnt) {
	   		keyListen(evnt);
		}


	</script>
		<table id="graphical">
			<tr>
				<td class="smallTitle"><fmt:message key="views.title" /> <tag:help
						id="graphicalViews" /></td>
				<td width="50"></td>
				<td align="right"><sst:select value="${currentView.id}"
						onchange="window.location='?viewId='+ this.value;">
						<c:forEach items="${views}" var="aView" >
							<sst:option value="${aView.key}">${sst:escapeLessThan(aView.value)}</sst:option>
						</c:forEach>
					</sst:select> <c:if test="${!empty currentView}">
						<c:choose>
							<c:when test="${owner}">
								<a href="view_edit.shtm?viewId=${currentView.id}"><tag:img
										png="icon_view_edit" title="viewEdit.editView" /> </a>
							</c:when>
							<c:otherwise>
								<tag:img png="icon_view_delete" title="viewEdit.deleteView"
									onclick="unshare()" />
							</c:otherwise>
						</c:choose>
					</c:if> <a href="view_edit.shtm"><tag:img png="icon_view_new"
							title="views.newView" /> </a></td>

				<c:if test="${fn:length(views) != 0}">
					<td><input type="button" name="buttonFull" value="Full Screen"
						onClick="fullScreen();" /></td>
					<td><input type="button" name="telacheiafull" value="Tela Cheia"
						onClick="telaCheia();" /></td>
				</c:if>

			</tr>

		</table>

		<table>
			<tr>
				<td class="smallTitle" id="fsOut">
					<fmt:message key="fullScreenOut"/>
				</td>
			</tr>
		</table>

		<script type="text/javascript">

			checkFullScreen();
		</script>
		<c:if test="${currentView.id == 17}" >
			<tag:displayView2 view="${currentView}" emptyMessageKey="views.noViews" />
		</c:if>
		<c:if test="${currentView.id != 17}" >
				<tag:displayView view="${currentView}" emptyMessageKey="views.noViews" />
		</c:if>
	</tag:page>
