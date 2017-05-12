FROM centos:6

RUN yum -y install httpd httpd-devel gcc-c++
RUN yum -y install mod_ssl libssh2 libssh2-devel make wget
RUN yum -y install mysql mysql-devel
RUN yum -y install unzip

RUN yum -y install epel-release             # some libs require this repo
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install libxml2-devel libcurl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel openssl-devel libtool-ltdl-devel
RUN mkdir -p /root/download
# download custom version of php (5.3.29 is the latest version of 5.3)
RUN cd /root/download && wget http://cn2.php.net/distributions/php-5.3.29.tar.gz
RUN cd /root/download && tar zxvf php-5.3.29.tar.gz

# configure php with these additions
RUN cd /root/download/php-5.3.29 && ./configure --with-mysql=/usr/lib64/mysql \
    --with-mysqli=/usr/bin/mysql_config --with-pdo-mysql=/usr/bin/mysql_config --with-iconv-dir --with-zlib --with-libxml-dir \
    --enable-xml --with-curl --with-openssl --with-mhash --with-xmlrpc --with-gettext --with-freetype-dir --with-jpeg-dir \
    --with-png-dir --with-gd --enable-gd-native-ttf --with-mcrypt --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-mbregex --enable-mbstring --enable-sockets --enable-ftp --enable-zip --enable-soap --with-libdir=lib64 \
    --with-mcrypt --with-pear --with-config-file-scan-dir=/etc/php.d --with-apxs2=/usr/sbin/apxs \
    && make && make install


# Extra Packages (imagick, ssh2, igbinary, xdebug, etc.). Adjust to your needs.
RUN mkdir /etc/php.d \
    && yum install -y ImageMagick ImageMagick-devel \
    && pecl install imagick-3.3.0 \
    && echo "extension=imagick.so" >> /etc/php.d/imagick.ini \
    && pecl install -f ssh2 \
    && echo "extension=ssh2.so" >> /etc/php.d/ssh2.ini \
    && pecl install igbinary \
    && echo "igbinary.so" >> /etc/php.d/igbinary.ini \
    && pear install channel://pear.php.net/OLE-1.0.0RC2 \
    && pear install channel://pear.php.net/Spreadsheet_Excel_Writer-0.9.3 \
    && pear install channel://pear.php.net/HTML_Template_IT \
    && yes | pecl install xdebug-2.2.7 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions -name xdebug.so)" > /etc/php.d/xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.default_enable=off" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=off" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.profiler_enable=off" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_host=10.254.254.254" >> /etc/php.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /etc/php.d/xdebug.ini

# enable this if you want to use a custom php file.
COPY etc/php.ini /usr/local/lib/php.ini

# the entrypoint script that will be run to start the apache server
COPY server_start.sh /root/server_start.sh

RUN cd /etc/httpd/conf.d \
    && rm -f ssl.conf welcome.conf README \
    && touch /var/log/httpd/error_log \
    && touch /var/log/httpd/access_log \
    && chown -R apache /var/log/httpd

EXPOSE 80
EXPOSE 9000

CMD ["sh", "/root/server_start.sh"]
