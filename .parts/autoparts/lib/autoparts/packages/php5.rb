# Copyright (c) 2013-2014 Irrational Industries Inc. d.b.a. Nitrous.IO
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/nitrous-io/autoparts/master/LICENSE).

module Autoparts
  module Packages
    class Php5 < Package
      name 'php5'
      version '5.5.14'
      description 'PHP 5.5: A popular general-purpose scripting language that is especially suited to web development.'
      category Category::PROGRAMMING_LANGUAGES

      source_url 'http://www.php.net/get/php-5.5.14.tar.bz2/from/this/mirror'
      source_sha1 '062d351da165aa0568e4d8cbc53a18d73b99f49a'
      source_filetype 'tar.bz2'

      depends_on 'apache2'
      depends_on 'libmcrypt'

      def compile
        Dir.chdir("php-#{version}") do
          args = [
            "--with-apxs2=#{apache2_dependency.bin_path + "apxs"}",
            "--with-mcrypt=#{get_dependency("libmcrypt").prefix_path}",
            # path
            "--prefix=#{prefix_path}",
            "--bindir=#{bin_path}",
            "--sbindir=#{bin_path}",
            "--with-config-file-path=#{php5_config_path}",
            "--with-config-file-scan-dir=#{php5_scan_path}",
            "--sysconfdir=#{php5_config_path}",
            "--libdir=#{lib_path}",
            "--includedir=#{include_path}",
            "--datarootdir=#{share_path}/#{name}",
            "--datadir=#{share_path}/#{name}",
            "--mandir=#{man_path}",
            "--docdir=#{doc_path}",
            # features
            "--enable-opcache",
            "--with-curl",
            "--with-freetype-dir=/usr/lib/x86_64-linux-gnu",
            "--with-gd",
            "--with-gettext",
            "--with-iconv",
            "--with-jpeg-dir=/usr/lib/x86_64-linux-gnu",
            "--with-kerberos",
            "--with-mysql=mysqlnd",
            "--with-mysqli=mysqlnd",
            "--with-mysql-sock=/tmp/mysql.sock",
            "--with-openssl",
            "--with-pdo-mysql=mysqlnd",
            "--with-pdo-pgsql",
            "--with-pdo-sqlite",
            "--with-pgsql",
            "--with-png-dir=/usr/lib/x86_64-linux-gnu",
            "--with-readline",
            "--with-zlib",
            "--with-zlib-dir=/usr/lib/x86_64-linux-gnu",
            "--with-xsl",
            "--enable-bcmath",
            "--enable-exif",
            "--enable-gd-native-ttf",
            "--enable-intl",
            "--enable-json",
            "--enable-mbstring",
            "--enable-soap",
            "--enable-sockets",
            "--enable-sysvsem",
            "--enable-sysvshm",
            "--enable-xmlreader",
            "--enable-zip"
          ]
          execute './configure', *args
          execute 'make'
        end
      end

      def install
        Dir.chdir("php-#{version}") do
          execute 'make install'
          execute 'cp', 'php.ini-development', "#{lib_path}/php.ini"
          # force apache2 to rewrite its config to get a pristine config
          # because php will rewrite it
          apache2_dependency.rewrite_config
          # copy libphp5.so over to the package so it will be distributed with
          # the binary
          execute 'mv', "#{apache2_libphp5_path}", "#{lib_path + "libphp5.so"}"
        end
      end

      def post_install
        # copy libphp5.so over to apache modules path
        execute 'cp', "#{lib_path + "libphp5.so"}", "#{apache2_libphp5_path}"
        # write php5_config if not exist
        unless apache2_php5_config_path.exist?
          File.open(apache2_php5_config_path, "w") { |f| f.write php5_apache_config }
        end
        # copy php.ini over
        unless php5_ini_path.exist?
          FileUtils.mkdir_p(File.dirname(php5_ini_path))
          execute 'cp', "#{lib_path}/php.ini", "#{php5_ini_path}"
        end
      end

      def tips
        apache2_dependency.tips + "\n" + <<-EOS.unindent
          PHP config file is located at:
            $ #{php5_ini_path}

          If Apache2 httpd is already running, you will need to restart it:
            $ parts restart apache2
        EOS
      end

      def php5_config_path
        Path.etc + "php5"
      end

      def php5_ini_path
        php5_config_path + "php.ini"
      end

      def php5_scan_path
        php5_config_path + "conf.d"
      end

      def apache2_dependency
        @apache2_dependency ||= get_dependency "apache2"
      end

      def apache2_libphp5_path
        apache2_dependency.prefix_path + "modules" + "libphp5.so"
      end

      def apache2_php5_config_path
        apache2_dependency.user_config_path + "php.conf"
      end

      def php5_apache_config
        <<-EOF.unindent
          PHPIniDir #{php5_ini_path}
          LoadModule php5_module modules/libphp5.so
          AddHandler php5-script .php
          DirectoryIndex index.php
        EOF
      end
    end
  end
end
