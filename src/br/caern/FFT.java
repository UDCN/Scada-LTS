/*BIBLIOTECA
 * - FFT
 * - IFFT
*/

package br.org.caern;
import br.org.caern.Complex;

public class FFT {
	final double PI = 3.14159265359;
	final Complex var_i = new Complex(0,1); //Variavel complexa %i

	//
    public Complex[] fft(double x[]) 
    {
    	 int tam = x.length;
    	 Complex[] resposta = new Complex[tam];
    	 
    	 for(int k=1; k<=tam; k++)
    	 {
    		 Complex soma = new Complex(0,0);
    		 
    		 for(int m=1; m<=tam; m++)
    		 {
    			 //s = s + x(m) * exp(-2 * %i * %pi * - (m-1) * (k-1) / tam);
    			 Complex a = new Complex(((-2 * PI * (-m+1) * (k-1))/tam), 0);
    			 Complex arg = a.times(var_i);
    			 arg = arg.exp();
    			 Complex mult = arg.times(new Complex(x[m-1],0) );
    			 soma = soma.plus(mult);
    		 }
    		 
    		 resposta[k-1] = soma;
    	 }
    	 
    	 return resposta;
    }
    
    public double[] ifft(Complex x[]) 
    {
    	 int tam = x.length;
    	 double[] resposta = new double[tam];
    	 
    	 for(int k=1; k<=tam; k++)
    	 {
    		 Complex soma = new Complex(0,0);
    		 
    		 for(int m=1; m<=tam; m++)
    		 {
    			 //s = s + x(m) * exp(-2 * %i * %pi * - (m-1) * (k-1) / tam);
    			 Complex a = new Complex(((2 * PI * (-m+1) * (k-1))/tam), 0);
    			 Complex arg = a.times(var_i);
    			 arg = arg.exp();
    			 Complex mult = arg.times(x[m-1]);
    			 soma = soma.plus(mult);
    		 }
    		 
    		 resposta[k-1] = (soma.divides(new Complex(tam, 0))).re();
    	 }
    	 
    	 return resposta;
    }
}