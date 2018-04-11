# ICB_pipeline

Welcome to ICB!

ICB is a computational pipeline for protein annotation. Using an integrative approach, it allows the user to annotate several protein features such as domains, TMHs, disorder and identity through PSIBLAST, HHpred and InterProScan.

The input: your sequences in a single multiFASTA file.

The output: DataTables to browse your data (example: http://pvcbacteria.org/mywiki/pipeline-tables/Chlamydia_trachomatis.html), a tabular output and raw data from the predictors.




## Using ICB through Docker

### System Requirements

ICB pipeline runs on every system architecture and OS supported by Docker. 
The pipeline supports multicore systems. While the Docker container can run even on a laptop, the pipeline requires a discrete amount of hard disk space (~130GB) due to databases size and was built with server-side processing in mind.
Downloading through a high-speed broadband connection is strongly suggested.

The setup is quite easy.

1. Install Docker for your system.
2. Pull the ICB image from DockerHub.
3. Point the container to your data and run it.
4. Run ICB.
5. Enjoy!

### 1. Install Docker for your system 

Get Docker for your OS from https://store.docker.com/search?type=edition&offering=community.

### 2. Pull the ICB image from DockerHub

To pull the image

```
docker pull bordin89/icb
```
### 3. Point the container to your data and run it.

The container contains already all the tools and databases. You'll need to point the folder containing your data to the folder "/data/" . Run the container using the command

```
docker run -it -v /path/in/my/computer/to/data:/data/ bordin89/icb
```
an example:
```
docker run -it -v /cluster/data/proteomes/e_coli_proteome.fasta:/data/ bordin89/icb
```

### 4. Run ICB

Enter your folder containing your data.

```
cd data/
```
To see the main script helper, type

```
python /ICB_docker/icb.py -h
```

You can run all the modules at once, or just the ones you need.

```
python /ICB_docker/icb.py -i my_sequences.fasta -all
python /ICB_docker/icb.py -i my_sequences.fasta -tmh -hhblits -hhpred -iup -psiblast
```

Modules and command-line parameters

>PSIBLAST (-psiblast)

>HHPred on PDB (-hhpred)

>HHblits on UniProt (-hhblits)

>InterProScan (-ipr)

>SignalP (-sigp)

>IUPRED (-iup)

>TMHMM (-tmh)

### The config.txt file for multicore processing

A config.txt file is located at ``` /ICB_docker/config.txt ```. Modify the "cpus = 2" parameter according to your machine.

Here you can set the amount of cores available for PSIBLAST, HHpred and HHblits. 

The same parameter needs to be passed to the container before launch.
```
docker run -it -v /cluster/data/e_coli_proteome.fasta:/data/ --cpus 10 bordin89/icb
```

### Enjoy!

Your data is available in the same input folder. Here you can find a tsv (tab-separated-values) and the HTML with the 

DataTables. You can also find the raw data for the predictors organized in archives and folders.
