#!/bin/bash

sudo apt update -y

# Install Dependencies

sudo apt install apache2 \
ghostscript \
libapache2-mod-php \
mysql-server \
php \
php-bcmath \
php-curl \
php-imagick \
php-intl \
php-json \
php-mbstring \
php-mysql \
php-xml \
php-zip -y

# Configure Apache for WordPress

sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
sudo curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

sudo echo "
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
" | sudo tee /etc/apache2/sites-available/wordpress.conf


#Enable the site with:
sudo a2ensite wordpress

#Enable URL rewriting with:
sudo a2enmod rewrite

# Disable the default “It Works” site with:
sudo a2dissite 000-default

sudo service apache2 reload

# Configure database
sudo mysql -u root -e "CREATE DATABASE wordpress; CREATE USER wordpress@localhost IDENTIFIED BY 'password123'; GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost; FLUSH PRIVILEGES;"
sudo mysql -u root

mysql> CREATE DATABASE wordpress;

mysql> CREATE USER wordpress@localhost IDENTIFIED BY 'password123';

mysql> GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;

mysql> FLUSH PRIVILEGES;

mysql> quit

#Configure WordPress to connect to the database
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/password123/' /srv/www/wordpress/wp-config.php

#sudo -u www-data nano /srv/www/wordpress/wp-config.php
#Find the following:
#
#define( 'AUTH_KEY',         'put your unique phrase here' );
#define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
#define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
#define( 'NONCE_KEY',        'put your unique phrase here' );
#define( 'AUTH_SALT',        'put your unique phrase here' );
#define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
#define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
#define( 'NONCE_SALT',       'put your unique phrase here' );
#Delete those lines (ctrl+k will delete a line each time you press the sequence).
# Then replace with the content of https://api.wordpress.org/secret-key/1.1/salt/.
# (This address is a randomiser that returns completely random keys each time it is opened.)
# This step is important to ensure that your site is not vulnerable to “known secrets” attacks.
#

#define('AUTH_KEY',         'me|>E]CH5Zs<+<*oGe>=$a<-rhb~qT>-F^*U6M{YWq}apl:*p&z~$+eB[lZ.i%i,');
#define('SECURE_AUTH_KEY',  'K{t]8&5;m69_aQiY!JK{`*waWa/O=X^o~C~`8t^=lqahOF/u[Ehp*LCR6!C|^,=C');
#define('LOGGED_IN_KEY',    '_i>?JdHt|+0+CZfj{h`cO|_ZyE>9jp!av|*jnpZi_=nI-@!;(O485d~aBxS I|vK');
#define('NONCE_KEY',        '_Gi@dh1X;m9e0|M!d$|e;)vyFck~rO),C_j;N;?fGU<4lWDOvoSU3zw<&bV%y{y-');
#define('AUTH_SALT',        '|ZgbN}dV4q;qx]zzRK4lfyJ.9CWc,~{YV`I+[sH|ef,30$f)4~xM43;v|.^*<SG0');
#define('SECURE_AUTH_SALT', '@P(Mnogt$3%sHn/^|n,P8#k6eE5OD^M(/fFWX%EVG]FWnxO$DkMb1BZq4CS E5; ');
#define('LOGGED_IN_SALT',   'UmuV9k@rbsXj5VSl=tVF.KAYIharTUFT-79+y!eXM3Lr!QeMEI^?PN3Npen:|5!$');
#define('NONCE_SALT',       '8DF[S#XT!7TX3kP3`@fn@3:O|WuNNh?7b9;^=0j%hw-~Wk+_Q]7n!8=}~ VCgxy5');

#Save and close the configuration file by typing ctrl+x followed by y then enter
