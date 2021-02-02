FROM php:7.1-fpm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev

RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install mysqli pdo pdo_mysql

# install the PHP gd library
RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

# install the soap extension
RUN apt-get update -yqq && \
    apt-get -y install libxml2-dev && \
    docker-php-ext-install soap

# install bcmath, mbstring and zip extensions
RUN docker-php-ext-install bcmath && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install zip

# install intl and requirements
RUN apt-get update -yqq && \
    apt-get install -y zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

RUN docker-php-ext-install fileinfo

# Install Composer, PHPCS,
# PHPMetrics, PHPDepend, PHPMessDetector, PHPCopyPasteDetector
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require 'squizlabs/php_codesniffer' \
        'phpmetrics/phpmetrics' \
        'pdepend/pdepend' \
        'phpmd/phpmd' \
        'sebastian/phpcpd'

# Install Nodejs
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g eslint babel-eslint eslint-plugin-react yarn

# compile igbinary extension
RUN cd /tmp/ && git clone https://github.com/igbinary/igbinary "php-igbinary" && \
    cd php-igbinary && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    docker-php-ext-enable igbinary

# curl extension
RUN apt-get install -y curl libcurl4-openssl-dev --no-install-recommends && \
    docker-php-ext-install curl

# data structures extension
RUN pecl install ds && \
    docker-php-ext-enable ds

# imagick
RUN apt-get update && apt-get install -y libmagickwand-6.q16-dev --no-install-recommends && \
    ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin && \
    pecl install imagick && \
    echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini

# ssh2 module
RUN apt-get install -y libssh2-1-dev && \
    pecl install ssh2-1.0 && \
    docker-php-ext-enable ssh2

# php-module: curl dom bz2 gd json mysqli pcntl pdo pdo_mysql phar posix
RUN apt-get install -y libxml2-dev libbz2-dev re2c libpng++-dev \
    libjpeg-dev libvpx-dev zlib1g-dev libgd-dev \
    libtidy-dev libxslt1-dev libmagic-dev libexif-dev file \
    sqlite3 libsqlite3-dev libxslt-dev

RUN export CFLAGS="-I/usr/src/php" && \
    docker-php-ext-install xmlreader xmlwriter

RUN docker-php-ext-configure json && \
    docker-php-ext-configure session && \
    docker-php-ext-configure ctype && \
    docker-php-ext-configure tokenizer && \
    docker-php-ext-configure simplexml && \
    docker-php-ext-configure dom && \
    docker-php-ext-configure mbstring && \
    docker-php-ext-configure zip && \
    docker-php-ext-configure pdo && \
    docker-php-ext-configure pdo_sqlite && \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure mysqli && \
    docker-php-ext-configure iconv && \
    docker-php-ext-configure xml && \
    docker-php-ext-configure phar

RUN docker-php-ext-install \
    dom \
    bz2 \
    json \
    pcntl \
    phar \
    posix \
    simplexml \
    soap \
    tidy \
    xml \
    xmlrpc \
    xsl \
    calendar \
    ctype \
    fileinfo \
    ftp \
    sysvmsg \
    sysvsem \
    sysvshm

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["php-fpm"]
