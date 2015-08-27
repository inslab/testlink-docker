#!/bin/bash

if [ ! -d /var/lib/mysql/testlink_conf ]
then
    cp -rf /tmp/testlink_conf /var/lib/mysql/
    rm -rf /tmp/testlink_conf
fi

if [ -n "$LDAP_HOST" ] && [ -n "$LDAP_PORT" ] && [ -n "$LDAP_BASE_DN" ]
then
    echo "--> LDAP setting..."
    sed -e "s|\$tlCfg->authentication\['ldap_server'\] = 'localhost';|\$tlCfg->authentication['ldap_server'] = '$LDAP_HOST';|" \
        -e "s|\$tlCfg->authentication\['ldap_port'\] = 389;|\$tlCfg->authentication['ldap_port'] = '$LDAP_PORT'|" \
        -e "s|\$tlCfg->authentication\['ldap_root_dn'\] = 'dc=mycompany,dc=com';|\$tlCfg->authentication['ldap_root_dn'] = '$LDAP_BASE_DN';|" \
        -e "s|\$tlCfg->authentication\['ldap_automatic_user_creation'\] = false;|\$tlCfg->authentication['ldap_automatic_user_creation'] = true;|" \
        -e "s|\$tlCfg->authentication\['ldap_firstname_field'\] = 'givenname';|\$tlCfg->authentication['ldap_firstname_field'] = 'givenName';|" \
        -e "s|\$tlCfg->user_self_signup = TRUE;|\$tlCfg->user_self_signup = FALSE;|" \
        -e "s|\$tlCfg->password_reset_send_method = 'send_password_by_mail';|\$tlCfg->password_reset_send_method = 'display_on_screen';|" \
        /var/lib/mysql/testlink_conf/config.inc.php > /var/lib/mysql/testlink_conf/config.inc.php.tmp
    mv /var/lib/mysql/testlink_conf/config.inc.php.tmp /var/lib/mysql/testlink_conf/config.inc.php
else
    echo "Skip LDAP setting..."
fi

cp -f /var/lib/mysql/testlink_conf/config*.php /app/testlink/

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"
    echo "=> Create MySQL Admin User"
    /create_mysql_admin_user.sh
    echo "=> Done!"
    echo "=> Import MySQL Testlink Data"
    /import_mysql_testlink_data.sh $MYSQL_PASS
    echo "=> Done!"
    echo "=> Set MySQL User password into testlink"
    sed -i "s/testlink_pass/$MYSQL_PASS/g" /app/testlink/config_db.inc.php
    echo "=> Done!"
    echo "=> Clean after install"
    /clean.sh
    echo "=> Done!"
else
    echo "=> Using an existing volume of MySQL"
    echo "=> Set MySQL User password into testlink"
    sed -i "s/testlink_pass/$MYSQL_PASS/g" /app/testlink/config_db.inc.php
    /clean.sh
    echo "=> Done!"
fi

exec supervisord -n
