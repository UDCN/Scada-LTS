package org.scada_lts.web.mvc.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.mail.internet.InternetAddress;
import javax.servlet.http.HttpServletRequest;

import org.scada_lts.dao.SystemSettingsDAO;
import org.scada_lts.dao.UserDAO;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.serotonin.mango.vo.User;
import com.serotonin.web.email.EmailContent;
import com.serotonin.web.email.EmailSender;

@Controller
@RequestMapping("/contato.shtm") 
public class ContatoController {
	
	private InternetAddress fromAddress;
    private InternetAddress[] toAddresses;
    private String subject;
    
	@RequestMapping(method = RequestMethod.GET)
	protected ModelAndView criaForm(HttpServletRequest request)
			throws Exception
	{
		Map<String, Object> model = new HashMap<String, Object>();
		
		return new ModelAndView("contato", model);
	}
	
	@RequestMapping(method = RequestMethod.POST)
	protected ModelAndView enviaDados(HttpServletRequest request)
			throws Exception
	{
		Map<String, Object> model = new HashMap<String, Object>();
		SystemSettingsDAO SystemSettingsDAO = new SystemSettingsDAO();
		UserDAO UserDAO = new UserDAO();
		
		List<User> usuarios = new ArrayList<User>();
		
		
		try 
		{
			String nome = request.getParameter("nome");
			String email = request.getParameter("email");
			String telefone = request.getParameter("telefone");
			String setor = request.getParameter("setor");
			String assunto = request.getParameter("assunto");
			String mensagem = "";
			
			mensagem += "NOME: " + nome + "\r\n";
			mensagem += "EMAIL: " + email + "\r\n";
			mensagem += "TELEFONE: " + telefone + "\r\n";
			mensagem += "SETOR: " + setor + "\r\n";
			mensagem += "ASSUNTO: " + assunto + "\r\n";
			mensagem += "---------------------------------------------------------------------- \r\n";
			mensagem += request.getParameter("mensagem") + "\r\n";
			mensagem += "---------------------------------------------------------------------- \r\n";
			mensagem += "Mensagem automática do Scada enviada através do formulário de contato.";
			
			subject = "Contato Scada - " + assunto;
			
			EmailContent cnt = new EmailContent(mensagem);
			
			String addr = SystemSettingsDAO.getValue(SystemSettingsDAO.EMAIL_FROM_ADDRESS);
            String pretty = SystemSettingsDAO.getValue(SystemSettingsDAO.EMAIL_FROM_NAME);
            fromAddress = new InternetAddress(addr, pretty);
            
            EmailSender emailSender = new EmailSender(SystemSettingsDAO.getValue(SystemSettingsDAO.EMAIL_SMTP_HOST),
                    SystemSettingsDAO.getIntValue(SystemSettingsDAO.EMAIL_SMTP_PORT),
                    SystemSettingsDAO.getBooleanValue(SystemSettingsDAO.EMAIL_AUTHORIZATION),
                    SystemSettingsDAO.getValue(SystemSettingsDAO.EMAIL_SMTP_USERNAME),
                    SystemSettingsDAO.getValue(SystemSettingsDAO.EMAIL_SMTP_PASSWORD),
                    SystemSettingsDAO.getBooleanValue(SystemSettingsDAO.EMAIL_TLS));

            usuarios = UserDAO.getUsers();
            List<String> nomes = new ArrayList<String>();
            List<String> emails = new ArrayList<String>();
            for(User usuario : usuarios)
            {
            	if(usuario.isAdmin())
            	{
            		nomes.add(usuario.getUsername());
            		emails.add(usuario.getEmail());
            	}
            }
            
            toAddresses = new InternetAddress[1];
            
            for (int i=0; i<nomes.size(); i++)
            {
            	toAddresses[0] = new InternetAddress(emails.get(i), nomes.get(i));
            	emailSender.send(fromAddress, toAddresses, subject, cnt);
            }
            
            model.put("resposta", "<center><h4><font color='green'><b>Mensagem enviada com sucesso."
            		+ "</b></font></h4></center>");
            
		} catch (Exception e) {
			model.put("resposta", "<center><h4><font color='red'><b>Erro ao enviar mensagem."
            		+ "</b></font></h4></center>");
		}
		
		return new ModelAndView("contato", model);
	}
	
	

}
