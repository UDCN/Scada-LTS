package br.org.caern;

public class Filtros {

	//Filtro butterworth
	public double[] ganho_butterworth(Complex x[], int ordem, int w_max, int wc)
	{
		double[] ganhos = new double[w_max];
		
		for (int i = 1; i <= w_max; i++)
		{
			int a = i / w_max;
			ganhos[i-1] = 1 / ( Math.sqrt(1 + (a ^ (2*ordem))));
		}
		
		return ganhos;		
	}
	
	
	
}
