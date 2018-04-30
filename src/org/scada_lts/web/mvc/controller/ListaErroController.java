package org.scada_lts.web.mvc.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.scada_lts.dao.event.EventDAO;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.ParameterizableViewController;

import com.serotonin.mango.Common;
import com.serotonin.mango.db.dao.DataSourceDao;
import com.serotonin.mango.rt.event.EventInstance;
import com.serotonin.mango.vo.dataSource.DataSourceVO;
import com.serotonin.mango.vo.permission.Permissions;

@Controller
@RequestMapping("/lista_erro.shtm") 
public class ListaErroController extends ParameterizableViewController 
{
	
	@RequestMapping(method = RequestMethod.GET)
	protected ModelAndView inicial(HttpServletRequest request)
			throws Exception 
	{
		Permissions.ensureAdmin(request);
		
		Map<String, List> resposta = new HashMap<String, List>(); 
		
		if(request.getParameter("id") != null)
		{
			List<String> id = new ArrayList<String>();
			List<String> mensagem = new ArrayList<String>();
			
			EventDAO eventDao = new EventDAO();
			
			List<EventInstance> eventos = eventDao.filtered("typeId=? AND typeRef1=? "
					+ "ORDER BY e.id DESC LIMIT 100", 
					new Object[]{3, request.getParameter("id")}, 0);
			
			for(EventInstance evento : eventos)
			{
				id.add(Integer.toString(evento.getId()));
				mensagem.add(evento.getMessage().getKey());
			}
			
			List<String> tabelaHeader = new ArrayList<String>();
			tabelaHeader.add("2");
			tabelaHeader.add("ID");
			tabelaHeader.add("MENSAGEM");
			resposta.put("tabelaHeader", tabelaHeader);
			
			resposta.put("id", id);
			resposta.put("mensagem", mensagem);
			
			retornaLista("tamanhoTabela", Integer.toString(id.size()), resposta);
			
			
			DataSourceVO<?> ds = Common.ctx.getRuntimeManager().
	        		getDataSource(Integer.parseInt(request.getParameter("id")));
			
			retornaLista("xid", ds.getXid(), resposta);
			retornaLista("nome", ds.getName(), resposta);
		}
		
		return new ModelAndView("lista_erro", resposta);
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
