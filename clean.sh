#!/bin/bash

rm -rf /app/testlink/install

echo "" >> /app/testlink/config.inc.php
echo "\$tlCfg->config_check_warning_mode = 'SILENT';" >> /app/testlink/config.inc.php

for f in $(find /app/testlink -name ".htaccess")
do
    rm -rf $f
done

