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
<%@ include file="/WEB-INF/jsp/include/tech.jsp" %>
<%@page import="com.serotonin.mango.Common"%>

<tag:page onload="init">
<c:if test="${selecionado != null}">
	<link rel="stylesheet" href="resources/chartist.css">
	
	<style>
       .ct-chart {
           position: relative;
       }
       .ct-legend {
       	   position: relative;
           z-index: 10;
           list-style: none;
           text-align: center;
       }
       .ct-legend li {
           position: relative;
           padding-left: 23px;
           margin-right: 10px;
           margin-bottom: 3px;
           cursor: pointer;
           display: inline-block;
       }
       .ct-legend li:before {
           width: 12px;
           height: 12px;
           position: absolute;
           left: 0;
           content: '';
           border: 3px solid transparent;
           border-radius: 2px;
       }
       .ct-legend li.inactive:before {
           background: transparent;
       }
       .ct-legend.ct-legend-inside {
           position: absolute;
           top: 0;
           right: 0;
       }
       .ct-legend.ct-legend-inside li{
           display: block;
           margin: 0;
       }
       .ct-legend .ct-series-0:before {
           background-color: #0B486B;
           border-color: #0B486B;
       }
       .ct-legend .ct-series-1:before {
           background-color: #69D2E7;
           border-color: #69D2E7;
       }
       .ct-legend .ct-series-2:before {
           background-color: #f4c63d;
           border-color: #f4c63d;
       }
       .ct-legend .ct-series-3:before {
           background-color: #d17905;
           border-color: #d17905;
       }
       .ct-legend .ct-series-4:before {
           background-color: #453d3f;
           border-color: #453d3f;
       }
       
      

    </style>

	<script type="text/javascript" src="resources/chartist.min.js"></script>
	<script type="text/javascript" src="resources/chartist-plugin-legend.js"></script>
	<script type="text/javascript">	
	
		<c:if test="${selecionado[0] == '1'}">
			//Gráfico de pizza de usuários admin x outros
			function adminOutros() 
			{

				var sum = function(a, b) { return a + b };

				var data = 
				{
				  <c:set var="adminPor" value="${(adminNum[0] / (adminNum[0] + outrosNum[0])) * 100}"/>
				  <c:set var="outrosPor" value="${(outrosNum[0] / (adminNum[0] + outrosNum[0])) * 100}"/>

				  labels: ['Admin (${adminNum[0]} - <fmt:formatNumber value="${adminPor}" minFractionDigits="0" maxFractionDigits="2"/>%)', 
				  		   'Outros (${outrosNum[0]} - <fmt:formatNumber value="${outrosPor}" minFractionDigits="0" maxFractionDigits="2"/>%)'],
				  series: [${adminNum[0]},${outrosNum[0]}]
				};

				var options = 
				{
					showLabel: false,
					plugins: [ Chartist.plugins.legend() ]
				};

				new Chartist.Pie('.ct-chart', data, options);
	      	}
		</c:if>
		
		<c:if test="${selecionado[0] == '2'}">
			function representacoesGraficas() 
			{
				var data = 
				{
				  labels: 
				  [ 
				  	<c:if test="${tamanhoGrafico[0] > 0}">
				  		<c:forEach var="i" begin="0" end="${tamanhoGrafico[0]}">
			            	'<c:out value = "${nomes[i]}"/>',
			            </c:forEach>
			        </c:if>
			        
			            '<c:out value = "${nomes[tamanhoGrafico[0]]}"/>'
				  ] 
					  ,
				  series: 
			      [
				    [
				    	<c:if test="${tamanhoGrafico[0] > 0}">
				    		<c:forEach var="i" begin="0" end="${tamanhoGrafico[0]-1}">
			          			<c:out value = "${quantidades[i]}"/>,
			          	</c:forEach>
			          	</c:if>
			            	<c:out value = "${quantidades[tamanhoGrafico[0]]}"/>
				    ]
				  ]
				};

				var options = {
				  seriesBarDistance: 10
				};

				new Chartist.Bar('.ct-chart', data, options);
			}
		</c:if>
		
		
		<c:if test="${selecionado[0] == '3'}">

		
		function watchListPontos() 
		{
			var data = 
			{
			  labels: 
			  [ 
			  	<c:if test="${tamanhoGrafico[0] > 0}">
			  		<c:forEach var="i" begin="0" end="${tamanhoGrafico[0] - 1}">
		            	'<c:out value = "${nomes[i]}"/>',
		            </c:forEach>
		        </c:if>
		        
		            '<c:out value = "${nomes[tamanhoGrafico[0]]}"/>'
			  ] 
				  ,
			  series: 
		      [
			    {"name" : "Watch Lists", "data" : 
			    [
			    
			    	<c:if test="${tamanhoGrafico[0] > 0}">
			    		<c:forEach var="i" begin="0" end="${tamanhoGrafico[0]-1}">
		          			<c:out value = "${quantidadesWL[i]}"/>,
		          	</c:forEach>
		          	</c:if>
		            	<c:out value = "${quantidadesWL[tamanhoGrafico[0]]}"/>
			    ]},

			    {"name" : "Data Points", "data" : 
			    [
			    	<c:if test="${tamanhoGrafico[0] > 0}">
			    		<c:forEach var="i" begin="0" end="${tamanhoGrafico[0]-1}">
		          			<c:out value = "${quantidadesPO[i]}"/>,
		          	</c:forEach>
		          	</c:if>
		            	<c:out value = "${quantidadesPO[tamanhoGrafico[0]]}"/>
			    ]}
			    
			  ]
			};

			var options = {
			  seriesBarDistance: 10,
			  plugins: [ Chartist.plugins.legend() ]
			};

			new Chartist.Bar('.ct-chart', data, options);
		}
		</c:if>
		
		
		<c:if test="${selecionado[0] == '4'}">
			//Gráfico de pizza dos estados de DataSources
			function dataSourcesEstados() 
			{
	
				<c:set var="habPor" value="${(habilitado[0] / (habilitado[0] + desabilitado[0])) * 100}"/>
				<c:set var="desPor" value="${(desabilitado[0] / (habilitado[0] + desabilitado[0])) * 100}"/>
	
				var data = {
				  labels: ['Habilitados (${habilitado[0]} - <fmt:formatNumber value="${habPor}" minFractionDigits="0" maxFractionDigits="2"/>%)', 
				  		   'Desabilitados (${desabilitado[0]} - <fmt:formatNumber value="${desPor}" minFractionDigits="0" maxFractionDigits="2"/>%)'],
				  series: [${habilitado[0]},${desabilitado[0]}]
				};
	
				var options = 
				{
					showLabel: false,
					plugins: [ Chartist.plugins.legend() ]
				};

				new Chartist.Pie('.ct-chart', data, options);
	      	}
		</c:if>
		
		<c:if test="${selecionado[0] == '5'}">
		//Gráfico de pizza dos estados de DataPoints
		function dataPointsEstados() 
		{

				<c:set var="habPor" value="${(habilitado[0] / (habilitado[0] + desabilitado[0])) * 100}"/>
				<c:set var="desPor" value="${(desabilitado[0] / (habilitado[0] + desabilitado[0])) * 100}"/>
	
				var data = {
				  labels: ['Habilitados (${habilitado[0]} - <fmt:formatNumber value="${habPor}" minFractionDigits="0" maxFractionDigits="2"/>%)', 
				  		   'Desabilitados (${desabilitado[0]} - <fmt:formatNumber value="${desPor}" minFractionDigits="0" maxFractionDigits="2"/>%)'],
				  series: [${habilitado[0]},${desabilitado[0]}]
				};
	
				var options = 
				{
					showLabel: false,
					plugins: [ Chartist.plugins.legend() ]
				};

				new Chartist.Pie('.ct-chart', data, options);
      	}
	</c:if>
		
		
			function init()
			{
				<c:if test="${selecionado[0] == '1'}">
			  		adminOutros();
				</c:if>
				<c:if test="${selecionado[0] == '2'}">
					representacoesGraficas();
				</c:if>
				<c:if test="${selecionado[0] == '3'}">
					watchListPontos();
				</c:if>
				<c:if test="${selecionado[0] == '4'}">
					dataSourcesEstados();
				</c:if>
				<c:if test="${selecionado[0] == '5'}">
					dataPointsEstados();
				</c:if>
			}

	</script>
</c:if>

	<table style="width: 100%">
	    <tr>
	      <td rowspan="2" valign="top">
	        <div class="borderDiv">
	          
	          <table>
	            <tr>
	              <td>
	                <span class="smallTitle">ESTATÍSTICAS</span>
	              </td>
	            </tr>
	          </table>
	          
	        </div>
	      </td>
	    </tr>
	</table>
	
	<div class="borderDiv" style="width: 100%">
		<form action="estatisticas.shtm" method="post">
					<input type="radio" name="tipo" value="1" <c:if test="${selecionado[0] == '1'}"> checked </c:if> <c:if test="${selecionado == null}"> checked </c:if> > Usuários Admins X Normais<br>
					<input type="radio" name="tipo" value="2" <c:if test="${selecionado[0] == '2'}"> checked </c:if> > Quantidade de Representações Gráficas<br>
					<input type="radio" name="tipo" value="3" <c:if test="${selecionado[0] == '3'}"> checked </c:if> > Quantidade de Watch Lists e Data Points<br>
					<input type="radio" name="tipo" value="4" <c:if test="${selecionado[0] == '4'}"> checked </c:if> > Quantidade de Data Sources habilitados<br>
					<input type="radio" name="tipo" value="5" <c:if test="${selecionado[0] == '5'}"> checked </c:if> > Quantidade de Data Points habilitados<br>
					<input type="radio" name="tipo" value="6" <c:if test="${selecionado[0] == '6'}"> checked </c:if> > Data Sources fora do padrão<br>
					<input type="radio" name="tipo" value="7" <c:if test="${selecionado[0] == '7'}"> checked </c:if> > Data Source host e Porta<br>
					<input type="radio" name="tipo" value="8" <c:if test="${selecionado[0] == '8'}"> checked </c:if> > Cadastro Modem<br>
					<input type="radio" name="tipo" value="9" <c:if test="${selecionado[0] == '9'}"> checked </c:if> > Cadastro Modbus<br>
					<input type="radio" name="tipo" value="10" <c:if test="${selecionado[0] == '10'}"> checked </c:if> > Quantidade de erros por Data Source<br>
					<input type="submit" value="Gerar" name="gerar">
		</form>
	</div>
	
	<c:if test="${erro != null}">
		${erro}
	</c:if>
	
	<c:if test="${tamanhoGrafico != null}">
		<div class="borderDiv" style="width: 100%">
			<div id="ct-chart" class="ct-chart" style="width: 800px; height: 400px;" ></div>
		</div>
	</c:if>
	
	<c:if test="${tabelaHeader != null}">
		<fieldset>
	       <table cellspacing="1">
	         <tr class="rowHeader">
	           <c:forEach var="i" begin="1" end="${tabelaHeader[0]}">
	             <td><c:out value = "${tabelaHeader[i]}"/></td>
	           </c:forEach>
	         </tr>
	         
	         <c:forEach var="i" begin="0" end="${tamanhoTabela[0] - 1}">
	           <tr class="row">
	           		<c:if test="${selecionado[0] == '1'}">
	             		<td><c:out value = "${username[i]}"/></td>
	             		<td><c:out value = "${telefone[i]}"/></td>
	             		<td><c:out value = "${email[i]}"/></td>
	             		<td><c:out value = "${admin[i]}"/></td>
	             	</c:if>
	             	
	             	<c:if test="${selecionado[0] == '6'}">
	             		<td><c:out value = "${id[i]}"/></td>
	             		<td><c:out value = "${xid[i]}"/></td>
	             		<td><c:out value = "${nome[i]}"/></td>
	             		<td><c:out value = "${resultado[i]}"/></td>
	             	</c:if>
	             	
	             	<c:if test="${selecionado[0] == '7'}">
	             		<td><c:out value = "${id[i]}"/></td>
	             		<td><c:out value = "${xid[i]}"/></td>
	             		<td><c:out value = "${nome[i]}"/></td>
	             		<td><c:out value = "${host[i]}"/></td>
	             		<td><c:out value = "${porta[i]}"/></td>
	             	</c:if>
	             	
	             	<c:if test="${selecionado[0] == '8'}">
	             		<td><c:out value = "${id[i]}"/></td>
	             		<td><c:out value = "${xid[i]}"/></td>
	             		<td><c:out value = "${nome[i]}"/></td>
	             		<td><c:out value = "${B0[i]}"/></td>
	             		<td><c:out value = "${B1[i]}"/></td>
	             		<td><c:out value = "${B2[i]}"/></td>
	             		<td><c:out value = "${B3[i]}"/></td>
	             		<td><c:out value = "${B4[i]}"/></td>
	             		<td><c:out value = "${B5[i]}"/></td>
	             		<td><c:out value = "${B6[i]}"/></td>
	             		<td><c:out value = "${B7[i]}"/></td>
	             		<td><c:out value = "${B03[i]}"/></td>
	             		<td><c:out value = "${B04[i]}"/></td>
	             		<td><c:out value = "${B05[i]}"/></td>
	             		<td><c:out value = "${B06[i]}"/></td>
	             	</c:if>
	             	
	             	<c:if test="${selecionado[0] == '9'}">
	             		<td><c:out value = "${id[i]}"/></td>
	             		<td><c:out value = "${nome[i]}"/></td>
	             		<td><c:out value = "${B1[i]}"/></td>
	             		<td><c:out value = "${B2[i]}"/></td>
	             		<td><c:out value = "${B4[i]}"/></td>
	             		<td><c:out value = "${B5[i]}"/></td>
	             		<td><c:out value = "${B6[i]}"/></td>
	             		<td><c:out value = "${B7[i]}"/></td>
	             		<td><c:out value = "${B8[i]}"/></td>
	             		<td><c:out value = "${B9[i]}"/></td>
	             		<td><c:out value = "${B10[i]}"/></td>
	             		<td><c:out value = "${B11[i]}"/></td>
	             		<td><c:out value = "${B54[i]}"/></td>
	             		<td><c:out value = "${B88[i]}"/></td>
	             		<td><c:out value = "${B100[i]}"/></td>
	             		<td><c:out value = "${B101[i]}"/></td>
	             	</c:if>
	             	
	             	<c:if test="${selecionado[0] == '10'}">
	             	
	             		<td>
	             			<a href='#' onClick="MyWindow=window.open('lista_erro.shtm?id=<c:out value = "${id[i]}" />','MyWindow',width=600,height=300);return false;"> <c:out value = "${xid[i]}" /> </a> 
	             		</td>
	             		<td><c:out value = "${nome[i]}"/></td>
	             		<td><c:out value = "${erros[i]}"/></td>
	             	</c:if>
	             	
	             	
	           </tr>
	         </c:forEach>
	         
	         
	       </table>
	   	</fieldset> 
	</c:if>
	
</tag:page>