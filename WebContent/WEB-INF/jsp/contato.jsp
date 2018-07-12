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

<form action="contato.shtm"  method="post" class="borderDiv form-group centerForm" style="margin-left:25%;">

	<div class="smallTitle titlePadding" style="float:left;">
      <img class="ptr" src="images/email.png" alt="Alarms" title="Alarms" border="0">
      CONTATO
    </div>
    
			<input type="text" name="nome" id="nome" 
			class="form-control" placeholder="Nome" style="width: 93%;" required/>
			
		    <input type="email" name="email" id="email" 
		    class="form-control" placeholder="Email"  style="width: 93%;" required/>
	
	    	<input type="text" name="telefone" id="telefone" 
	    	class="form-control" placeholder="Telefone"  style="width: 93%;" required/>
	    	
	    	<input type="text" name="setor" id="setor" 
	    	class="form-control" placeholder="Setor"  style="width: 93%;" required/>

			<input type="text" name="assunto" id="assunto" 
			class="form-control" placeholder="Assunto"  style="width: 93%;" required/>

			<textarea name="mensagem" id="mensagem" 
			class="form-control" placeholder="Mensagem" style="width: 93%;" required></textarea>

			<input id="submit" name="submit" type="submit" value="Enviar Mensagem"/>


	<c:if test="${resposta != null}">
		${resposta}
	</c:if>

</form>


	
</tag:page>