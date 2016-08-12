pkg_name=national-parks
pkg_description="A sample JavaEE Web app deployed in the Tomcat8 package"
pkg_origin=billmeyer
pkg_version=0.1.3
pkg_maintainer="Bill Meyer <bill@chef.io>"
pkg_license=('Apache-2.0')
pkg_source=https://github.com/billmeyer/national-parks
pkg_deps=(core/tomcat8 core/git core/maven chefops/mongodb)
pkg_expose=(8080)

do_begin()
{
    build_line "do_begin() ====================================================="
    do_default_begin
}

do_end()
{
    build_line "do_end() ======================================================="
    do_default_end
}

do_check()
{
    build_line "do_check() ====================================================="
    do_default_check
}

do_unpack()
{
    build_line "do_unpack() ===================================================="
    return 0
#    do_default_unpack
}

do_prepare()
{
    build_line "do_prepare() ==================================================="
    do_default_prepare
}

do_strip()
{
    build_line "do_strip() ====================================================="
    do_default_strip
}

# Override do_download() to pull our source code from GitHub instead
# of downloading a tarball from a URL.
do_download()
{
    build_line "do_download() =================================================="
    cd ${HAB_CACHE_SRC_PATH}

    build_line "\$pkg_dirname=${pkg_dirname}"
    build_line "\$pkg_filename=${pkg_filename}"

    if [ -d "${pkg_dirname}" ];
    then
        rm -rf ${pkg_dirname}
    fi

    mkdir ${pkg_dirname}
    cd ${pkg_dirname}
    GIT_SSL_NO_VERIFY=true git clone --branch v${pkg_version} https://github.com/billmeyer/national-parks.git
    return 0
}

do_clean()
{
    build_line "do_clean() ===================================================="
    build_line "\$HAB_CACHE_SRC_PATH/\$pkg_dirname=${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
}


do_build()
{
    build_line "do_build() ===================================================="

    # Ant requires JAVA_HOME to be set, and can be set via:
    export JAVA_HOME=$(hab pkg path core/jdk8)

    cd ${HAB_CACHE_SRC_PATH}/${pkg_dirname}/${pkg_filename}
    mvn package
}

do_install()
{
    build_line "do_install() =================================================="

    # Our source files were copied over to the HAB_CACHE_SRC_PATH in do_build(),
    # so now they need to be copied into the root directory of our package through
    # the pkg_prefix variable. This is so that we have the source files available
    # in the package.

    local source="${HAB_CACHE_SRC_PATH}/${pkg_dirname}/${pkg_filename}"
    webapps_dir="$(hab pkg path core/tomcat8)/tc/webapps"
    cp ${source}/target/${pkg_filename}.war ${webapps_dir}/

    # Copy our seed data so that it can be loaded into Mongo using our init hook
    cp ${source}/national-parks.json $(hab pkg path billmeyer/national-parks)/
}

# We verify our own source code because we cloned from GitHub instead of
# providing a SHA-SUM of a tarball
do_verify()
{
    build_line "do_verify() ==================================================="
    return 0
}