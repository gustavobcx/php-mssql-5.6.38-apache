FROM httpd:2.2

RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN sed -i '/deb http:\/\/\(deb\|httpredir\).debian.org\/debian jessie.* main/d' /etc/apt/sources.list
RUN apt-get -o Acquire::Check-Valid-Until=false update

RUN apt-get install -y build-essential vim nano wget apt-utils

COPY ./freetds-patched.tar.gz /tmp/freetds-patched.tar.gz

RUN cd /tmp && tar xzvf freetds-patched.tar.gz \
 && cd freetds-* \
 && ./configure --prefix=/usr/local/freetds --with-tdsver=7.3 --enable-msdblib --with-gnu-ld \
 && make \
 && make install \
 && make clean

RUN touch /usr/local/freetds/include/tds.h \
 && touch /usr/local/freetds/lib/libtds.a

ENV PHP_VERSION 5.6.38

COPY ./php-$PHP_VERSION.tar.gz /tmp/php-$PHP_VERSION.tar.gz

RUN cd /tmp && tar xzvf "php-$PHP_VERSION.tar.gz"

RUN apt-get install -y \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev

RUN apt-get install -y libmysqlclient-dev

RUN apt-get install -y pkg-config

RUN cd "/tmp/php-$PHP_VERSION" \
 && ./configure \
   --enable-pdo --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd \
   --enable-bcmath \
   --enable-fastcgi \
   --enable-force-cgi-redirect \
   --enable-sockets \
   --enable-memory-limit \
   --enable-so \
   --enable-mbstring \
   --with-apxs2  \
   --with-config-file=/etc/php5.ini \
   --with-gettext \
   --with-xml \ 
   --with-dom \
   --with-openssl \
   --with-zlib-dir=/usr/lib \
   --with-freetype-dir=/usr/lib \
   --with-mssql=/usr/local/freetds \
   --without-pear \
 && make \
 && make install \
 && make clean

RUN sed -i 's/#Include conf\/extra\/httpd-vhosts.conf/Include conf\/extra\/httpd-vhosts.conf/g' /usr/local/apache2/conf/httpd.conf
 
# RUN sed -i -r 's/(modules\/mod_foo.so)/\1\nLoadModule php5_module        modules\/libphp5.so/g' /usr/local/apache2/conf/httpd.conf

RUN sed -i -r 's/(DirectoryIndex index.html)/  \1 index.php/g'  /usr/local/apache2/conf/httpd.conf

RUN echo '<fIlesMatch \\.(php)$>\n    SetHandler application/x-httpd-php\n</FilesMatch>' >> /usr/local/apache2/conf/httpd.conf

RUN echo 'ServerTokens ProductOnly\nServerSignature Off' >> /usr/local/apache2/conf/httpd.conf

RUN echo 'Header unset X-Powered-By' >> /usr/local/apache2/conf/httpd.conf

COPY ./php.ini /usr/local/lib/php.ini

COPY ./ca-bundle.crt /etc/ssl/certs/ca-bundle.crt

RUN mkdir -p /var/www/

RUN ln -s /usr/local/apache2/htdocs /var/www

# EXPOSE 80

# CMD apachectl -D FOREGROUND