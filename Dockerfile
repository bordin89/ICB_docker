############################################################
# Dockerfile to build the cICB Docker image
# Based on ubuntu:16.04.1
############################################################

# Set the base image to official ubuntu
FROM ubuntu:latest

# File Author / Maintainer
MAINTAINER Nicola Bordin <https://github.com/bordin89>

################## BEGIN INSTALLATION ######################
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN dpkg --add-architecture i386
RUN apt-get -yqq update 
RUN apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
RUN apt-get upgrade -y
RUN apt-get autoremove -y

# Install dependencies
RUN apt-get install -y libgnutls-dev
RUN apt-get install -y build-essential
RUN apt-get install -y wget
RUN apt-get install -y python-dev
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y libgl1-mesa-glx
RUN apt-get install -y ncbi-blast+
RUN apt-get install -y hhsuite
RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y openjdk-8-jre
RUN apt-get install -y blast2
RUN echo "export PERL_MM_USE_DEFAULT=1" >> /root/.bashrc
RUN cpan List::MoreUtils
#Install Programs and scripts
RUN curl -O http://pvcbacteria.org/tmhmm.tar.gz
RUN curl -O http://pvcbacteria.org/signalp.tar.gz
RUN git clone http://github.com/soedinglab/hh-suite
RUN git clone http://github.com/bordin89/ICB_docker
RUN curl -O http://pvcbacteria.org/interproscan.tar.gz 
RUN curl -O http://pvcbacteria.org/pdb70_14Sep16.tgz
RUN curl -O http://pvcbacteria.org/swissprot_compressed.tar.gz
RUN curl -O http://pvcbacteria.org/uniprot20_2013_03.tgz
RUN curl -O http://pvcbacteria.org/uniprot_sprot_reduced.dat.tar.gz
RUN curl -O http://pvcbacteria.org/psipred-3.5.tar.gz
RUN curl -O http://pvcbacteria.org/iupred-1.0.tar.gz
#Untar the programs and databases
RUN tar xzf interproscan.tar.gz
RUN tar xzf pdb70_14Sep16.tgz
RUN tar xzf swissprot_compressed.tar.gz
RUN tar xzf uniprot20_2013_03.tgz
RUN tar xzf uniprot_sprot_reduced.dat.tar.gz
RUN tar xzf psipred-3.5.tar.gz
RUN tar xzf iupred-1.0.tar.gz
RUN tar xzf tmhmm.tar.gz
RUN tar xzf signalp.tar.gz
#Cleanup of major db tarballs
RUN rm uniprot_sprot_reduced.dat.tar.gz
RUN rm interproscan.tar.gz
RUN rm pdb70_14Sep16.tgz
RUN rm uniprot20_2013_03.tgz
RUN rm swissprot_compressed.tar.gz
RUN rm psipred-3.5.tar.gz
RUN rm iupred-1.0.tar.gz
RUN rm tmhmm.tar.gz
RUN rm signalp.tar.gz
#Copy scripts in right place (add also alias to icb.py)
RUN cp /ICB_docker/HHPaths.pm /hh-suite/scripts/
RUN echo "export PATH=${PATH}:$HHLIB/bin:$HHLIB/scripts" >>/root/.bashrc 
RUN echo "export HHLIB=/hh-suite" >> /root/.bashrc
RUN echo "export IUPred_PATH=/iupred-1.0/" >> /root/.bashrc
RUN source /root/.bashrc
#Create folder for sequence analysis
RUN mkdir data
CMD cd data/

