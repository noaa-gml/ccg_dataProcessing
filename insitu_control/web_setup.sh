
USER=ccg

cd /
tar xvzf /home/$USER/dist/webserver-2024-03-21.tar.gz

cd /etc/lighttpd
mkdir certs
cd certs
openssl req -new -x509 -keyout lighttpd.pem -out lighttpd.pem -days 365 -nodes
chmod 400 lighttpd.pem

chmod 755 /home/$USER
if [ ! -d /home/$USER/web ]
then
	mkdir /home/$USER/web
fi
chmod 755 /home/$USER/web

cd /etc/lighttpd
htdigest -c .htdigest GGGRN gggrn

htpasswd -c .htpasswd gggrn

systemctl enable lighttpd
systemctl start lighttpd
systemctl enable php-fpm
systemctl start php-fpm
