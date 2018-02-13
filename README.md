# cICB_pipeline

Welcome to cICB!

cICB is a computational pipeline for protein annotation. Using an integrative approach, it allows the user to annotate several protein features such as domains, TMHs, disorder and identity through PSIBLAST, HHpred and InterProScan.

The input: your sequences in a single multiFASTA file.

The output: DataTables to browse your data (example: http://pvcbacteria.org/mywiki/pipeline-tables/Chlamydia_trachomatis.html), a tabular output and raw data from the predictors.




## Using cICB through Docker

### System Requirements

cICB pipeline runs on every system architecture and OS supported by Docker. 
The pipeline supports multicore systems. While the Docker container can run even on a laptop, the pipeline requires a discrete amount of hard disk space (~130GB) due to databases size and was built with server-side processing in mind.
Downloading through a high-speed broadband connection is strongly suggested.

The setup is quite easy.

1. Install Docker for your system.
2. Pull the cICB image from DockerHub.
3. Point the container to your data and run it.
4. Run cICB.
5. Enjoy!

### 1. Install Docker for your system 

Get Docker for your OS from https://store.docker.com/search?type=edition&offering=community.

### 2. Pull the cICB image from DockerHub

To pull the image

```
docker pull bordin89/icb
```

Due to the modular approach, you need to install one, a few or all the following tools (according to your needs).

-PSIBLAST

-HHsuite

-InterProScan

-PSIPRED

-IUPRED

-TMHMM

The config.txt file

A config.txt file is included in the ICB package.
After installing the tools required by ICB, please modify the config.txt file according to your installation paths and the amount of cores available for BLAST and HHblits/HHpred.
