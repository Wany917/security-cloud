#!/bin/bash
# ──────────────────────────────────────────────────────────────────────────
# DEMO UNIQUEMENT : reproduit l'app vulnerable du CTF kungfu (SSRF + RCE).
# Sert a prouver que sur l'EC2 durcie (IMDSv2), le pivot vol-de-creds echoue.
# A NE JAMAIS exposer a internet (RCE) : le SG demo ne l'ouvre qu'a ton IP.
# ──────────────────────────────────────────────────────────────────────────
set -e

apt-get update -y
apt-get install -y curl nginx php-fpm

systemctl enable nginx

# Debian 12 -> php8.2 ; on detecte la socket php-fpm dynamiquement.
PHP_SOCK=$(ls /run/php/php*-fpm.sock 2>/dev/null | head -1)
[ -z "$PHP_SOCK" ] && PHP_SOCK="/run/php/php-fpm.sock"

cat > /var/www/html/index.php <<'PHPEOF'
<?php
$input = filter_var($_POST['input'], FILTER_VALIDATE_URL);
$command = "curl $input";
$output = system($command);
?>
<!DOCTYPE html>
<html>
<body>
<form action="index.php" method="post">
Enter URL to curl :
   <input type="text" name="input" id="input">
   <input type="submit" value="Launch" name="submit">
</form>
</body>
</html>
PHPEOF

cat > /etc/nginx/sites-available/default <<EOF
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  root /var/www/html;
  index index.php;
  server_name _;
  location / { try_files \$uri \$uri/ /index.php; }
  location ~ \.php\$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:${PHP_SOCK};
  }
}
EOF

chmod -R 755 /var/www/html
systemctl restart php*-fpm
systemctl restart nginx
