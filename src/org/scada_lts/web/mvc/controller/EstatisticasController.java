package org.scada_lts.web.mvc.controller;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.serotonin.mango.vo.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.scada_lts.web.mvc.form.GraficosForm;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.ParameterizableViewController;
import org.springframework.web.util.WebUtils;

import com.serotonin.db.spring.ConnectionCallbackVoid;
import com.serotonin.mango.Common;
import com.serotonin.mango.db.DatabaseAccess;
import com.serotonin.mango.db.dao.DataPointDao;
import com.serotonin.mango.db.dao.UserDao;
import com.serotonin.mango.vo.DataPointNameComparator;
import com.serotonin.mango.vo.DataPointVO;
import com.serotonin.mango.vo.dataSource.DataSourceVO;
import com.serotonin.mango.vo.dataSource.modbus.ModbusIpDataSourceVO;
import com.serotonin.mango.vo.dataSource.modbus.ModbusPointLocatorVO;
import com.serotonin.mango.vo.permission.Permissions;
import com.serotonin.mango.web.dwr.UsersDwr;

@Controller
@RequestMapping("/estatisticas.shtm") 
public class EstatisticasController extends ParameterizableViewController
{
	//private static final Log LOG = LogFactory.getLog(EstatisticasController.class);
	
	@RequestMapping(method = RequestMethod.GET)
	protected ModelAndView inicial(HttpServletRequest request)
			throws Exception 
	{
		Permissions.ensureAdmin(request);
		
		return new ModelAndView("estatisticas");
	}
	
	
	@RequestMapping(method = RequestMethod.POST)
	protected ModelAndView executaRequisicao(HttpServletRequest request,
			HttpServletResponse response) throws Exception 
	{
		Permissions.ensureAdmin(request);
		Map<String, List> resposta = new HashMap<String, List>(); 
		
		if (WebUtils.hasSubmitParameter(request, "gerar"))
		{
			executaComando(request.getParameter("tipo"), resposta);
		}
		
		return new ModelAndView("estatisticas", resposta);
	}
	
	private void executaComando (String comando, Map<String,List> resposta)
	{
		switch(comando)
		{
			case "1": retornaUsuarios(resposta); break;
		}
		
		retornaLista("selecionado", comando, resposta);
	}
	
	private void retornaUsuarios(Map<String,List> resposta)
	{
		UserDao userDAO = new UserDao();
		
		List<String> username = new ArrayList<String>();
		List<String> telefone = new ArrayList<String>();
		List<String> email = new ArrayList<String>();
		List<String> admin = new ArrayList<String>();
		
		int adminNum = 0;
		int outrosNum = 0;
		
		for(User usuario : userDAO.getUsers())
		{
			username.add(usuario.getUsername());
			telefone.add(usuario.getPhone());
			email.add(usuario.getEmail());
			if(usuario.isAdmin())
			{
				admin.add("Y");
				adminNum++;
			}
			else
			{
				admin.add("N");
				outrosNum++;
			}	
		}
				
		List<String> tabela = new ArrayList<String>();
		tabela.add("4");
		tabela.add("Username");
		tabela.add("Telefone");
		tabela.add("E-mail");
		tabela.add("Admin");
		resposta.put("tabela", tabela);
		
		retornaLista("tamanhoTabela", Integer.toString(username.size()), resposta);
		resposta.put("username", username);
		resposta.put("telefone", telefone);
		resposta.put("email", email);
		resposta.put("admin", admin);
		retornaLista("adminNum", Integer.toString(adminNum), resposta);
		retornaLista("outrosNum", Integer.toString(outrosNum), resposta);
	}
	
	/*Função necessária para adicionar quando é somente uma string
	* Uma vez que a reposta só aceita List 
	*/
	public void retornaLista (String nome, String valor, Map<String,List> resposta)
	{
		List<String> lista = new ArrayList<String>();
		lista.add(valor);
		resposta.put(nome, lista);
	}
	
	
}