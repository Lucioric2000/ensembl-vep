conda_home=${CONDA_PREFIX:-/root/conda}
sudo apt install gcc g++ git make
rm -rf ensembl-vep
git clone https://github.com/ensembl/ensembl-vep
cd ensembl-vep && git checkout release/102
echo now in $(pwd)
function conda_install(){
	#Install the Miniconda Python pachages manager
	echo "Next, the Miniconda package will be downloaded and installed at the folder ${conda_home}."
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
	chmod +x Miniconda3-latest-Linux-x86_64.sh
	sudo bash Miniconda3-latest-Linux-x86_64.sh -p ${conda_home} -u -b
	rm Miniconda3-latest-Linux-x86_64.sh
	${conda_home}/condabin/conda init bash
	#Make the updated shell path available in this session:
	source ~/.bashrc
	#source ${conda_home}/bin/activate ${conda_env}
	echo "Conda was installed in the ${conda_home} folder. The environment that will be used is ${conda_env}."

}
conda_install
${conda_home}/bin/conda remove --all -n ensembl-vep
${conda_home}/bin/conda create -y -n ensembl-vep
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda perl-dbi perl-dbd-mysql perl-archive-zip perl-json perl-set-intervaltree perl-bio-bigfile
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda curl htslib perl-bio-db-hts libcurl libssh2 perl-base perl-cgi perl-compress-raw-bzip2
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda perl-encode perl-html-parser perl-html-tagset perl-io-compress perl-scalar-list-utils
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda perl-sereal perl-sereal-decoder perl-sereal-encoder perl-xsloader unzip
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda perl-module-build perl-bioperl perl-try-tiny perl-test-exception perl-test-warnings
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda perl-lwp-simple perl-http-tiny perl-carp perl-test-most gxx_linux-64 gfortran_linux-64
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda perl-db-file perl-graph perl-test-memory-cycle perl-xml-dom perl-xml-dom-xpath
${conda_home}/bin/conda install -n ensembl-vep -y -c bioconda perl-xml-libxml perl-xml-parser perl-xml-twig perl-list-moreutils
source ${conda_home}/bin/activate ensembl-vep && perl INSTALL.pl --NO_HTSLIB
