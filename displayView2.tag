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
--%><%@include file="/WEB-INF/tags/decl.tagf"%><%--
--%><%@tag body-content="empty"%><%--
--%><%@attribute name="view" type="com.serotonin.mango.view.View" required="true" rtexprvalue="true"%><%--
--%><%@attribute name="emptyMessageKey" required="true"%>


<div id="viewContent">

<style>
.list-group-item
{
  padding-right: 10px;
  padding-left: 10px;
  text-align:center;
}

.verde
{
  background-color: #4EA53D;
}
.vermelho
{
  background-color: #EA4946;
}

.local{
  color: #b7b305;
  background-color: #f9e504;
  margin-left: 3px;
  padding: 3px;
}

.remoto{
  color: #0e037c;
  background-color: #1803f9;
  margin-left: 3px;
  padding: 3px;
}
</style>


  <div class="container col-xs-12">
    <nav class="navbar navbar-default">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#"><img src="http://adcon.rn.gov.br/ACERVO/caern/IMG/IMG000000000012363.PNG" alt="W3Schools.com" style="width:120px;height:53px; padding-bottom: 15px;"></a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="scadalts/views.shtm">Início</a></li>
            <li><a href="http://scadabr.caern.com.br:8080/ScadaBR/views.shtm?viewId=60">Manutenção</a></li>
            <li><a href="http://scadabr.caern.com.br:8080/ScadaBR/views.shtm?viewId=55">Fluxograma</a></li>
          </ul>

          <ul class="nav navbar-nav navbar-right">
            <!-- <li class="active"><a href="./"><span class="sr-only">(current)</span></a></li> -->
          </ul>
        </div><!--/.nav-collapse -->
      </div><!--/.container-fluid -->
    </nav>

  <c:forEach items="${view.viewComponents}" var="vc">  
    <!-- vc ${vc.id} -->
    <c:choose>
      <c:when test="${!vc.visible}"><!-- vc ${vc.id} not visible --></c:when>

      <c:when test="${vc.defName == 'simpleCompound'}">
        <div id="c${vc.id}" style="position:absolute;left:${vc.x}px;top:${vc.y}px;"
                  onmouseover="vcOver('c${vc.id}', 5);" onmouseout="vcOut('c${vc.id}');">
          <tag:pointComponent vc="${vc.leadComponent}"/>
          <c:choose>
            <c:when test="${empty vc.backgroundColour}"><c:set var="bkgd"></c:set></c:when>
            <c:otherwise><c:set var="bkgd">background:${vc.backgroundColour};</c:set></c:otherwise>
          </c:choose>
          <div id="c${vc.id}Controls" class="controlContent" style="left:5px;top:5px;${bkgd}">
            <b>${vc.name}</b><br/>
            <c:forEach items="${vc.childComponents}" var="child">
              <c:if test="${child.viewComponent.visible && child.viewComponent.id != vc.leadComponent.id}">
                <tag:pointComponent vc="${child.viewComponent}"/>
              </c:if>
            </c:forEach>
          </div>
        </div>
      </c:when>

      <c:when test="${vc.defName == 'imageChart'}">
        <div id="c${vc.id}" style="position:absolute;left:${vc.x}px;top:${vc.y}px;"
                  onmouseover="vcOver('c${vc.id}', 10);" onmouseout="vcOut('c${vc.id}');">
          <div id="c${vc.id}Content"><img src="images/icon_comp.png" alt=""/></div>
          <div id="c${vc.id}Controls" class="controlContent">
            <div id="c${vc.id}Info">
              <tag:img png="hourglass" title="common.gettingData"/>
            </div>
          </div>
        </div>
      </c:when>

      <c:when test="${vc.compoundComponent}">
        <div id="c${vc.id}" style="position:absolute;left:${vc.x}px;top:${vc.y}px;"
                  onmouseover="vcOver('c${vc.id}', 5);" onmouseout="vcOut('c${vc.id}');">
          ${vc.staticContent}
          <div id="c${vc.id}Controls" class="controlsDiv">
            <table cellpadding="0" cellspacing="1">
              <tr onmouseover="showMenu('c${vc.id}Info', 16, 0);" onmouseout="hideLayer('c${vc.id}Info');"><td>
                <tag:img png="information"/>
                <div id="c${vc.id}Info" onmouseout="hideLayer(this);">
                  <tag:img png="hourglass" title="common.gettingData"/>
                </div>
              </td></tr>
              <c:if test="${vc.displayImageChart}">
                <tr onmouseover="mango.view.showChart('${vc.id}', event, this);"
                        onmouseout="mango.view.hideChart('${vc.id}', event, this);"><td>
                  <img src="images/icon_chart.png" alt=""/>
                  <div id="c${vc.id}ChartLayer"></div>
                  <textarea style="display:none;" id="c${vc.id}Chart"><tag:img png="hourglass" title="common.gettingData"/></textarea>
                </td></tr>
              </c:if>
            </table>
          </div>
          <c:forEach items="${vc.childComponents}" var="child">
            <c:if test="${child.viewComponent.visible}"><tag:pointComponent vc="${child.viewComponent}"/></c:if>
          </c:forEach>
        </div>
      </c:when>

      <c:otherwise>
      	<c:choose>
      	 <c:when test="${vc.pointComponent}">
      	     <div class="col-sm-3 panel-group">
			      <div class="panel panel-default">
			        <div class="panel-heading">
			          <h4 class="panel-title">
			            <a data-toggle="" href="">
							 ${vc.name.substring(0, 3)}
			            </a>
			          </h4>
			        </div>
			        <div id="collapse1" class="panel-collapse collapse in">
			         	<ul class="list-group">
			             	<li class="">
			     				 ${vc.name.substring(4, vc.name.length())} <tag:pointComponent2 vc="${vc}"/>
			          		</li>
			          	</ul>
          				<div class="panel-footer"></div>
	          		</div>
	      		</div>
	   		 </div>
          			
         </c:when>
         <c:otherwise>
           		<tag:pointComponent vc="${vc}"/>
      	</c:otherwise>
      	</c:choose>
      </c:otherwise>
    </c:choose>
    
  </c:forEach>
  
       

  </div>
</div>

