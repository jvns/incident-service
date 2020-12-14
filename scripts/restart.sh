export RAILS_ENV=production
NODE_ENV=production npx tailwindcss-cli@latest build app/assets/stylesheets/tailwind.css -o public/tailwind.css
PATH=/usr/share/rvm/gems/ruby-2.7.2/bin:/usr/share/rvm/gems/ruby-2.7.2@global/bin:/usr/share/rvm/rubies/ruby-2.7.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/share/rvm/bin
bundle install --without development test
if ! [ -e gotty ]; then
    wget -O gotty.tar.gz https://github.com/yudai/gotty/releases/download/v2.0.0-alpha.3/gotty_2.0.0-alpha.3_linux_amd64.tar.gz
    tar -xzf gotty.tar.gz
fi
