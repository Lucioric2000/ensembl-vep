###################################################
# Stage 1 - docker container to build ensembl-vep #
###################################################
#FROM ubuntu:18.04 as builder
FROM ubuntu:16.04

# Update aptitude and install some required packages
# a lot of them are required for Bio::DB::BigFile
ENV BRANCH master
RUN apt-get update && apt-get -y install \
    apache2 \
    build-essential \
    cpanminus \
    curl \
    git \
    libmysqlclient-dev \
    libpng-dev \
    libssl-dev \
    locales \
    manpages \
    mysql-client \
    openssl \
    perl \
    perl-base \
    unzip \
    vim \
    wget

# install ensembl dependencies
RUN cpanm DBI DBD::mysql

# create vep user
RUN useradd -r -m -U -d /opt/vep -s /bin/bash -c "VEP User" -p '' vep
RUN usermod -a -G sudo vep
USER vep
ENV OPT /opt/vep
WORKDIR $OPT

# clone git repositories
RUN mkdir -p src
WORKDIR $OPT/src
RUN git clone https://github.com/Ensembl/ensembl.git
RUN git clone https://github.com/Ensembl/ensembl-vep.git

# get VEP dependencies
WORKDIR $OPT/src
RUN ensembl-vep/travisci/get_dependencies.sh
ENV PERL5LIB $PERL5LIB:$OPT/src/bioperl-live-release-1-6-924
ENV KENT_SRC $OPT/src/kent-335_base/src
ENV HTSLIB_DIR $OPT/src/htslib
ENV MACHTYPE x86_64
ENV CFLAGS "-fPIC"
ENV DEPS $OPT/src

# Working directory
WORKDIR $OPT_SRC

# Clone/download repositories/libraries
RUN if [ "$BRANCH" = "master" ]; \
    then export BRANCH_OPT=""; \
    else export BRANCH_OPT="-b $BRANCH"; \
    fi && \
    # Get ensembl cpanfile in order to get the list of the required Perl libraries
    wget -q "https://raw.githubusercontent.com/Ensembl/ensembl/$BRANCH/cpanfile" -O "ensembl_cpanfile" && \
    # Clone ensembl-vep git repository
    git clone $BRANCH_OPT --depth 1 https://github.com/Ensembl/ensembl-vep.git && chmod u+x ensembl-vep/*.pl && \
    # Clone ensembl-variation git repository and compile C code
    git clone $BRANCH_OPT --depth 1 https://github.com/Ensembl/ensembl-variation.git && \
    mkdir var_c_code && \
    cp ensembl-variation/C_code/*.c ensembl-variation/C_code/Makefile var_c_code/ && \
    rm -rf ensembl-variation && \
    chmod u+x var_c_code/* && \
    # Clone bioperl-ext git repository - used by Haplosaurus
    git clone --depth 1 https://github.com/bioperl/bioperl-ext.git && \
    # Download ensembl-xs - it contains compiled versions of certain key subroutines used in VEP
    wget https://github.com/Ensembl/ensembl-xs/archive/2.3.2.zip -O ensembl-xs.zip && \
    unzip -q ensembl-xs.zip && mv ensembl-xs-2.3.2 ensembl-xs && rm -rf ensembl-xs.zip && \
    # Clone/Download other repositories: bioperl-live is needed so the cpanm dependencies installation from the ensembl-vep/cpanfile file takes less disk space
    ensembl-vep/travisci/get_dependencies.sh && \
    # Only keep the bioperl-live "Bio" library
    mv bioperl-live bioperl-live_bak && mkdir bioperl-live && mv bioperl-live_bak/Bio bioperl-live/ && rm -rf bioperl-live_bak && \
    ## A lot of cleanup on the imported libraries, in order to reduce the docker image ##
    rm -rf Bio-HTS/.??* Bio-HTS/Changes Bio-HTS/DISCLAIMER Bio-HTS/MANIFEST* Bio-HTS/README Bio-HTS/scripts Bio-HTS/t Bio-HTS/travisci \
           bioperl-ext/.??* bioperl-ext/Bio/SeqIO bioperl-ext/Bio/Tools bioperl-ext/Makefile.PL bioperl-ext/README* bioperl-ext/t bioperl-ext/examples \
           ensembl-vep/.??* ensembl-vep/docker \
           ensembl-xs/.??* ensembl-xs/TODO ensembl-xs/Changes ensembl-xs/INSTALL ensembl-xs/MANIFEST ensembl-xs/README ensembl-xs/t ensembl-xs/travisci \
           htslib/.??* htslib/INSTALL htslib/NEWS htslib/README* htslib/test && \
    # Only keep needed kent-335_base libraries for VEP - used by Bio::DB::BigFile (bigWig parsing)
    mv kent-335_base kent-335_base_bak && mkdir -p kent-335_base/src && \
    cp -R kent-335_base_bak/src/lib kent-335_base_bak/src/inc kent-335_base_bak/src/jkOwnLib kent-335_base/src/ && \
    cp kent-335_base_bak/src/*.sh kent-335_base/src/ && \
    rm -rf kent-335_base_bak

# install bioperl-ext, faster alignments for haplo
WORKDIR $OPT/src
RUN git clone https://github.com/bioperl/bioperl-ext.git
WORKDIR bioperl-ext/Bio/Ext/Align/
RUN perl -pi -e"s|(cd libs.+)CFLAGS=\\\'|\$1CFLAGS=\\\'-fPIC |" Makefile.PL

# install perl dependencies
WORKDIR $OPT/src
RUN cpanm --installdeps --with-recommends --notest --cpanfile ensembl/cpanfile .
RUN cpanm --installdeps --with-recommends --notest --cpanfile ensembl-vep/cpanfile .

# configure locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# switch back to vep user
USER vep

# update bash profile
RUN echo >> $OPT/.profile && \
    echo PATH=$OPT/src/ensembl-vep:\$PATH >> $OPT/.profile && \
    echo export PATH >> $OPT/.profile

# setup environment
ENV PATH $OPT/src/ensembl-vep:$PATH

# run INSTALL.pl
WORKDIR $OPT/src/ensembl-vep
RUN chmod u+x *.pl
RUN ./INSTALL.pl -a a -l