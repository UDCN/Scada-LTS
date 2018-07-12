package org.scada_lts.web.mvc.controller;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import br.org.caern.FFT;
import br.org.caern.Funcoes;
import br.org.caern.Complex;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
//import org.scada_lts.web.mvc.form.GraficosForm;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.serotonin.db.spring.ConnectionCallbackVoid;
import com.serotonin.mango.Common;
import com.serotonin.mango.db.DatabaseAccess;
import com.serotonin.mango.db.dao.DataPointDao;
import com.serotonin.mango.vo.DataPointNameComparator;
import com.serotonin.mango.vo.DataPointVO;
import com.serotonin.mango.vo.dataSource.DataSourceVO;
import com.serotonin.mango.vo.permission.Permissions;

/*
 * SELECIONAR NO RETORNO AS OPÇÕES PRÉ-SELECIONADAS
 * - FUNCAO
 * - DATAPOINT
 * - TIPO
 * - VALORTEMPO
 * - SELECTTEMPO
 * - DESDE PRIMEIRO PONTO
 * - ATE ULTIMO PONTO
 */


@Controller
@RequestMapping("/funcoes.shtm") 
public class FuncoesController 
{
	private final Log LOG = LogFactory.getLog(FuncoesController.class);
	
	@RequestMapping(method = RequestMethod.GET)
	protected ModelAndView criaForm(HttpServletRequest request)
			throws Exception
	{
		LOG.trace("/funcoes.shtm");
		
		Permissions.ensureAdmin(request);
		
		Funcoes funcoes = new Funcoes();
		
		List<List<String>> dataPoints = funcoes.retornaDataPoints();
		
			
		Map<String, Object> model = new HashMap<String, Object>();
		
		Date date = new Date();
		
		ArrayList<Integer> resposta = new ArrayList<Integer>(Collections.nCopies(7, 0));
		resposta.set(3, 1); //Valor tempo (padrão 1)
		resposta.set(5, 5); //Tamanho da janela
		
		model.put("select", dataPoints); //Lista de dataPoints
		
		model.put("ano", Integer.toString(date.getYear()+1900));
		model.put("mes", Integer.toString(date.getMonth()+1));
		model.put("dia", Integer.toString(date.getDate()));
		model.put("hora", Integer.toString(date.getHours()));
		model.put("minuto", Integer.toString(date.getMinutes()));
		
		model.put("resposta", resposta);
		
		return new ModelAndView("funcoes", model);
	}
	
	
	@RequestMapping(method = RequestMethod.POST)
	protected ModelAndView geraGrafico(HttpServletRequest request)
			throws Exception
	{
		ArrayList<Integer> resposta = new ArrayList<Integer>(Collections.nCopies(7, 0));
		resposta.set(3, 1); //Valor tempo (padrão 1)
		
		LOG.trace("/funcoes.shtm");
		
		Permissions.ensureAdmin(request);
				
		Funcoes funcoes = new Funcoes();
		
		Map<String, Object> model = new HashMap<String, Object>();
		
		List<List<String>> dataPoints = funcoes.retornaDataPoints();
		
		Date date = new Date();
		
		model.put("select", dataPoints);
		model.put("ano", Integer.toString(date.getYear()+1900));
		model.put("mes", Integer.toString(date.getMonth()+1));
		model.put("dia", Integer.toString(date.getDate()));
		model.put("hora", Integer.toString(date.getHours()));
		model.put("minuto", Integer.toString(date.getMinutes()));
		
		
		String funcao = request.getParameter("funcao");
		String idDP = request.getParameter("datapoint");
		String tipo = request.getParameter("tipo");
		String janela = request.getParameter("janela");
		
		int janelaInt = 5;
		
		//Verifica possíveis casos de erro de janela
		if(janela.isEmpty() || janela.equals("0") || janela.equals(""))
			janelaInt = 5;
		else
			janelaInt = Integer.parseInt(janela);
		if(janelaInt < 0)
			janelaInt = 5;
		
		resposta.set(0, Integer.parseInt(funcao));
		resposta.set(1, Integer.parseInt(idDP));
		resposta.set(2, Integer.parseInt(tipo));
		resposta.set(5, janelaInt);
		
		
		String tempo = "";
		
		switch (tipo)
		{
			case "1": //Tempo a partir de agora
				tempo = funcoes.ajustaTempo(tipo, request);
				resposta.set(3, Integer.parseInt(request.getParameter("valortempo")));
				resposta.set(4, Integer.parseInt(request.getParameter("selecttempo")));
				break;
			case "2": //Tempo a partir do último ponto
				tempo = funcoes.ajustaTempo(tipo, request, funcoes.retornaUltimaHora(idDP));
				resposta.set(3, Integer.parseInt(request.getParameter("valortempo")));
				resposta.set(4, Integer.parseInt(request.getParameter("selecttempo")));
				break;
			case "3": //Especificar data
				tempo = funcoes.ajustaTempo(tipo, request, "");
				break;
		}
		
		
		String tempoInicial = tempo.split(",")[0];
		String tempoFinal = tempo.split(",")[1];
		
		List<List<String>> pontos = funcoes.retornaPontos(idDP, tempoInicial, tempoFinal);
		
		switch (funcao)
		{
			//Função de pontos normal
			case "1":
				if(!pontos.isEmpty()) model.put("grafico", pontos);
				break;
			
				//Função de média
			case "2":
				if(!pontos.isEmpty())
				{
					model.put("grafico", pontos);
					model.put("grafico2", funcoes.media_pontos(pontos, janelaInt));
				}
				break;
			
			//Função de mediana
			case "3":
				if(!pontos.isEmpty())
				{
					model.put("grafico", pontos);
					model.put("grafico2", funcoes.mediana_pontos(pontos, janelaInt));
				}
				break;
			
			//Função fft
			case "4":
				if(!pontos.isEmpty()) 
				{
					model.put("grafico", pontos);
					model.put("grafico3", funcoes.fft(pontos));
				}
				break;

			//Função fft - média
			case "5":
				if(!pontos.isEmpty()) 
				{
					List<List<String>> media_pontos = funcoes.media_pontos(pontos, janelaInt);
					model.put("grafico", media_pontos);
					model.put("grafico3", funcoes.fft(media_pontos));
				}
				break;
			
			//Função fft - mediana
			case "6":
				if(!pontos.isEmpty()) 
				{
					List<List<String>> mediana_pontos = funcoes.mediana_pontos(pontos, janelaInt);
					model.put("grafico", mediana_pontos);
					model.put("grafico3", funcoes.fft(mediana_pontos));
				}
				break;
			
		}
		
		
		
		model.put("tipo", tipo);
		model.put("resposta", resposta);
		
		return new ModelAndView("funcoes", model);
		
	}
	
		
	
}