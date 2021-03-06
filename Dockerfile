FROM php:7.2-cli-stretch
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install git zip unzip sqlite3

# copy app files
RUN mkdir /usr/src/app
COPY ./ /usr/src/app/
WORKDIR /usr/src/app

# install and run composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r " \
    if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') \
    { echo 'Installer verified'; } \
    else { echo 'Installer corrupt'; unlink('composer-setup.php'); } \
    echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"
RUN composer install --no-dev 

# install database
RUN sqlite3 database/database.sqlite ".databases"
RUN php artisan migrate --force

# run webserver
EXPOSE 8000
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
