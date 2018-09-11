# ICB

Welcome to ICB!

ICBdocker is a computational pipeline for protein annotation. Using an integrative approach, it allows the user to annotate several protein features such as domains, TMHs, disorder and identity through PSIBLAST, HHpred and InterProScan.

## Description of the modules

#### PSIBLAST (-psiblast)

The PSIBLAST performs an homology search of your protein on UniProt/SwissProt, which will provide information on similar hits with their Gene Ontology (GO), keywords and Enzyme Commission (EC) numbers. 

#### HHPred on PDB (-hhpred)

HHpred consists of several tools that allows to map your sequence on the Protein Data Bank (PDB). This modules provides information on proteins that are structurally similar to your proteins of interest, including information on function, GOs and EC numbers. You can obtain from the raw data the alignments for eventual modelization using tools like MODELLER.

#### HHblits on UniProt (-hhblits)

HHblits maps sequence domains on your proteins by creating a multiple sequence alignment based on the UniProt20 Hidden Markov Model Database. Secondary structure prediction of the sequence is added using PSIPRED, increasing the sensitivity of HHblits.

#### InterProScan (-ipr)

InterProScan searches for protein signatures on several databases, including PFAM, PANTHER and SUPERFAMILY among others, and results are parsed for KEGG-pathway entries and additional GO terms. 

#### SignalP (-sigp)

SignalP predicts the presence or absence of a signal peptide on your sequences, indicating the probability of them to be excreted. 

#### IUPRED (-iup)

IUPRED predicts the average level of disorder of your protein, giving information on the globular portions of the input proteins.

#### TMHMM (-tmh)

TMHMM predicts the presence and localization of TransMembrane Helices (TMHs) on the provided sequences, indicating with portions of the proteins are extracellular or periplasmic.


## The input and the output

The input: your sequences in a single multiFASTA file.
### EACH FASTA HEADER NEEDS TO BE EITHER IN A UNIPROT OR GENBANK FORMAT!!

The output: DataTables to browse your data (example: http://pvcbacteria.org/mywiki/pipeline-tables/Blastopirellula_marina.html), 

![alt text](http://pvcbacteria.org/bay042f4.png)

a tabular-separated-values file (Can be imported into R or Excel).

![alt text](http://pvcbacteria.org/bay_tsv.png)

and raw data from the predictors.





## Using ICB through Docker

### System Requirements

ICB pipeline runs on every system architecture and OS supported by Docker. 
The pipeline supports multicore systems. 
#### While the Docker container can run even on a laptop, the pipeline requires a discrete amount of hard disk space (~130GB) due to databases size and was built with server-side processing in mind.
#### Downloading through a high-speed broadband connection is strongly suggested.

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

Enter the folder containing your data.

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

Modules and related command-line parameters

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
