#!/usr/bin/env bash

basepath=$(cd `dirname $0`; pwd)

if [ -z $@ ]; then
    version='10.6.8'
else
    version="$@"
fi

mkdir apps
app_name="mariadb"
app_dir="$app_name-$version"
app_pkg_name="$app_name-$version"
MAKE_OPT="cmake . -DCMAKE_INSTALL_PREFIX=$basepath/apps/$app_dir -DMYSQL_DATADIR=$basepath/apps/$app_dir/data -DSYSCONFDIR=$basepath/apps/$app_dir/data -DMYSQL_USER=mariadb -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITHOUT_MROONGA_STORAGE_ENGINE=1 -DWITH_DEBUG=0 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_LIBWRAP=0 -DENABLED_LOCAL_INFILE=1 -DMYSQL_UNIX_ADDR=/data/mariadb/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci"

_make_install(){
    wget -c https://mirrors.gigenet.com/mariadb/$app_name-$version/source/$app_name-$version.tar.gz
    tar xf $app_pkg_name.tar.gz
    cd $app_dir && $MAKE_OPT && make -j $(nproc) && make install 
    cp support-files/wsrep.cnf $basepath/$app_dir/
    cp support-files/mysql.server $basepath/$app_dir/mysqld
    cd .. && tar Jcvf $app_pkg_name.tar.xz apps/$app_pkg_name
}

_make_install "$@"

gh release delete ${app_pkg_name} -y

# gh release create ${PKGNAME} ./*.tar.xz --title "${PKGNAME} (beta)" --notes "this is a nginx beta release" --prerelease
gh release create ${app_pkg_name} $app_pkg_name.tar.xz --title "${app_pkg_name}" --notes "this is a make mariadb release" --prerelease
