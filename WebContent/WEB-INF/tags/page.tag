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
<!DOCTYPE html>
<%@include file="/WEB-INF/tags/decl.tagf"%>
<%@attribute name="styles" fragment="true" %>
<%@attribute name="dwr" %>
<%@attribute name="css" %>
<%@attribute name="js" %>
<%@attribute name="onload" %>
<%@attribute name="jqplugins" %>


<html>
<head>
  <title>Supervisorio ScadaBR SMN</title>

  <!-- Meta -->
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <meta charset="utf-8"/>
  <meta http-equiv="content-type" content="application/xhtml+xml;charset=utf-8"/>
  <meta http-equiv="Content-Style-Type" content="text/css" />
  <meta name="Copyright" content="ScadaBR  &copy;2009-2011 Fundação Certi, MCA Sistemas, Unis Sistemas, Conetec. Todos os direitos reservados. <br> &copy;2018 Companhia de aguas e Esgotos do RN - CAERN."/>
  <meta name="DESCRIPTION" content="Sistema Supervisório SCADABR da CAERN para monitoramento dos sistemas de água e esgoto de Natal/RN"/>
  <meta name="KEYWORDS" content="ScadaBR CAERN Supervisório Natal"/>

  <!-- Style -->
  <link rel="icon" href="images/favicon.ico"/>
  <link rel="shortcut icon" href="images/favicon.ico"/>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" />
  <link id="pagestyle" href="assets/common.css" type="text/css" rel="stylesheet"/>

  <c:forTokens items="${css}" var="cssfile" delims=", ">
    <link href="resources/${cssfile}.css" type="text/css" rel="stylesheet"/>
  </c:forTokens>
  <jsp:invoke fragment="styles"/>
    <!-- Style -->

  <!-- Scripts -->
  <script type="text/javascript">
  	var djConfig = { isDebug: false, extraLocale: ['en-us', 'nl', 'nl-nl', 'ja-jp', 'fi-fi', 'sv-se', 'zh-cn', 'zh-tw','xx'] };
  	var ctxPath = "<%=request.getContextPath()%>";
  </script>
  <!-- script type="text/javascript" src="http://o.aolcdn.com/dojo/0.4.2/dojo.js"></script -->
  <script type="text/javascript" src="resources/dojo/dojo.js"></script>
  <!--  <script type="text/javascript" src="resources/jQuery/jquery-1.10.2.min.js"></script> -->
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script> 
  
  <c:forTokens items="${jqplugins}" var="plugin" delims=", ">
    <script type="text/javascript" src="resources/jQuery/plugins/${plugin}.js"></script>
  </c:forTokens>
  <script type="text/javascript">
	var jQuery = $;
	$ = null;
  </script>
  <script type="text/javascript" src="dwr/engine.js"></script>
  <script type="text/javascript" src="dwr/util.js"></script>
  <script type="text/javascript" src="dwr/interface/MiscDwr.js"></script>
  <script type="text/javascript" src="resources/soundmanager2-nodebug-jsmin.js"></script>
  <script type="text/javascript" src="resources/common.js"></script>
  <c:forEach items="${dwr}" var="dwrname">
    <script type="text/javascript" src="dwr/interface/${dwrname}.js"></script></c:forEach>
  <c:forTokens items="${js}" var="jsname" delims=", ">
    <script type="text/javascript" src="resources/${jsname}.js"></script></c:forTokens>
  <script type="text/javascript">
    mango.i18n = <sst:convert obj="${clientSideMessages}"/>;
  </script>
  <c:if test="${!simple}">
    <script type="text/javascript" src="resources/header.js"></script>
    <script type="text/javascript">

	    function loadjscssfile(filename, filetype){
			if (filetype=="js"){ //if filename is a external JavaScript file
	    		var fileref=document.createElement('script')
	    		fileref.setAttribute("type","text/javascript")
	    		fileref.setAttribute("src", filename)
			} else if (filetype=="css"){ //if filename is an external CSS file
	    		var fileref=document.createElement("link")
	    		fileref.setAttribute("rel", "stylesheet")
	    		fileref.setAttribute("type", "text/css")
	    		fileref.setAttribute("href", filename)
			}
			if (typeof fileref!="undefined")
	    		document.getElementsByTagName("head")[0].appendChild(fileref)
		};

      dwr.util.setEscapeHtml(false);
      <c:if test="${!empty sessionUser}">
        dojo.addOnLoad(mango.header.onLoad);
        dojo.addOnLoad(function() { setUserMuted(${sessionUser.muted}); });
      </c:if>

      function setLocale(locale) {
          MiscDwr.setLocale(locale, function() { window.location = window.location });
      }

      function setHomeUrl() {
          MiscDwr.setHomeUrl(window.location.href, function() { alert("Home URL saved"); });
      }

      function goHomeUrl() {
          MiscDwr.getHomeUrl(function(loc) { window.location = loc; });
      }

      function swapStyleSheet(sheet) {
        document.getElementById("pagestyle").setAttribute("href", sheet);
        localStorage.setItem('theme', sheet);
      }

      function initate() {

        var theme = localStorage.getItem('theme');
        if (theme) {
            document.getElementById("pagestyle").setAttribute("href", theme);
        }

        var style1 = document.getElementById("stylesheet1");
        var style2 = document.getElementById("stylesheet2");

        style1.onclick = function () { swapStyleSheet("assets/common_deprecated.css") };
        style2.onclick = function () { swapStyleSheet("assets/common.css") };
      }

      window.onload = initate;

    </script>
  </c:if>
</head>

<script>
    /* When the user clicks on the button,
    toggle between hiding and showing the dropdown content */
    function myDropdownFunction() {
      document.getElementById("myDropdown").classList.toggle("show");
    }

    function filterFunction() {
      var input, filter, ul, li, a, i;
      input = document.getElementById("myInput");
      filter = input.value.toUpperCase();
      div = document.getElementById("myDropdown");
      a = div.getElementsByTagName("a");
      for (i = 0; i < a.length; i++) {
        if (a[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
          a[i].style.display = "";
        } else {
          a[i].style.display = "none";
        }
      }
    }
</script>

<body>
  <header id="mainHeader" >
    <nav class="navbar navbar-default">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#" style="font-size: 18pt; font-family: Impact, Charcoal, sans-serif; color: black;">Supervisorio ScadaBR Natal/RN</a>
          <c:if test="${!empty sessionUser}"> <br> Usuário: <b>${sessionUser.username}</b> </c:if>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <c:if test="${!empty sessionUser}">
              <li><a><tag:img png="house" title="header.goHomeUrl" onclick="goHomeUrl()" onmouseover="hideLayer('localeEdit')"/> <br> Home</a></li>
              <li id="blank">
                <li id="dropbtn" onclick="myDropdownFunction()" class="dropbtn"><a><tag:img id="Systems" png="modulos" title="header.sistemas"/><br>Sistemas</a></li>
                <div id="myDropdown" class="dropdown-content">
                  <input type="text" placeholder="Procurar..." id="myInput" onkeyup="filterFunction()">
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=82">CANDELARIA</a>
                    <a href="http://scadabr.caern.govrn:8080/ScadaBR/views.shtm?viewId=110">DUNAS</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=82">SAN VALE</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=85">NOVO CAMPO</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=104"><f>FELIPE CAMARÃO</f></a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=106">LAGOA NOVA I</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=107">LAGOA NOVA II</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=81">PONTA NEGRA</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=86">SATÉLITE</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=84">PLANALTO</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=112">JIQUI</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=108">PIRANGI</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=109">GUARAPES</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=105">NOVA CIDADE</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=111">DIX SEPT ROSADO</a>
                    <a href="https://scadabr-smn.caern.com.br/ScadaBR/views.shtm?viewId=111">BOOSTER GMS</a>
                  </div>
                </li>
                <li><a href="reports.shtm" onclick="onClickHelp(this,'reportInstancesMenu')" > <tag:img id="Reports" png="report" title="header.reports"/> <br> Relatorios</a></li>
                <li><a href="events.shtm" onclick="" > <tag:img id="Alarms" png="flag_white" title="header.alarms"/> <br> Alarmes </a></li>
                <li><a href="views.shtm?viewId=16"  > <tag:img id="Maps" png="maps" title="header.maps"/> <br> Mapa </a></li>
                <li><a href="contato.shtm" ><tag:img id="Contact" png="email" title="header.contato"/> <br> Contato </a></li>
                <li><a> <tag:img png="full" title="header.full" onclick="full()"/> <br> Full </a></li>
                <li><a> <tag:img id="userMutedImg" onclick="MiscDwr.toggleUserMuted(setUserMuted)" onmouseover="hideLayer('localeEdit')"/> <br> Som </a></li>
                <li><a href="logout.htm"><tag:img png="logout" title="header.logout" onmouseover="hideLayer('localeEdit')"/> <br> Sair</a></li>
              </c:if>
            </ul>

            <c:if test="${!empty sessionUser}">
              <ul class="nav navbar-nav navbar-right">
              <!-- <li class="active"><a href="./"><span class="sr-only">(current)</span></a></li> -->

              <c:if test="${!simple}">
                <div align="right" width="30%" id="eventsRow" class="projectTitle" style="clear:right; padding:8px;	background: gray;">
                  <a href="events.shtm">
                    <span id="__header__alarmLevelDiv" style="display:none;">
                      <img id="__header__alarmLevelImg" src="images/spacer.gif" alt="" border="0" title=""/>
                      <span id="__header__alarmLevelText"></span>
                    </span>
                  </a>
                </div>
              </c:if>
            </ul>
          </c:if>
          </div><!--/.nav-collapse -->
        </div><!--/.container-fluid -->
      </nav>


      <c:if test="${!simple}">
        <ul id="adminBar" class="semi-transparent">
          <c:if test="${!empty sessionUser}">
            <c:if test="${sessionUser.admin}">
              <li><a href="users.shtm" ><tag:img id="Users" png="user" title="header.users"/> <br> Usuários </a></li>
              <li><a href="emport.shtm" ><tag:img id="Emport" png="script_code" title="header.emport"/> <br> Import </a></li>
              <li><a href="watch_list.shtm" > <tag:img id="Whatchlist"  png="eye" title="header.watchlist"  /><br> Whatchlist </a></li>
              <li><a href="event_handlers.shtm" ><tag:img id="event_handlers" png="cog" title="header.eventHandlers"/> <br> Event Handlers </a></li>
              <li><a href="data_sources.shtm" ><tag:img id="data_sources" png="icon_ds" title="header.dataSources"/> <br> Data Sources </a></li>
              <li><a href="estatisticas.shtm" ><tag:img id="chart" png="chart" title="header.estatisticas"/> <br> Estatísticas </a></li>
              <li><a href="scheduled_events.shtm" ><tag:img id="scheduled_events" png="clock" title="header.scheduledEvents"/> <br> Eventos Programados </a></li>
              <li><a href="compound_events.shtm" ><tag:img id="compound_events" png="multi_bell" title="header.compoundEvents"/> <br> Eventos Compostos </a></li>
              <li><a href="point_links.shtm" ><tag:img id="point_links" png="link" title="header.pointLinks"/> <br> Point Links </a></li>
              <li><a href="scripting.shtm" ><tag:img id="scripting" png="script_gear" title="header.scripts"/> <br> Scripts </a></li>
              <li><a href="point_hierarchy.shtm" ><tag:img id="point_hierarchy" png="folder_brick" title="header.pointHierarchy"/> <br> Hierarquia </a></li>
              <li><a href="mailing_lists.shtm" ><tag:img id="mailing_lists" png="book" title="header.mailingLists"/> <br>  Listas de Email </a></li>
              <li><a href="publishers.shtm" ><tag:img id="publishers" png="transmit" title="header.publishers"/> <br> Publicadores </a></li>
              <li><a href="maintenance_events.shtm" ><tag:img id="maintenance_events" png="hammer" title="header.maintenanceEvents"/> <br> Manutencao </a></li>
              <li><a href="system_settings.shtm" ><tag:img id="system_settings" png="application_form" title="header.systemSettings"/> <br> Configuracoes </a></li>
              <li><a href="sql.shtm" ><tag:img id="sql" png="script" title="header.sql"/> <br> SQL </a></li>
            </c:if>
              <%-- <div style="display:inline;" class="ptr" onmouseover="showMenu('localeEdit', -40, 10);">
              <tag:img png="world" title="header.changeLanguage"/> --%>
              <%-- <div id="localeEdit" style="visibility:hidden;left:0px;top:15px;" class="labelDiv" onmouseout="hideLayer(this)">
                <c:forEach items="${availableLanguages}" var="lang">
                  <a class="ptr" onclick="setLocale('${lang.key}')">${lang.value}</a><br/>
                </c:forEach>
              </div> --%>
            </div>
        </c:if>
      </ul>
    </c:if>
  </header>

<div class="content" style="padding-top:10px; padding-bottom: 50px;">
  <jsp:doBody/>
</div>

<div class="footer" style="text-align:center">
  <p colspan="2"  align="center"> &copy;2009-2011 Fundação Certi, MCA Sistemas, Unis Sistemas, Conetec. Todos os direitos reservados. <br> &copy;2018 Companhia de aguas e Esgotos do RN - CAERN. <fmt:message key="footer.rightsReserved"/></p>
</div>
<c:if test="${!empty onload}">
  <script type="text/javascript">dojo.addOnLoad(${onload});</script>
</c:if>

</body>
</html>
