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

<%--
<tag:page dwr="ListasDwr" onload="init">
--%>

<c:if test="${tabelaHeader != null}">
	<center>
		<h2>ERROS DATA SOURCE</h2>
		<h2>XID: ${xid[0]} - NOME: ${nome[0]}</h2> 


		 <table width="300px" border="1px" bordercolor="#FFFFFF">
	         <tr>
	           <c:forEach var="i" begin="1" end="${tabelaHeader[0]}">
	             <th><c:out value = "${tabelaHeader[i]}"/></th>
	           </c:forEach>
	         </tr>
	    
	    	<c:forEach var="i" begin="0" end="${tamanhoTabela[0] - 1}">
	           <tr>
	           		<td><c:out value = "${id[i]}"/></td>
	             	<td><c:out value = "${mensagem[i]}"/></td>
	           </tr>
	        </c:forEach>
	    
	    </table>
	  
    </center> 
</c:if>

<%--
</tag:page>
--%>