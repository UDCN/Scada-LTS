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
	<script type="text/javascript" src="resources/chartist.min.js"></script>
	<script type="text/javascript">	
	
	${selecionado}
		
		<c:if test="${selecionado[0] == '1'}">
			//Gráfico de pizza de usuários admin x outros
			function adminOutros() 
			{

				var sum = function(a, b) { return a + b };

				var data = {
				  labels: ['Admin', 'Outros'],
				  series: [${adminNum[0]},${outrosNum[0]}]
				};

				var options = {
				  labelInterpolationFnc: function(value) {
				    var posicao = data.labels.indexOf(value);
				    var valor = data.series[posicao]
				    var valorPor = Math.round(valor / data.series.reduce(sum) * 100) + '%';
				    return value + ' (' + valorPor + ' / ' + valor + ')'
				  }
				  
				};
				new Chartist.Pie('.ct-chart', data, options);
	      	}
			
		</c:if>	
	
		<c:if test="${form.tipoGrafico == '2'}">
			//Gráfico de barras de representação gráfica
			function drawChartViews() 
			{
				var data = new google.visualization.DataTable();
					data.addColumn('string','VIEWS');
					data.addColumn('number', 'N Views');
					data.addRows(${form.listaGrafico[0]});
	
					<c:forEach var = "i" begin = "0" end = "${form.listaGrafico[0]-1}" step="1">
						data.setValue(<c:out value = "${i}"/>, 0, '<c:out value = "${form.listaGrafico[2*i+1]}"/>' );
						data.setValue(<c:out value = "${i}"/>, 1, <c:out value = "${form.listaGrafico[2*i+2]}"/> );
			        	
			      	</c:forEach>
					
		        var options = {
		          chart: {
		            title: 'Representacao Grafica',
		            subtitle: 'Numero de Representacoes graficas de cada usuario',
		          }
		        };
		        var chart = new google.charts.Bar(document.getElementById('chart_div'));
		        chart.draw(data, options);
		      }	
		</c:if>
		
		<c:if test="${form.tipoGrafico == '3'}">
			//Gráfico de barra de Watch Lists e Datapoints por usuários
			function drawChartViews() 
			{
				var data = new google.visualization.DataTable();
					data.addColumn('string','WATCHLISTS');
					data.addColumn('number', 'N Watchlist');
					data.addColumn('number', 'N DataPoints');
					data.addRows(${form.listaGrafico[0]});
	
					<c:forEach var = "i" begin = "0" end ="${form.listaGrafico[0]-1}" step="1">
						data.setValue(<c:out value = "${i}"/>, 0, '<c:out value = "${form.listaGrafico[3*i+1]}"/>' );
						data.setValue(<c:out value = "${i}"/>, 1, <c:out value = "${form.listaGrafico[3*i+2]}"/> );
						data.setValue(<c:out value = "${i}"/>, 2, <c:out value = "${form.listaGrafico[3*i+3]}"/> );
			      	</c:forEach>
					
		        var options = {
		          chart: {
		            title: 'Representacao Grafica',
		            subtitle: 'Numero de Watchlists e Datapoints de cada usuario',
		          }
		        };
		        var chart = new google.charts.Bar(document.getElementById('chart_div'));
		        chart.draw(data, options);
	      }	
		</c:if>
		
		
		<c:if test="${form.tipoGrafico == '4'}">
			//Gráfico de pizza de datasources habilitados x desabilitados
			function drawChartPizza() 
			{

	    		//Create the data table.
	    	    var data = new google.visualization.DataTable();
		        data.addColumn('string', 'Topping');
	        	data.addColumn('number', 'Slices');
		    	data.addRows([ ['Habilitados (${form.listaGrafico[0]})', ${form.listaGrafico[0]}], 
		    		['Desabilitados (${form.listaGrafico[1]})', ${form.listaGrafico[1]}] ]);
	
	        	//Set chart options
	        	var options = {'title':'Quantidade de Data Sources Habilitados x Desabilitados',
	                       'width':800,
	                       'height':400};
	
	        	//Instantiate and draw our chart, passing in some options.
	        	var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
	        	chart.draw(data, options);
	      	}
		</c:if>	
		
		<c:if test="${form.tipoGrafico == '5'}">
			//Gráfico de pizza de datapoints habilitados x desabilitados
			function drawChartPizza() 
			{
	
	    		//Create the data table.
	    	    var data = new google.visualization.DataTable();
		        data.addColumn('string', 'Topping');
	        	data.addColumn('number', 'Slices');
		    	data.addRows([ ['Habilitados (${form.listaGrafico[0]})', ${form.listaGrafico[0]}], 
		    		['Desabilitados (${form.listaGrafico[1]})', ${form.listaGrafico[1]}] ]);
	
	        	//Set chart options
	        	var options = {'title':'Quantidade de Data Points Habilitados x Desabilitados',
	                       'width':800,
	                       'height':400};
	
	        	//Instantiate and draw our chart, passing in some options.
	        	var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
	        	chart.draw(data, options);
	      	}
		</c:if>	
		
		
		
			function init()
			{
				// Load the Visualization API and the corechart package.
			      	// initialization code goes here
			  	<c:if test="${selecionado[0] == '1'}">
			  		adminOutros();
				</c:if>
				
				<c:if test="${form.tipoGrafico == '2'}">
					google.charts.load('current', {'packages':['bar']});
		    		google.charts.setOnLoadCallback(drawChartViews);	
		    		drawChartViews();
				</c:if>
				
				<c:if test="${form.tipoGrafico == '3'}">
					google.charts.load('current', {'packages':['bar']});
		    		google.charts.setOnLoadCallback(drawChartViews);	
		    		drawChartViews();
				</c:if>
				
				<c:if test="${form.tipoGrafico == '4'}">
			  		google.charts.load('current', {'packages':['corechart']});
			    	google.charts.setOnLoadCallback(drawChartPizza);	
			  		drawChartPizza();
				</c:if>
				
				<c:if test="${form.tipoGrafico == '5'}">
			  		google.charts.load('current', {'packages':['corechart']});
			    	google.charts.setOnLoadCallback(drawChartPizza);	
			  		drawChartPizza();
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
	
	<c:if test="${selecionado != null}">
		<div class="borderDiv" style="width: 100%">
			<div id="ct-chart" class="ct-chart" style="width: 800px; height: 400px;" ></div>
		</div>
	</c:if>
	
	<c:if test="${tabela != null}">
		<fieldset>
	       <table cellspacing="1">
	         <tr class="rowHeader">
	           <c:forEach var="i" begin="1" end="${tabela[0]}">
	             <td><c:out value = "${tabela[i]}"/></td>
	           </c:forEach>
	         </tr>
	         <c:forEach var="i" begin="0" end="${tamanhoTabela[0]}">
	           <tr class="row">
	           		<c:if test="${selecionado[0] == '1'}">
	             		<td><c:out value = "${username[i]}"/></td>
	             		<td><c:out value = "${telefone[i]}"/></td>
	             		<td><c:out value = "${email[i]}"/></td>
	             		<td><c:out value = "${admin[i]}"/></td>
	             	</c:if>
	           </tr>
	         </c:forEach>
	       </table>
	   	</fieldset> 
	</c:if>
	
</tag:page>