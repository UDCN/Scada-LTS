export CATALINA_HOME=/usr/share/tomcat7 && ant clean && ant build && sudo cp -r build/* /var/lib/tomcat7/webapps/scadalts/WEB-INF/ && sudo service tomcat7 restart