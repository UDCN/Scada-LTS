package br.org.caern;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import com.serotonin.db.spring.ConnectionCallbackVoid;
import com.serotonin.mango.Common;
import com.serotonin.mango.db.DatabaseAccess;
import com.serotonin.mango.db.dao.DataPointDao;
import com.serotonin.mango.db.dao.PointValueDao;
import com.serotonin.mango.rt.dataImage.PointValueTime;
import com.serotonin.mango.rt.dataImage.types.MangoValue;
import com.serotonin.mango.vo.DataPointNameComparator;
import com.serotonin.mango.vo.DataPointVO;
import com.serotonin.mango.vo.dataSource.DataSourceVO;

import java.util.Arrays;

public class Funcoes 
{
	public List<List<String>> retornaDataPoints()
	{
		List<DataSourceVO<?>> dataS = Common.ctx.getRuntimeManager().getDataSources();
		
		List<List<String>> data = new ArrayList<List<String>>();
		
		List<String> linha;
		
		/*
		 * RETORNA, EM ORDEM: ID - NOME DOS DATA SOURCES
		 */
		
		DataPointDao dataPointDao = new DataPointDao();
		List<DataPointVO> dataPoints = new ArrayList<DataPointVO>();
		
		for(DataSourceVO<?> ds : dataS)
		{
		 	dataPoints = dataPointDao.getDataPoints(ds.getId(), DataPointNameComparator.instance);
	       	for (DataPointVO dataPoint : dataPoints)
	       	{
	       		linha = new ArrayList<String>();
				
				try
				{
					linha.add(Integer.toString(dataPoint.getId()));
					linha.add(dataPoint.getName().toUpperCase());
					linha.add(ds.getName().toUpperCase());
					data.add(linha);
				}
				catch(Exception e)
				{
					linha.add("");
				}
				
	       	}
		}
		
		return data;
	}
	
	public String ajustaTempo(String tipo, HttpServletRequest request) throws ParseException
	{
		return ajustaTempo(tipo, request, "");
	}
	
	public String ajustaTempo(String tipo, HttpServletRequest request, String dataInicialStr) 
			throws ParseException
	{
		String tempo = "";
		
		switch(tipo)
		{
			case "1":
			case "2":	
				String selectTempo = request.getParameter("selecttempo");
				int valorTempo = Integer.parseInt(request.getParameter("valortempo"));
				Date dataFinal = new Date();
				Date dataInicial;
				
				if (dataInicialStr.equals("")) dataInicial = new Date(); 
				else dataInicial = new Date(Long.valueOf(dataInicialStr));
				
				switch(selectTempo)
				{
					case "1":
						dataInicial.setMinutes(dataInicial.getMinutes() - valorTempo);
						break;
					case "2":
						dataInicial.setHours(dataInicial.getHours() - valorTempo);
						break;
					case "3":
						dataInicial.setDate(dataInicial.getDate() - valorTempo);
						break;
					case "4":
						dataInicial.setDate(dataInicial.getDate() - valorTempo*7);
					case "5":
						dataInicial.setMonth(dataInicial.getMonth() - valorTempo);
					case "6":
						dataInicial.setYear(dataInicial.getYear() - valorTempo);
				}
				tempo = dataInicial.getTime() + ",";
				tempo += dataFinal.getTime();
				break;
				
			case "3":
				if(request.getParameterMap().containsKey("inicio") && 
						request.getParameterMap().containsKey("fim"))
				{
					Date agora = new Date();
					tempo = "0,";
					tempo += agora.getTime(); 
				}
				
				else if(request.getParameterMap().containsKey("inicio"))
				{
					SimpleDateFormat dateParse = new SimpleDateFormat("dd/MM/yyyy HH:mm");
					String dataCompleta = request.getParameter("diafim") + "/" +
							request.getParameter("mesfim") + "/" +
							request.getParameter("anofim") + " " +
							request.getParameter("horafim") + ":" +
							request.getParameter("minutofim");
					
					Date date = dateParse.parse(dataCompleta);
					
					tempo = "0,";
					tempo += date.getTime();
				}
				
				else if(request.getParameterMap().containsKey("fim"))
				{
					SimpleDateFormat dateParse = new SimpleDateFormat("dd/MM/yyyy HH:mm");
					String dataCompleta = request.getParameter("diainicio") + "/" +
							request.getParameter("mesinicio") + "/" +
							request.getParameter("anoinicio") + " " +
							request.getParameter("horainicio") + ":" +
							request.getParameter("minutoinicio");
					
					Date date = dateParse.parse(dataCompleta);
					
					tempo = date.getTime() + ",";
					date = new Date();
					tempo += date.getTime();
					
				}
				else
				{
					SimpleDateFormat dateParse = new SimpleDateFormat("dd/MM/yyyy HH:mm");
					
					String dataInicio = request.getParameter("diainicio") + "/" +
							request.getParameter("mesinicio") + "/" +
							request.getParameter("anoinicio") + " " +
							request.getParameter("horainicio") + ":" +
							request.getParameter("minutoinicio");
					
					Date date = dateParse.parse(dataInicio);
					tempo = date.getTime() + ",";
					
					String dataFim = request.getParameter("diafim") + "/" +
							request.getParameter("mesfim") + "/" +
							request.getParameter("anofim") + " " +
							request.getParameter("horafim") + ":" +
							request.getParameter("minutofim");
					
					date = dateParse.parse(dataFim);
					tempo += date.getTime();
				}
				
				break;
			
		}
		return tempo;
	}
	
	public String retornaUltimaHora(String id)
	{
		List<String> param = new ArrayList<String>();
		param.add("");
		
		List<Integer> idList = new ArrayList<Integer>();
		idList.add(Integer.parseInt(id));
		
		PointValueDao pointValue = new PointValueDao();
		
		PointValueTime ponto = pointValue.getLatestPointValue(Integer.parseInt(id));
		
		
		
		return Long.toString(ponto.getTime());
	}
	
	
	public List<List<String>> retornaPontos(String id, String tempoinicial, String tempofinal)
	{
		List<List<String>> pontos = new ArrayList<List<String>>();
		
		List<PointValueTime> listPontos = new ArrayList<PointValueTime>();
		
		
		PointValueDao pointValue = new PointValueDao();
		listPontos = pointValue.getPointValuesBetween(Integer.parseInt(id), 
				Long.parseLong(tempoinicial), Long.parseLong(tempofinal));
		
		for (PointValueTime ponto : listPontos)
		{
			MangoValue valorMango = null;
			valorMango = ponto.getValue();
			
			List<String> linha = new ArrayList<String>();
    		linha.add(Long.toString(ponto.getTime()));
    		linha.add(valorMango.toString() + "},"); 
    		pontos.add(linha);
		}
		
		if(pontos.size() > 1)
		{
			List<String> linha = new ArrayList<String>();
	    	linha = pontos.get(pontos.size()-1);
	    	linha.set(1, linha.get(1).replace(",", ""));
	    	pontos.set(pontos.size()-1, linha);
		}
		
		
		
		
		return pontos;
	}
	
	

	public List<List<String>> media_pontos (List<List<String>> pontos, int janela)
	{
		List<List<String>> novos_pontos = new ArrayList<List<String>>();;
		
		int i = 0;
		List<String> list_valor = new ArrayList<String>();
		
		for (List<String> ponto : pontos)
		{
			String tempo = ponto.get(0);
			String valor = ponto.get(1).replace("}", "");
			valor = valor.replace(",", "");
			list_valor.add(valor);
			if(i<janela)
			{
				List<String> linha = new ArrayList<String>();
        		linha.add(tempo);
        		linha.add(valor + "},"); 
        		novos_pontos.add(linha);
			}
			else
			{
				float soma = 0;
				for(int aux=janela; aux>=1; aux--)
				{
					String valorS = list_valor.get(list_valor.size() - aux);
					if(valorS.contains("-")) //Tratamento para número negativo
					{
						valorS = valorS.replace("-", "");
						soma += -Float.parseFloat(valorS);
					}
					else
					{
						//Tratamento para tipo booleano
						if(valorS.equals("true")) valorS = "1";
						if(valorS.equals("false")) valorS = "0";
						
						soma += Float.parseFloat(valorS);
					}
						
				}
					
				
				soma = soma/janela;
				List<String> linha = new ArrayList<String>();
        		linha.add(tempo);
        		linha.add(Float.toString(soma) + "},"); 
        		novos_pontos.add(linha);
				
			}
			i++;
			
		}
		
		List<String> linha = new ArrayList<String>();
    	linha = novos_pontos.get(novos_pontos.size()-1);
    	linha.set(1, linha.get(1).replace(",", ""));
    	novos_pontos.set(novos_pontos.size()-1, linha);
		
		
		return novos_pontos;
	}
	
	public List<List<String>> mediana_pontos (List<List<String>> pontos, int janela)
	{
		List<List<String>> novos_pontos = new ArrayList<List<String>>();;
		
		int i = 0;
		List<String> list_valor = new ArrayList<String>();
		
		for (List<String> ponto : pontos)
		{
			String tempo = ponto.get(0);
			String valor = ponto.get(1).replace("}", "");
			valor = valor.replace(",", "");
			list_valor.add(valor);
			if(i<janela)
			{
				List<String> linha = new ArrayList<String>();
        		linha.add(tempo);
        		linha.add(valor + "},"); 
        		novos_pontos.add(linha);
			}
			else
			{
				double[] vetor = new double[janela];
				
				for(int aux=janela ; aux>=1; aux--)
				{
					String valorS = list_valor.get(list_valor.size() - aux);
					if(valorS.contains("-")) //Tratamento para número negativo
					{
						valorS = valorS.replace("-", "");
						vetor[aux-1] = -Float.parseFloat(valorS);
					}
					else
					{
						//Tratamento para tipo booleano
						if(valorS.equals("true")) valorS = "1";
						if(valorS.equals("false")) valorS = "0";
						
						vetor[aux-1] = Float.parseFloat(valorS);
					}
						
				}
				
				//Organiza o array, do maior para o menos
		        Arrays.sort(vetor);
				
				List<String> linha = new ArrayList<String>();
        		linha.add(tempo);
        		linha.add(Double.toString(vetor[2]) + "},"); 
        		novos_pontos.add(linha);
				
			}
			i++;
			
		}
		
		List<String> linha = new ArrayList<String>();
    	linha = novos_pontos.get(novos_pontos.size()-1);
    	linha.set(1, linha.get(1).replace(",", ""));
    	novos_pontos.set(novos_pontos.size()-1, linha);
		
		
		return novos_pontos;
	}
	
	
	public List<List<String>> fft (List<List<String>> pontos)
	{
		double x[] = new double[pontos.size()];
		int i = 0;
		
		for (List<String> ponto : pontos)
		{
			String valor = ponto.get(1).replace("}", "");
			valor = valor.replace(",", "");
			
			if(valor.contains("-")) //Tratamento para número negativo
			{
				valor = valor.replace("-", "");
				x[i] = -Double.valueOf(valor);
			}
			else
			{
				//Tratamento para tipo booleano
				if(valor.equals("true")) valor = "1";
				if(valor.equals("false")) valor = "0";
				x[i] = Double.valueOf(valor);
			}
			
			i++;
		}
		
		FFT fftConv = new FFT();
		Complex[] complexConv = fftConv.fft(x);
		i = 0;
		List<List<String>> fftList = new ArrayList<List<String>>();
		List<String> linha;
		
		for(i=0; i<pontos.size(); i++)
		{
			linha = new ArrayList<String>();
			linha.add(Integer.toString(i));
			if (complexConv[i].re() > 0)
				linha.add(Double.toString(complexConv[i].re()) + "},");
			else
				linha.add(0 + "},");
			fftList.add(linha);
		}
		
		List<List<String>> fftListFinal = new ArrayList<List<String>>();
		for(i=1; i<pontos.size()/2; i++)
		{
			fftListFinal.add(fftList.get(i));
		}
		
		linha = new ArrayList<String>();
    	linha = fftListFinal.get(fftListFinal.size()-1);
    	linha.set(1, linha.get(1).replace(",", ""));
    	fftListFinal.set(fftListFinal.size()-1, linha);
		
		
		return fftListFinal;
	}
	

}
