PATH=/usr/share/rvm/gems/ruby-2.7.2/bin:/usr/share/rvm/gems/ruby-2.7.2@global/bin:/usr/share/rvm/rubies/ruby-2.7.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/share/rvm/bin
bundle
if [ ! -e gotty ]; then
    wget -O gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz
    tar -xzf gotty.tar.gz
fi
