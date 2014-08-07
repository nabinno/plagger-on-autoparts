# Copyright (c) 2013-2014 Irrational Industries Inc. d.b.a. Nitrous.IO
# This software is licensed under the [BSD 2-Clause license](https://raw.github.com/nitrous-io/autoparts/master/LICENSE).

module Autoparts
  module Packages
    class CouchDB < Package
      name 'couchdb'
      version '1.5.1'

      description "CouchDB: A Database for the Web"

      category Category::DATA_STORES

      source_url 'http://www.apache.org/dist/couchdb/source/1.5.1/apache-couchdb-1.5.1.tar.gz'

      source_sha1 '5340c79f8f9e11742b723f92e2251d4d59b8247c'

      source_filetype 'tar.gz'

      depends_on 'spidermonkey'
      depends_on 'erlangr16'

      def compile
        Dir.chdir('apache-couchdb-1.5.1') do
          args = [
            "--prefix=#{prefix_path}",
            "--with-js-include=#{get_dependency("spidermonkey").include_path}/js" ,
            "--with-js-lib=#{get_dependency("spidermonkey").lib_path}"
          ]

          execute './configure', *args
          execute 'make'
        end
      end

      def install
        Dir.chdir('apache-couchdb-1.5.1') do
          execute 'make install'
        end
      end

      def couchdb_conf_path
        prefix_path + 'etc/couchdb/default.ini'
      end

      def couchdb_daemon_path
        prefix_path + 'etc/init.d/couchdb'
      end

      def couchdb_daemon_conf_path
        prefix_path + 'etc/default/couchdb'
      end

      def post_install
        execute 'sed', '-i', "s|bind_address = 127.0.0.1|bind_address = 0.0.0.0|g", couchdb_conf_path
        execute 'sed', '-i', "s|COUCHDB_USER=couchdb||g", couchdb_daemon_conf_path
      end

      def start
        execute couchdb_daemon_path, 'start'
      end

      def stop
        execute couchdb_daemon_path, 'stop'
      end

      def running?
        !!system(couchdb_daemon_path.to_s, 'status', out: '/dev/null', err: '/dev/null')
      end

      def tips
        <<-STR.unindent
          To start the server:
            $ parts start couchdb

          To stop the server:
            $ parts stop couchdb
        STR
      end
    end
  end
end
