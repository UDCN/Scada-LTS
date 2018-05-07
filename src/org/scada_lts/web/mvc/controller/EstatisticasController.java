package org.scada_lts.web.mvc.controller;

import java.sql.ResultSet;
import java.sql.SQLException;
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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.scada_lts.dao.DAO;
import org.scada_lts.dao.DataSourceDAO;
import org.scada_lts.dao.SerializationData;
import org.scada_lts.dao.ViewDAO;
import org.scada_lts.dao.event.EventDAO;
import org.scada_lts.dao.watchlist.WatchListDAO;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Controller;
import org.springframework.util.Assert;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.ParameterizableViewController;
import org.springframework.web.util.WebUtils;

import com.serotonin.mango.Common;
import com.serotonin.mango.db.dao.DataPointDao;
import com.serotonin.mango.db.dao.DataSourceDao;
import com.serotonin.mango.db.dao.UserDao;
import com.serotonin.mango.rt.RuntimeManager;
import com.serotonin.mango.rt.dataSource.DataSourceRT;
import com.serotonin.mango.rt.event.EventInstance;
import com.serotonin.mango.vo.DataPointNameComparator;
import com.serotonin.mango.vo.DataPointVO;
import com.serotonin.mango.vo.dataSource.DataSourceVO;
import com.serotonin.mango.vo.dataSource.modbus.ModbusIpDataSourceVO;
import com.serotonin.mango.vo.dataSource.modbus.ModbusPointLocatorVO;
import com.serotonin.mango.vo.permission.Permissions;
/*
 * RETORNA OS GRÁFICOS E TABELAS DO SISTEMA
 * ---------------------------------------
 * PARA GERAR TABELA, OS HEADERS DEVE TER
 * [0] - CONTER A QUANTIDADE DE HEADERS
 * [1...] - CONTER OS NOMES DO HEADERS
 */

import br.org.scadabr.vo.scripting.ScriptVO;

@Controller
@RequestMapping("/estatisticas.shtm") 
public class EstatisticasController extends ParameterizableViewController
{
	//RowMapper
	private class EstatisticaRowMapper implements RowMapper<String> {
		public String mapRow(ResultSet rs, int rowNum) throws SQLException {
			String dados;
            dados = rs.getString("xid");
			return dados;
		}
	}
	
	private static final Log LOG = LogFactory.getLog(EstatisticasController.class);
	
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
			executaComando(request.getParameter("tipo"), resposta, request);
		}
		
		return new ModelAndView("estatisticas", resposta);
	}
	
	private void executaComando (String comando, Map<String,List> resposta, 
			HttpServletRequest request)
	{
		switch(comando)
		{
			case "1": retornaUsuarios(resposta); break;
			case "2": representacoesGraficas(resposta); break;
			case "3": dataPointsWatchList(resposta); break;
			case "4": dataSoucesEstados(resposta); break;
			case "5": dataPointsEstados(resposta); break;
			case "6": dataSourcesPadrao(resposta); break;
			case "7": dataSoucePortaHost(resposta); break;
			case "8": tabelaModem(resposta); break;
			case "9": tabelaModbus(resposta); break;
			case "10": contaErroDataSource(resposta); break;
			case "11": dataSourcesDesabitilados(resposta, request); break;
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
		
		retornaLista("tamanhoGrafico", Integer.toString(1), resposta);
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
			int pontos = watchLists.getPointsWatchList(watchList.getId()).size();
			numPoints.set(posicao, numPoints.get(posicao) + pontos);
		}
		
		//Retorna a resposta para criar o gráfico
		List<String> nomes = new ArrayList<String>();
		List<String> quantidadesWL = new ArrayList<String>();
		List<String> quantidadesPO = new ArrayList<String>();
		for (int i = 0; i < usuariosIds.size(); i++)
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
	
	/*
	 * RETORNA A QUANTIDADE DE DATASOURCES
	 * HABILITADOS OU DESABILITADOS
	 */
	
	public void dataSoucesEstados(Map<String,List> resposta)
	{
		
		DataSourceDAO dataSources = new DataSourceDAO();
		
		int habilitado = 0;
		int desabilitado = 0;
		
		for (DataSourceVO ds : dataSources.getDataSources())
		{
			if (ds.isEnabled())
				habilitado++;
			else
				desabilitado++;
		}
		
		retornaLista("habilitado", Integer.toString(habilitado), resposta);
		retornaLista("desabilitado", Integer.toString(desabilitado), resposta);
		retornaLista("tamanhoGrafico", Integer.toString(1), resposta);
	}
	
	/*
	 * RETORNA A QUANTIDADE DE DATAPOINTS
	 * HABILITADOS OU DESABILITADOS
	 */
	
	public void dataPointsEstados(Map<String,List> resposta)
	{
		
		DataSourceDAO dataSources = new DataSourceDAO();
		List<DataPointVO> dataPoints = new ArrayList<DataPointVO>();
		DataPointDao dataPointDao = new DataPointDao();
		
		int habilitado = 0;
		int desabilitado = 0;
		
		for (DataSourceVO ds : dataSources.getDataSources())
		{
			dataPoints = dataPointDao.getDataPoints(ds.getId(), DataPointNameComparator.instance);
			for (DataPointVO dataPoint : dataPoints)
        	{
        		if(dataPoint.isEnabled())
            	{
        			habilitado++;
            	}
            	else
            	{
            		desabilitado++;
            	}
            	
        	}
		}
		
		retornaLista("habilitado", Integer.toString(habilitado), resposta);
		retornaLista("desabilitado", Integer.toString(desabilitado), resposta);
		retornaLista("tamanhoGrafico", Integer.toString(1), resposta);
	}
	
	/*
	 * INFORMAÇÕES DE DATA SOURCE (FORA DE PADRÃO)
	 * RETORNA AS INFORMAÇÕES QUE ESTÃO FORA DO PADRÃO PRÉ-ESTABELECIDO
	 * SOMENTE RETORNA SE FOR MODBUSIP E QUE ESTIVEREM TOTALMENTE FORA DO PADRÃO
	 */
	
	public void dataSourcesPadrao(Map<String,List> resposta)
	{
		String MODBUS_IP = "dsEdit.modbusIp";
		int MINUTES = 2;
		int idCount = 1;
		List<DataSourceVO<?>> dataS = Common.ctx.getRuntimeManager().getDataSources();
		String[] medidasTempo = {"SECONDS", "MINUTES", "HOURS", "DAYS", "WEEKS",
				"MONTHS", "YEARS", "MILLISECONDS"};
		
		
		List<String> id = new ArrayList<String>();
		List<String> Xid = new ArrayList<String>();
		List<String> nome = new ArrayList<String>();
		List<String> resultadoLst = new ArrayList<String>();
		 
		for (DataSourceVO<?> ds : dataS) 
        {
			String resultado = "";
			if(ds.getType().getKey().equals(MODBUS_IP))
			{
				ModbusIpDataSourceVO dataSourceModbusIP = (ModbusIpDataSourceVO) Common
						.ctx.getRuntimeManager().getDataSource(ds.getId());
				
				if(dataSourceModbusIP.getUpdatePeriodType() != MINUTES) 
					resultado = resultado.concat("updatePeriodType: " + 
										medidasTempo[dataSourceModbusIP.getUpdatePeriodType()-1] + "; ");
				
				if(!dataSourceModbusIP.getTransportType().getKey().equals("dsEdit.modbusIp.transportType.tcpKA"))
					resultado = resultado.concat("transportType: " + 
										dataSourceModbusIP.getTransportType().getKey().
										replaceAll("dsEdit.modbusIp.transportType.", "").toUpperCase() + "; ");	
				
				if(dataSourceModbusIP.isContiguousBatches())
					resultado = resultado.concat("contiguousBatches: " +
										dataSourceModbusIP.isContiguousBatches() + "; ");
				
				if(dataSourceModbusIP.isCreateSlaveMonitorPoints())
					resultado = resultado.concat("createSlaveMonitorPoints: " +
										dataSourceModbusIP.isCreateSlaveMonitorPoints() + "; ");
			
				if(!dataSourceModbusIP.isEncapsulated())
					resultado = resultado.concat("encapsulated: " +
										dataSourceModbusIP.isEncapsulated() + "; ");

				if(!dataSourceModbusIP.getHost().equals("10.18.0.243"))
					resultado = resultado.concat("host: " +
										dataSourceModbusIP.getHost() + "; ");
				
				if(dataSourceModbusIP.getMaxReadBitCount() != 2000)
					resultado = resultado.concat("maxReadBitCount: " +
										dataSourceModbusIP.getMaxReadBitCount() + "; ");
				
				if(dataSourceModbusIP.getMaxReadRegisterCount() != 125)
					resultado = resultado.concat("maxReadRegisterCount: " +
										dataSourceModbusIP.getMaxReadRegisterCount() + "; "); 
				
				if(dataSourceModbusIP.getMaxWriteRegisterCount() != 120)
					resultado = resultado.concat("maxWriteRegisterCount: " +
										dataSourceModbusIP.getMaxWriteRegisterCount() + "; "); 
				
				if(dataSourceModbusIP.isQuantize())
					resultado = resultado.concat("quantize: " +
										dataSourceModbusIP.isQuantize() + "; "); 
				
				if(dataSourceModbusIP.getRetries() != 3)
					resultado = resultado.concat("retries: " +
										dataSourceModbusIP.getRetries() + "; ");
				
				if(dataSourceModbusIP.getTimeout() != 1000)
					resultado = resultado.concat("timeout: " +
										dataSourceModbusIP.getTimeout() + "; ");
				
				if(dataSourceModbusIP.getUpdatePeriods() != 1000)
					resultado = resultado.concat("updatePeriods: " +
										dataSourceModbusIP.getUpdatePeriods() + "; ");
				
				if(!resultado.equals("")) 
				{
					id.add(Integer.toString(idCount));
					Xid.add(dataSourceModbusIP.getXid());
					nome.add(dataSourceModbusIP.getName());
					resultadoLst.add(resultado);
					idCount++;
				}
			}
			
        }
		
		List<String> tabelaHeader = new ArrayList<String>();
		tabelaHeader.add("4");
		tabelaHeader.add("");
		tabelaHeader.add("XID");
		tabelaHeader.add("NOME");
		tabelaHeader.add("RESULTADO");
		resposta.put("tabelaHeader", tabelaHeader);
		
		retornaLista("tamanhoTabela", Integer.toString(id.size()), resposta);
		resposta.put("id", id);
		resposta.put("xid", Xid);
		resposta.put("nome", nome);
		resposta.put("resultado", resultadoLst);
		
	}
	
	
	/*
	 * INFORMAÇÕES DE DATA SOURCE (HOST E PORTA)
	 * RETORNA APENAS DE MODBUS IP
	 */
	
	private void dataSoucePortaHost(Map<String,List> resposta)
	{
		String MODBUS_IP = "dsEdit.modbusIp";
		int idCount = 1;
		List<DataSourceVO<?>> dataS = Common.ctx.getRuntimeManager().getDataSources();
		
		List<String> id = new ArrayList<String>();
		List<String> Xid = new ArrayList<String>();
		List<String> nome = new ArrayList<String>();
		List<String> host = new ArrayList<String>();
		List<String> porta = new ArrayList<String>();
		
		for (DataSourceVO<?> ds : dataS) 
        {
			
			if(ds.getType().getKey().equals(MODBUS_IP))
			{
				ModbusIpDataSourceVO dataSourceModbusIP = (ModbusIpDataSourceVO) Common
						.ctx.getRuntimeManager().getDataSource(ds.getId());
				
					id.add(Integer.toString(idCount));
					Xid.add(dataSourceModbusIP.getXid());
					nome.add(dataSourceModbusIP.getName());
					host.add(dataSourceModbusIP.getHost());
					porta.add(Integer.toString(dataSourceModbusIP.getPort()));
					idCount++;
			}
			
        }
		
		List<String> tabelaHeader = new ArrayList<String>();
		tabelaHeader.add("5");
		tabelaHeader.add("");
		tabelaHeader.add("XID");
		tabelaHeader.add("NOME");
		tabelaHeader.add("HOST");
		tabelaHeader.add("PORTA");
		resposta.put("tabelaHeader", tabelaHeader);
		
		retornaLista("tamanhoTabela", Integer.toString(id.size()), resposta);
		resposta.put("id", id);
		resposta.put("xid", Xid);
		resposta.put("nome", nome);
		resposta.put("host", host);
		resposta.put("porta", porta);
            	
	}
	
	
	/*
	 * INFORMAÇÕES DE DATA POINT DOS MODEMS
	 * RETORNA OS OFFSETS
	 * RETORNA APENAS O MODBUSIP
	 */
	
	private void tabelaModem(Map<String,List> resposta)
	{
		String MODBUS_IP = "dsEdit.modbusIp";
		List<DataSourceVO<?>> dataS = Common.ctx.getRuntimeManager().getDataSources();
		
		DataPointDao dataPointDao = new DataPointDao();
		List<DataPointVO> dataPoints = new ArrayList<DataPointVO>();
		
		List<List<String>> data = new ArrayList<List<String>>();
		
		List<String> row;
		
		int countId = 1;
		
        for (DataSourceVO<?> ds : dataS) 
        {
        	if(ds.getType().getKey().equals(MODBUS_IP))
			{
        		row = new ArrayList<String>(Collections.nCopies(15, ""));
        		
        		row.set(0,Integer.toString(countId));
        		row.set(1,ds.getXid());
        		row.set(2,ds.getName());
        		
        		dataPoints = dataPointDao.getDataPoints(ds.getId(), DataPointNameComparator.instance);
        		
        		for (DataPointVO dataPoint : dataPoints)
        		{
        			ModbusPointLocatorVO dataPointModbusIP = (ModbusPointLocatorVO) 
        					dataPoint.getPointLocator();    			
        			
        			if(dataPointModbusIP.getOffset() == 64101)
        			{
        				if(dataPointModbusIP.getBit() == 0) row.set(3, dataPoint.getName());
        				if(dataPointModbusIP.getBit() == 1) row.set(4, dataPoint.getName());
        				if(dataPointModbusIP.getBit() == 2) row.set(5, dataPoint.getName());
        				if(dataPointModbusIP.getBit() == 3) row.set(6, dataPoint.getName());
        				if(dataPointModbusIP.getBit() == 4) row.set(7, dataPoint.getName());
        				if(dataPointModbusIP.getBit() == 5) row.set(8, dataPoint.getName());
        				if(dataPointModbusIP.getBit() == 6) row.set(9, dataPoint.getName());
        				if(dataPointModbusIP.getBit() == 7) row.set(10, dataPoint.getName());
        			}
        			if(dataPointModbusIP.getOffset() == 64103) row.set(11, dataPoint.getName());
        			if(dataPointModbusIP.getOffset() == 64104) row.set(12, dataPoint.getName());
        			if(dataPointModbusIP.getOffset() == 64105) row.set(13, dataPoint.getName());
        			if(dataPointModbusIP.getOffset() == 64106) row.set(14, dataPoint.getName());
        		}
        		data.add(row);
			}
        }
        
        
        List<String> id = new ArrayList<String>();
		List<String> xid = new ArrayList<String>();
		List<String> nome = new ArrayList<String>();
		List<String> B0 = new ArrayList<String>();
		List<String> B1 = new ArrayList<String>();
		List<String> B2 = new ArrayList<String>();
		List<String> B3 = new ArrayList<String>();
		List<String> B4 = new ArrayList<String>();
		List<String> B5 = new ArrayList<String>();
		List<String> B6 = new ArrayList<String>();
		List<String> B7 = new ArrayList<String>();
		List<String> B03 = new ArrayList<String>();
		List<String> B04 = new ArrayList<String>();
		List<String> B05 = new ArrayList<String>();
		List<String> B06 = new ArrayList<String>();
		
        
        //Transformando para listas com elementos
        for (List<String> lista : data)
        {
        	id.add(lista.get(0));
        	xid.add(lista.get(1));
        	nome.add(lista.get(2));
        	B0.add(lista.get(3));
        	B1.add(lista.get(4));
        	B2.add(lista.get(5));
        	B3.add(lista.get(6));
        	B4.add(lista.get(7));
        	B5.add(lista.get(8));
        	B6.add(lista.get(9));
        	B7.add(lista.get(10));
        	B03.add(lista.get(11));
        	B04.add(lista.get(12));
        	B05.add(lista.get(13));
        	B06.add(lista.get(14));
        }
        
        List<String> tabelaHeader = new ArrayList<String>();
        tabelaHeader.add("15");
        tabelaHeader.add("");
        tabelaHeader.add("XID");
        tabelaHeader.add("NOME - DATASOURCE");
        tabelaHeader.add("64101/0");
        tabelaHeader.add("64101/1");
        tabelaHeader.add("64101/2");
        tabelaHeader.add("64101/3");
        tabelaHeader.add("64101/4");
        tabelaHeader.add("64101/5");
        tabelaHeader.add("64101/6");
        tabelaHeader.add("64101/7");
        tabelaHeader.add("64103");
        tabelaHeader.add("64104");
        tabelaHeader.add("64105");
        tabelaHeader.add("64106");
        
        resposta.put("tabelaHeader", tabelaHeader);
        
        retornaLista("tamanhoTabela", Integer.toString(id.size()), resposta);
        
        resposta.put("id", id);
        resposta.put("xid", xid);
        resposta.put("nome", nome);
        resposta.put("B0", B0);
        resposta.put("B1", B1);
        resposta.put("B2", B2);
        resposta.put("B3", B3);
        resposta.put("B4", B4);
        resposta.put("B5", B5);
        resposta.put("B6", B6);
        resposta.put("B7", B7);
        resposta.put("B03", B03);
        resposta.put("B04", B04);
        resposta.put("B05", B05);
        resposta.put("B06", B06);
        
	}
	
	
	/*
	 * INFORMAÇÕES DE DATA POINT DOS MODEMS
	 * RETORNA OS OFFSETS
	 * RETORNA APENAS DO MODBUSIP
	 */
	
	private void tabelaModbus(Map<String,List> resposta)
	{
		String MODBUS_IP = "dsEdit.modbusIp";
		List<DataSourceVO<?>> dataS = Common.ctx.getRuntimeManager().getDataSources();
		
		DataPointDao dataPointDao = new DataPointDao();
		List<DataPointVO> dataPoints = new ArrayList<DataPointVO>();
		
		List<List<String>> data = new ArrayList<List<String>>();
		List<String> row;
		
		int countId = 1;
		
        for (DataSourceVO<?> ds : dataS) 
        {
        	if(ds.getType().getKey().equals(MODBUS_IP))
			{
        		row = new ArrayList<String>(Collections.nCopies(16, ""));
        		
        		row.set(0,Integer.toString(countId));
        		row.set(1,ds.getName());
        		
        		dataPoints = dataPointDao.getDataPoints(ds.getId(), DataPointNameComparator.instance);
        		
        		for (DataPointVO dataPoint : dataPoints)
        		{
        			ModbusPointLocatorVO dataPointModbusIP = (ModbusPointLocatorVO) 
        					dataPoint.getPointLocator();    			
        			
        			
        			if(dataPointModbusIP.getSlaveId() == 1) row.set(2, dataPoint.getName().
        						concat(", " + row.get(2).toString()));
                    if(dataPointModbusIP.getSlaveId() == 2) row.set(3, dataPoint.getName().
                    			concat(", " + row.get(3).toString()));
                    if(dataPointModbusIP.getSlaveId() == 4) row.set(4, dataPoint.getName().
                    			concat(", " + row.get(4).toString()));
                    if(dataPointModbusIP.getSlaveId() == 5) row.set(5, dataPoint.getName().
                    			concat(", " + row.get(5).toString()));
                    if(dataPointModbusIP.getSlaveId() == 6) row.set(6, dataPoint.getName().
                    			concat(", " + row.get(6).toString()));
                    if(dataPointModbusIP.getSlaveId() == 7) row.set(7, dataPoint.getName().
                    			concat(", " + row.get(7).toString()));
                    if(dataPointModbusIP.getSlaveId() == 8) row.set(8, dataPoint.getName().
                    			concat(", " + row.get(8).toString()));
                    if(dataPointModbusIP.getSlaveId() == 9) row.set(9, dataPoint.getName().
                    			concat(", " + row.get(9).toString()));
                    if(dataPointModbusIP.getSlaveId() == 10) row.set(10, dataPoint.getName().
                    			concat(", " + row.get(10).toString()));
                    if(dataPointModbusIP.getSlaveId() == 11) row.set(11, dataPoint.getName().
                    			concat(", " + row.get(11).toString()));
                    if(dataPointModbusIP.getSlaveId() == 54) row.set(12, dataPoint.getName().
                    			concat(", " + row.get(12).toString()));
                    if(dataPointModbusIP.getSlaveId() == 88) row.set(13, dataPoint.getName().
                    			concat(", " + row.get(13).toString()));
                    if(dataPointModbusIP.getSlaveId() == 100) row.set(14, dataPoint.getName().
                    			concat(", " + row.get(14).toString()));
                    if(dataPointModbusIP.getSlaveId() == 101) row.set(15, dataPoint.getName().
                    			concat(", " + row.get(15).toString()));
        				
        				
        		}
        		data.add(row);
        		countId++;
			}
        }
        
        
        List<String> id = new ArrayList<String>();
		List<String> nome = new ArrayList<String>();
		List<String> B1 = new ArrayList<String>();
		List<String> B2 = new ArrayList<String>();
		List<String> B4 = new ArrayList<String>();
		List<String> B5 = new ArrayList<String>();
		List<String> B6 = new ArrayList<String>();
		List<String> B7 = new ArrayList<String>();
		List<String> B8 = new ArrayList<String>();
		List<String> B9 = new ArrayList<String>();
		List<String> B10 = new ArrayList<String>();
		List<String> B11 = new ArrayList<String>();
		List<String> B54 = new ArrayList<String>();
		List<String> B88 = new ArrayList<String>();
		List<String> B100 = new ArrayList<String>();
		List<String> B101 = new ArrayList<String>();
		
        
        //Transformando para listas com elementos
        for (List<String> lista : data)
        {
        	id.add(lista.get(0));
        	nome.add(lista.get(1));
        	B1.add(lista.get(2));
        	B2.add(lista.get(3));
        	B4.add(lista.get(4));
        	B5.add(lista.get(5));
        	B6.add(lista.get(6));
        	B7.add(lista.get(7));
        	B8.add(lista.get(8));
        	B9.add(lista.get(9));
        	B10.add(lista.get(10));
        	B11.add(lista.get(11));
        	B54.add(lista.get(12));
        	B88.add(lista.get(13));
        	B100.add(lista.get(14));
        	B101.add(lista.get(15));
        }
        
        
        List<String> tabelaHeader = new ArrayList<String>();
        tabelaHeader.add("16");
        tabelaHeader.add("ID");
        tabelaHeader.add("NOME - DATASOURCE");
        tabelaHeader.add("1");
        tabelaHeader.add("2");
        tabelaHeader.add("4");
        tabelaHeader.add("5");
        tabelaHeader.add("6");
        tabelaHeader.add("7");
        tabelaHeader.add("8");
        tabelaHeader.add("9");
        tabelaHeader.add("10");
        tabelaHeader.add("11");
        tabelaHeader.add("54");
        tabelaHeader.add("88");
        tabelaHeader.add("100");
        tabelaHeader.add("101");
        
        resposta.put("tabelaHeader", tabelaHeader);
        
        retornaLista("tamanhoTabela", Integer.toString(id.size()), resposta);
        
        resposta.put("id", id);
        resposta.put("nome", nome);
        resposta.put("B1", B1);
        resposta.put("B2", B2);
        resposta.put("B4", B4);
        resposta.put("B5", B5);
        resposta.put("B6", B6);
        resposta.put("B7", B7);
        resposta.put("B8", B8);
        resposta.put("B9", B9);
        resposta.put("B10", B10);
        resposta.put("B11", B11);
        resposta.put("B54", B54);
        resposta.put("B88", B88);
        resposta.put("B100", B100);
        resposta.put("B101", B101);
		
	}
	
	public void contaErroDataSource (Map<String,List> resposta)
	{
		DataSourceDao dataSourceDao = new DataSourceDao();
		
		//List<DataSourceVO<?>> dataS = Common.ctx.getRuntimeManager().getDataSources();
		
		List<DataSourceVO<?>> dataS = dataSourceDao.getDataSources();
		
		List<List<String>> data = new ArrayList<List<String>>();
		List<String> row;
		EventDAO eventDao = new EventDAO();
		
		for (DataSourceVO<?> ds : dataS) 
        {
			row = new ArrayList<String>();
			
			//Type 3 é DataSource; O TypeRef=1 é o ID do DS
			List<EventInstance> eventos = eventDao.filtered("typeId=? AND typeRef1=?", 
					new Object[]{3, ds.getId()}, 0);
			int tamanho = eventos.size(); 
					
			if (tamanho > 0)
			{
				row.add(Integer.toString(ds.getId()));
				row.add(ds.getName());
				row.add(Integer.toString(tamanho));
				row.add(ds.getXid());
				data.add(row);
			}
			
        }
		
		data.sort(new Comparator<List<String>>()
		{
			@Override
			public int compare(List<String> o1, List<String> o2) {
				return -o1.get(2).compareTo(o2.get(2));
			}
		});
		
		List<String> nome = new ArrayList<String>();
		List<String> id = new ArrayList<String>();
		List<String> numErros = new ArrayList<String>();
		List<String> xid = new ArrayList<String>();
		
		//Transformando para listas com elementos
        for (List<String> lista : data)
        {
        	id.add(lista.get(0));
        	nome.add(lista.get(1));
        	numErros.add(lista.get(2));
        	xid.add(lista.get(3));
        }
		

        List<String> tabelaHeader = new ArrayList<String>();
        tabelaHeader.add("3");
        tabelaHeader.add("XID");
        tabelaHeader.add("NOME");
        tabelaHeader.add("NÚMERO DE ERROS");
        
        resposta.put("tabelaHeader", tabelaHeader);
        
        retornaLista("tamanhoTabela", Integer.toString(nome.size()), resposta);
        
        resposta.put("id", id);
        resposta.put("nome", nome);
        resposta.put("erros", numErros);
        resposta.put("xid", xid);
	}
	
	
	/*
	 * Lista os Data Sources que não foram habilitados na inicialização
	 */
	public void dataSourcesDesabitilados(Map<String,List> resposta, HttpServletRequest request)
	{
		
		if (WebUtils.hasSubmitParameter(request, "habilitar"))
		{
			iniciaDS(request.getParameter("habilitar"), resposta);
		}
		
		List<String> xids;
		xids = (List<String>) DAO.getInstance().getJdbcTemp().query("SELECT * FROM desativados", 
				new Object [] {}, new EstatisticaRowMapper());
		
		List<String> nome = new ArrayList<String>();
		
		DataSourceDao dataSourceDao = new DataSourceDao();
		for(String xid : xids)
		{
			DataSourceVO<?> ds;
			ds = dataSourceDao.getDataSource(xid);
			nome.add(ds.getName());
		}
		
		List<String> tabelaHeader = new ArrayList<String>();
        tabelaHeader.add("3");
        tabelaHeader.add("XID");
        tabelaHeader.add("NOME");
        tabelaHeader.add("LINK");
        
        resposta.put("tabelaHeader", tabelaHeader);
        
        retornaLista("tamanhoTabela", Integer.toString(nome.size()), resposta);
        
        resposta.put("xid", xids);
        resposta.put("nome", nome);
		
	}
	
	
	/* ----------------------------------------------------------------------------------------- */
	
	
	synchronized public void iniciaDS(String xid, Map<String,List> resposta)
	{
		
		RuntimeManager runtimeManager = Common.ctx.getRuntimeManager();
		DataSourceVO<?> ds = new DataSourceDao().getDataSource(xid);
		LOG.info(ds.getName());
		if (ds != null) 
		{
			Permissions.ensureDataSourcePermission(Common.getUser(), ds
					.getId());
			ds.setEnabled(true);
			runtimeManager.saveDataSource(ds);
			
			//Assert.isTrue(ds.isEnabled());
			//Cria o data source RT
			DataSourceRT dataSourceRT = ds.createDataSourceRT();
			
			dataSourceRT.initialize();
			
			//Verifica se inicializou
			int tentativas = 0;
			for(tentativas = 0; tentativas < 4; tentativas++)
			{
				//Se não conectou
				if(!dataSourceRT.getConnected())
				{
					//Escreve no Log
					try {
						//Delay progressivo a cada tentativa
						Thread.currentThread();
						Thread.sleep(Integer.toUnsignedLong( (tentativas + 1) * 499 ));
	     				//this.wait( Integer.toUnsignedLong( (tentativas + 1) * 499 ));
					} catch (InterruptedException e) {
					}
				}
				//Se conseguiu a conexão, sai do loop
				else
				{
					break;
				}
					
			}
			//Se as tentativas excederam 3, desabilita o DS e retorna o erro de habilitar
			if (tentativas >= 3)
			{
				ds.setEnabled(false);
				runtimeManager.saveDataSource(ds);
				
				//Retira o data source do RT
				dataSourceRT.terminate();
				
				//Insere o DataSource a tabela desativado
				try
				{
					DAO.getInstance().getJdbcTemp().update("INSERT INTO desativados (xid) VALUES (?)", 
							new Object[] {ds.getXid()});
				}catch(Exception e) {
					retornaLista("erro", "Erro ao habilitar Data Point.", resposta);
				}
						
				
				return;
			}
			
			
			//Se conseguiu conectar
			
			//Retira o DataSource dos pontos que foram desativados
			DAO.getInstance().getJdbcTemp().update("DELETE FROM desativados WHERE xid=?", 
					new Object[] {ds.getXid()});
			//Adiciona o Data Source na RT
			dataSourceRT.beginPolling();
		}
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