# Copyright (c) 2013-2014 Irrational Industries Inc. d.b.a. Nitrous.IO
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/nitrous-io/autoparts/master/LICENSE).

module Autoparts
  module Packages
    class Apache2 < Package
      name 'apache2'
      version '2.4.9'
      description 'Apache Web Server: A cross-platform open-source HTTP server for modern operating systems'
      category Category::WEB_DEVELOPMENT

      source_url 'http://www.us.apache.org/dist//httpd/httpd-2.4.9.tar.gz'
      source_sha1 '50496e51605a3d852c183a7c667c25bcc7ee658d'
      source_filetype 'tar.gz'

      depends_on 'apr'
      depends_on 'apr_util'

      def compile
        Dir.chdir('httpd-2.4.9') do
          File.open('config.layout', 'a') do |f|
            f.write config_layout_file
          end

          args = [
            "--with-apr=#{get_dependency("apr").prefix_path}",
            "--with-apr-util=#{get_dependency("apr_util").prefix_path}",
            "--enable-layout=Autoparts",
            # features
            "--disable-debug",
            "--disable-dependency-tracking",
            "--enable-so",
            "--enable-ssl",
            "--with-port=3000"
          ]
          execute './configure', *args
          execute 'make'
        end
      end

      def install
        Dir.chdir('httpd-2.4.9') do
          execute 'make install'
        end
      end

      def post_install
        execute 'mkdir', '-p', Path.var + 'apache2' + 'run'
        execute 'mkdir', '-p', Path.var + 'apache2' + 'log'

        # Setup configs.
        if apache_config_path.exist?
          FileUtils.cp apache_config_path, apache_config_path.to_s + "." + Time.now.to_s
        else
          FileUtils.mkdir_p(File.dirname(apache_config_path))
        end
        rewrite_config
        unless user_config_path.exist?
          user_config_path.mkpath
        end

        # Setup mime.types.
        FileUtils.cp '/etc/mime.types', mime_types_path

        # Setup document root.
        execute 'mkdir', '-p', htdocs_path
        if home_workspace_path.directory?
          home_workspace_htdocs_path.make_symlink(htdocs_path) unless home_workspace_htdocs_path.exist?
        end
      end

      def post_uninstall
        home_workspace_htdocs_path.unlink if home_workspace_htdocs_path.symlink?
      end

      def start
        execute bin_path + "apachectl", "start"
      end

      def stop
        execute bin_path + "apachectl", "stop"
      end

      def running?
        if apache_pid_file_path.exist?
          pid = File.read(apache_pid_file_path).strip
          if pid.length > 1 && `ps -o cmd= #{pid}`.include?(httpd_path.basename.to_s)
            return true
          end
        end
        false
      end

      def tips
        <<-EOS.unindent
          To start the Apache server:
            $ parts start apache2

          To stop the Apache server:
            $ parts stop apache2

          Apache config is located at:
            $ #{apache_config_path}

          Default document root is located at:
            $ #{htdocs_path}
        EOS
      end

      def rewrite_config
        File.open(apache_config_path, 'w') { |f| f.write apache_config }
      end

      def apache_config_path
        Path.etc + name + 'httpd.conf'
      end

      def apache_custom_config_path
        Path.etc + name + 'config'
      end

      def mime_types_path
        Path.etc + name + 'mime.types'
      end

      def httpd_path
        bin_path + 'httpd'
      end

      def apache_pid_file_path
        Path.var + name + 'run' + 'httpd.pid'
      end

      def htdocs_path
        return @htdocs_path if @htdocs_path
        if home_workspace_path.directory?
          home_workspace_htdocs_path.mkpath unless home_workspace_htdocs_path.exist?
          @htdocs_path = home_workspace_htdocs_path
        else
          @htdocs_path = Path.share + name + 'htdocs'
        end
        @htdocs_path
      end

      def user_config_path
        Path.etc + name + 'config'
      end

      def home_workspace_path
        Path.home + 'workspace'
      end

      def home_workspace_htdocs_path
        home_workspace_path + 'www'
      end

      def config_layout_file
        <<-EOF.unindent
          <Layout Autoparts>
              prefix:        #{prefix_path}
              exec_prefix:   #{prefix_path}
              bindir:        #{bin_path}
              sbindir:       #{bin_path}
              libdir:        #{lib_path}
              libexecdir:    ${exec_prefix}/modules
              mandir:        #{man_path}
              sysconfdir:    #{Path.etc}/apache2
              datadir:       #{share_path}/apache2
              installbuilddir: ${datadir}/build
              errordir:      ${datadir}/error
              iconsdir:      ${datadir}/icons
              htdocsdir:     #{htdocs_path}
              manualdir:     ${datadir}/manual
              cgidir:        #{Path.share}/apache2/cgi-bin
              includedir:    #{include_path}/apache2
              localstatedir: #{Path.var}/apache2
              runtimedir:    ${localstatedir}/run
              logfiledir:    ${localstatedir}/log
              proxycachedir: ${localstatedir}/proxy
              infodir:       #{info_path}
          </Layout>
        EOF
      end

      def apache_config
        <<-EOS.unindent
          # Generated by autoparts.
          # Put your custom changes into #{apache_custom_config_path}
          IncludeOptional #{apache_custom_config_path}/*.conf

          ServerRoot "#{prefix_path}"
          ServerName 127.0.0.1
          Listen 0.0.0.0:3000

          LoadModule access_compat_module modules/mod_access_compat.so
          LoadModule alias_module modules/mod_alias.so
          LoadModule auth_basic_module modules/mod_auth_basic.so
          LoadModule authn_core_module modules/mod_authn_core.so
          LoadModule authn_file_module modules/mod_authn_file.so
          LoadModule authz_core_module modules/mod_authz_core.so
          LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
          LoadModule authz_host_module modules/mod_authz_host.so
          LoadModule authz_user_module modules/mod_authz_user.so
          LoadModule autoindex_module modules/mod_autoindex.so
          LoadModule dir_module modules/mod_dir.so
          LoadModule env_module modules/mod_env.so
          LoadModule filter_module modules/mod_filter.so
          LoadModule headers_module modules/mod_headers.so
          LoadModule log_config_module modules/mod_log_config.so
          LoadModule mime_module modules/mod_mime.so
          LoadModule reqtimeout_module modules/mod_reqtimeout.so
          LoadModule rewrite_module modules/mod_rewrite.so
          LoadModule setenvif_module modules/mod_setenvif.so
          LoadModule status_module modules/mod_status.so
          LoadModule unixd_module modules/mod_unixd.so
          LoadModule version_module modules/mod_version.so

          <Directory />
            AllowOverride none
            Require all denied
          </Directory>

          DocumentRoot "#{htdocs_path}"
          <Directory "#{htdocs_path}">
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
          </Directory>

          <IfModule dir_module>
            DirectoryIndex index.html
          </IfModule>

          <Files ".ht*">
            Require all denied
          </Files>

          ErrorLog "#{Path.var + name + "log" + "error_log"}"
          LogLevel warn

          <IfModule mime_module>
            TypesConfig #{mime_types_path}
            AddType application/x-compress .Z
            AddType application/x-gzip .gz .tgz
          </IfModule>

          <IfModule ssl_module>
          SSLRandomSeed startup builtin
          SSLRandomSeed connect builtin
          </IfModule>

          <IfModule mpm_event_module>
            StartServers              1
            ServerLimit               1
            MinSpareThreads           5
            MaxSpareThreads           5
            ThreadLimit               5
            ThreadsPerChild           5
            MaxRequestWorkers         5
            MaxConnectionsPerChild   50
            ListenBackLog          1024
          </IfModule>
        EOS
      end
    end
  end
end
