set -e
apt-get install -y apache2
service apache2 start
mkdir -p /var/www/html/a/b/c
echo 'you got it! congratulations!' > /var/www/html/a/b/c/index.html
chmod 000 /var/www/html/a/
