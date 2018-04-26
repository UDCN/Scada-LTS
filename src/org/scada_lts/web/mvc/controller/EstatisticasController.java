package org.scada_lts.web.mvc.controller;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.serotonin.mango.vo.User;
import com.serotonin.mango.vo.WatchList;
import com.serotonin.mango.view.View;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.scada_lts.dao.DataSourceDAO;
import org.scada_lts.dao.ViewDAO;
import org.scada_lts.dao.watchlist.WatchListDAO;
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

/*
 * RETORNA OS GRÁFICOS E TABELAS DO SISTEMA
 * ---------------------------------------
 * PARA GERAR TABELA, OS HEADERS DEVE TER
 * [0] - CONTER A QUANTIDADE DE HEADERS
 * [1...] - CONTER OS NOMES DO HEADERS
 */

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
			case "2": representacoesGraficas(resposta); break;
			case "3": dataPointsWatchList(resposta); break;
		}
		
		retornaLista("selecionado", comando, resposta);
	}
	
	
	/*
	 * RETORNA A QUANTIDADE DE ADMIN X OUTROS
	 * RETORNA O USERNAME, TELEFONE, E-MAIL E SE É ADMIN
	 */
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
				
		List<String> tabelaHeader = new ArrayList<String>();
		tabelaHeader.add("4");
		tabelaHeader.add("Username");
		tabelaHeader.add("Telefone");
		tabelaHeader.add("E-mail");
		tabelaHeader.add("Admin");
		resposta.put("tabelaHeader", tabelaHeader);
		
		retornaLista("tamanhoTabela", Integer.toString(username.size()), resposta);
		resposta.put("username", username);
		resposta.put("telefone", telefone);
		resposta.put("email", email);
		resposta.put("admin", admin);
		retornaLista("adminNum", Integer.toString(adminNum), resposta);
		retornaLista("outrosNum", Integer.toString(outrosNum), resposta);
	}
	
	/*
	 * FUNÇÃO QUE RETORNA A QUANTIDADE DE REPRESENTAÇÕES GRÁFICAS (VIEWS)
	 * POR CADA USUÁRIO.
	 */
	
	public void representacoesGraficas(Map<String,List> resposta)
	{
		//Lista todos os usuários
		UserDao userDAO = new UserDao();
		List<Integer> usuariosIds = new ArrayList<Integer>();
		List<String> usuariosNomes = new ArrayList<String>();
		//Cria uma lista com o ID e Username de todos os usuários
		for(User usuario : userDAO.getUsers())
		{
			usuariosIds.add(usuario.getId());
			usuariosNomes.add(usuario.getUsername());
		}
		
		//Retorna lista com a quantidade de representações por usuário
		ViewDAO representacoes = new ViewDAO();
		List<Integer> numRepresentacoes = 
				new ArrayList<Integer>(Collections.nCopies(usuariosIds.size(), 0)); 
		for (View representacao : representacoes.findAll())
		{
			int posicao = usuariosIds.indexOf(representacao.getUserId());
			numRepresentacoes.set(posicao, numRepresentacoes.get(posicao) + 1);
		}
		
		//Retorna a resposta para criar o gráfico
		List<String> nomes = new ArrayList<String>();
		List<String> quantidades = new ArrayList<String>();
		for (int i = 0; i<= usuariosIds.size()-1; i++)
		{
			if(numRepresentacoes.get(i) > 0)
			{
				nomes.add(usuariosNomes.get(i));
				quantidades.add(Integer.toString(numRepresentacoes.get(i)));
			}
		}
		resposta.put("nomes", nomes);
		resposta.put("quantidades", quantidades);
		retornaLista("tamanhoGrafico", Integer.toString(nomes.size()-1), resposta);
	}
	
	/*
	 * FUNÇÃO QUE RETORNA (POR USUÁRIO)
	 * QUANTIDADE DE WATCHLISTS
	 * QUANTIDADE DE PONTOS POR WATCHLIST
	 */
	public void dataPointsWatchList(Map<String,List> resposta)
	{
		//Lista todos os usuários
		UserDao userDAO = new UserDao();
		List<Integer> usuariosIds = new ArrayList<Integer>();
		List<String> usuariosNomes = new ArrayList<String>();
		//Cria uma lista com o ID e Username de todos os usuários
		for(User usuario : userDAO.getUsers())
		{
			usuariosIds.add(usuario.getId());
			usuariosNomes.add(usuario.getUsername());
		}
		
		//Retorna todos os WatchLists por usuários
		List<Integer> numWatchList = 
				new ArrayList<Integer>(Collections.nCopies(usuariosIds.size(), 0)); 
		List<Integer> numPoints = 
				new ArrayList<Integer>(Collections.nCopies(usuariosIds.size(), 0));
		
		WatchListDAO watchLists = new WatchListDAO();
		
		for(WatchList watchList : watchLists.findAll())
		{
			int posicao = usuariosIds.indexOf(watchList.getUserId());
			numWatchList.set(posicao, numWatchList.get(posicao) + 1);
			//Retorna a quantidade de pontos do WatchList
			int pontos = 0;
			for (DataPointVO point : watchList.getPointList())
			{
				pontos++;
			}
			numPoints.set(posicao, numPoints.get(posicao) + pontos);
		}
		
		//Retorna a resposta para criar o gráfico
		List<String> nomes = new ArrayList<String>();
		List<String> quantidadesWL = new ArrayList<String>();
		List<String> quantidadesPO = new ArrayList<String>();
		for (int i = 0; i<= usuariosIds.size()-1; i++)
		{
			if(numWatchList.get(i) > 0)
			{
				nomes.add(usuariosNomes.get(i));
				quantidadesWL.add(Integer.toString(numWatchList.get(i)));
				quantidadesPO.add(Integer.toString(numPoints.get(i)));
			}
		}
		resposta.put("nomes", nomes);
		resposta.put("quantidadesWL", quantidadesWL);
		resposta.put("quantidadesPO", quantidadesPO);
		retornaLista("tamanhoGrafico", Integer.toString(nomes.size()-1), resposta);
		
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