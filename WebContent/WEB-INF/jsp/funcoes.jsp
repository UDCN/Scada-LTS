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

<link rel="stylesheet" href="resources/jQuery/plugins/chosen/chosen.min.css">
<script type="text/javascript" src="resources/jQuery/plugins/chosen/chosen.jquery.min.js"></script>

<c:if test="${grafico != null}">
	<link rel="stylesheet" href="resources/chartist.css">
	
	<style>	
		/* style the svg rect */
		.ct-zoom-rect {
		  fill: rgba(200, 100, 100, 0.3);
		  stroke: red;
		}
	</style>
	<script type="text/javascript" src="resources/chartist.min.js"></script>
	<script type="text/javascript" src="resources/chartist-plugin-zoom.js"></script>
	<script type="text/javascript" src="resources/moment.js"></script>
	
	<script type="text/javascript">
		function grafico() 
		{
			
			var data =
			{
			  series: 
			  [
			    {
			      name: 'Grafico-1',
			      data: 
			      [
			    	  <c:forEach items="${grafico}" var="linha">
			    	 	{x: new Date(${linha[0]}), y: ${linha[1]} 
			          </c:forEach>				    	  
			      ]
			    }
			  ]
			};
			
			var options = 
			{
			  axisX: 
			  {
			    type: Chartist.AutoScaleAxis,
			    scaleMinSpace: 100,
			    labelInterpolationFnc: function(value) 
			    {
			      return moment(value).format('D/M/Y H:mm:ss');
			    }
			  },
			  plugins: 
			  [
				  Chartist.plugins.zoom({ onZoom: onZoom })
			  ]
			};
		
			
			var chart = new Chartist.Line('.grafico', data, options);
			
			var resetFnc1;
			function onZoom(chart, reset) {
			  resetFnc1 = reset;
			}
			
			var btn1 = document.createElement('button');
			btn1.id = 'reset-zoom-btn1';
			btn1.innerHTML = 'Reset Zoom';
			btn1.style.float = 'right';
			btn1.addEventListener('click', function() {
			  console.log(resetFnc1);
			  resetFnc1 && resetFnc1();
			});
			var parent = document.querySelector('.grafico');
			!parent.querySelector('#reset-zoom-btn') && parent.appendChild(btn1);
			
		}
	</script>
	
	<script type="text/javascript">
		function grafico2() 
		{
			
			var data =
			{
			  series: 
			  [
			    {
			      name: 'Grafico-2',
			      data: 
			      [
			    	  <c:forEach items="${grafico2}" var="linha">
			    	 	{x: new Date(${linha[0]}), y: ${linha[1]} 
			          </c:forEach>				    	  
			      ]
			    }
			  ]
			};
			
			var options = 
			{
			  axisX: 
			  {
			    type: Chartist.AutoScaleAxis,
			    scaleMinSpace: 100,
			    labelInterpolationFnc: function(value) 
			    {
			      return moment(value).format('D/M/Y H:mm:ss');
			    }
			  },
			  plugins: 
			  [
				  Chartist.plugins.zoom({ onZoom: onZoom })
			  ]
			};
		
			
			var chart = new Chartist.Line('.grafico2', data, options);
			
			var resetFnc1;
			function onZoom(chart, reset) {
			  resetFnc1 = reset;
			}
			
			var btn1 = document.createElement('button');
			btn1.id = 'reset-zoom-btn1';
			btn1.innerHTML = 'Reset Zoom';
			btn1.style.float = 'right';
			btn1.addEventListener('click', function() {
			  console.log(resetFnc1);
			  resetFnc1 && resetFnc1();
			});
			var parent = document.querySelector('.grafico2');
			!parent.querySelector('#reset-zoom-btn') && parent.appendChild(btn1);
			
		}
	</script>
	
	
	
	<c:if test="${grafico3 != null}">
		<script type="text/javascript">
			function grafico3() 
			{
				var data =
				{
				  series: 
				  [
				    {
				      name: 'Grafico-2',
				      data: 
				      [
				    	 <c:forEach items="${grafico3}" var="linha">
				    	 	{x: ${linha[0]}, y: ${linha[1]}
				         </c:forEach>				    	  
				      ]
				    }
				  ]
				};
				
				var options = 
				{
				  axisX: 
				  {
				    type: Chartist.AutoScaleAxis,
				    scaleMinSpace: 100,
				  },
				  plugins: 
				  [
					  Chartist.plugins.zoom({ onZoom: onZoom })
				  ]
				};
					
					
				var chart = new Chartist.Line('.grafico2', data, options);
				
				var resetFnc;
				function onZoom(chart, reset) {
				  resetFnc = reset;
				}
				
				var btn2 = document.createElement('button');
				btn2.id = 'reset-zoom-btn2';
				btn2.innerHTML = 'Reset Zoom';
				btn2.style.float = 'right';
				btn2.addEventListener('click', function() {
				  console.log(resetFnc);
				  resetFnc && resetFnc();
				});
				var parent = document.querySelector('.grafico2');
				!parent.querySelector('#reset-zoom-btn2') && parent.appendChild(btn2);
				
			}
		</script>
	</c:if>
	
	
	<script type="text/javascript">
			function init()
			{
				grafico();

				<c:if test="${grafico2 != null}">
					grafico2();
				</c:if>
				
				<c:if test="${grafico3 != null}">
					grafico3();
				</c:if>
			}
	</script>
</c:if>


<script type="text/javascript">
	jQuery(document).ready(
	function(){    
  		jQuery("#allPointsList").chosen();     
  	});
</script>

<fieldset>
	<h3>Selecione uma função:</h3>
	<form action="funcoes.shtm" method="post">
	
		<select name="funcao">
			<option value="1" <c:if test="${resposta[0] == '1'}"> selected </c:if> >Gráfico</option>
			<option value="2" <c:if test="${resposta[0] == '2'}"> selected </c:if> >Gráfico - Média</option>
			<option value="3" <c:if test="${resposta[0] == '3'}"> selected </c:if> >Gráfico - Mediana</option>
			<option value="4" <c:if test="${resposta[0] == '4'}"> selected </c:if> >FFT</option>
			<option value="5" <c:if test="${resposta[0] == '5'}"> selected </c:if> >FFT - Média</option>
			<option value="6" <c:if test="${resposta[0] == '6'}"> selected </c:if> >FFT - Mediana</option>
		</select>
		Janela:
		<input type="text" name="janela" value="${resposta[5]}">
		
	<h3>Selecione um Data Point:</h3>
	
		<c:if test="${select != null}">
			<select id="allPointsList" name="datapoint">
				<c:forEach items="${select}" var="linha">
					<option value="${linha[0]}" <c:if test="${resposta[1] == linha[0]}"> selected </c:if> >
						${linha[2]} - ${linha[1]}</option>
				</c:forEach>
			</select>
		</c:if>
	<br>
	<h3>Selecione uma faixa de tempo:</h3>
		<input type="radio" name="tipo" value="1" <c:if test="${resposta[2] == '0'}"> checked </c:if>
		<c:if test="${resposta[2] == '1'}"> checked </c:if> > Especificar tempo de agora
		
		<input type="radio" name="tipo" value="2" <c:if test="${resposta[2] == '2'}"> checked </c:if>>
		   Especificar tempo a partir do último dado<br>
		   
		<br>
			<div style="padding-left:3em">
				<input type="text" name="valortempo" value="${resposta[3]}">
				<select name="selecttempo">
					<option value="1">Minuto(s)</option>
					<option value="2">Hora(s)</option>
					<option value="3" selected>Dia(s)</option>
					<option value="4">Semana(s)</option>
					<option value="5">Mês(es)</option>
					<option value="6">Ano(s)</option>
				</select>
			</div>
		<br>
		<input type="radio" name="tipo" value="3" <c:if test="${resposta[2] == '3'}"> checked </c:if>>
		   Especificar datas<br>
		<br>
			<div style="padding-left:3em">
				<table>
					<tr>
						<th></th>
						<th>Dia</th>
						<th>Mês</th>
						<th>Ano</th>
						<th>Hora</th>
						<th>Minuto</th>
						<th></th>
					</tr>	
					<tr>
						<td>Início em:</td>
						<td>
							<select name="diainicio">
								<c:forEach var="i" begin="1" end="31" step="1">
									<c:if test="${i eq dia}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne dia}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="mesinicio">
								<c:forEach var="i" begin="1" end="12" step="1">
									<c:if test="${i eq mes}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne mes}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="anoinicio">
								
								<c:forEach var="i" begin="2000" end="${ano}" step="1">
									<c:if test="${i eq ano}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne ano}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="horainicio">
								<c:forEach var="i" begin="0" end="23" step="1">
									<c:if test="${i eq hora}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne hora}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="minutoinicio">
								<c:forEach var="i" begin="0" end="59" step="1">
									<c:if test="${i eq minuto}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne minuto}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<input type="checkbox" name="inicio" value="1">Desde primeiro ponto<br>
						</td>
					</tr>
					
					<tr>
						<td>Finalizar em:</td>
						<td>
							<select name="diafim">
								<c:forEach var="i" begin="1" end="31" step="1">
									<c:if test="${i eq dia}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne dia}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="mesfim">
								<c:forEach var="i" begin="1" end="12" step="1">
									<c:if test="${i eq mes}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne mes}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="anofim">
								
								<c:forEach var="i" begin="2000" end="${ano}" step="1">
									<c:if test="${i eq ano}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne ano}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="horafim">
								<c:forEach var="i" begin="0" end="23" step="1">
									<c:if test="${i eq hora}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne hora}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<select name="minutofim">
								<c:forEach var="i" begin="0" end="59" step="1">
									<c:if test="${i eq minuto}">
										<option value="${i}" selected>${i}</option>
									</c:if>
									<c:if test="${i ne minuto}">
										<option value="${i}">${i}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<td>
							<input type="checkbox" name="fim" value="1">Até último ponto<br>
						</td>
					</tr>
					
				</table>
			</div>
			<input type="submit" value="Gerar" name="gerar">
	</form>
</fieldset>

<c:if test="${grafico != null}">
	<fieldset>
			<div class="ct-chart grafico" style="width: 800px; height: 400px;" ></div>
	</fieldset>
</c:if>

<c:if test="${grafico2 != null}">
	<fieldset>
			<div class="ct-chart grafico2" style="width: 800px; height: 400px;" ></div>
	</fieldset>
</c:if>

<c:if test="${grafico3 != null}">
	<fieldset>
			<div class="ct-chart grafico2" style="width: 800px; height: 400px;" ></div>
	</fieldset>
</c:if>

</tag:page>