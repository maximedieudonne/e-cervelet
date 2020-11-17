# e-cervelet
e-cervelet is a pipeline that allows you to make first-order and second-order analysis on the cerebellum thanks the SUIT functions. All the code use a specific database available here : https://openneuro.org/datasets/ds002105/versions/1.1.0

<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/logo_ecervelet.png height="350" width="300">
</div>

# Introduction 
## Scientific context for the developement of this code : 

## the database used : Multi Domain Task Battery

# Work environement 
this project was developped on a personal laptop Dell Latitude 3500. \
OS : Ubuntu 18.04.5 LTS 64 bits \
RAM : 31,3 Gio \
processor : Intel® Core™ i7-8565U CPU @ 1.80GHz × 8 \
graphic card :  Intel® UHD Graphics 620 (WHL GT2) \
GNOME 3.28.2 \
Stockage capabilities : 1,0 To \

MatlabR2020a with the spm12 toolbox and suit toolbox.

# Run the code
## dependencies
MatlabR2020a : it should work with R2018 and higher version but i haven't checked yet\ 
spm12 \
Suit \

## how to install SPM
official website of spm12 : https://www.fil.ion.ucl.ac.uk/spm/software/spm12/ \
On the oficial website, go to the sub-window "download", here is the info i specify for this project: \
SPM vesion : 
Select SPM version required: spm12
Additional info : (optional)
Which imaging modality will you mainly examine with SPM? : fmri
Which operating system will you run SPM onto? : Linux
Which MATLAB version will you be using? : r2020a
Additional Comments : i add no additional comments

Once SPM is downloaded, i have to add the path of spm on Matlab. \
For that, open Matlab >> window 'HOME' >> subwindow 'environement' >> 'set Path' \
then, select the right path that points your SPM folder.

## how to install Suit

official website of suit : http://www.diedrichsenlab.org/imaging/suit.htm \
go to the download page :http://www.diedrichsenlab.org/imaging/suit_download.htm \

you need to register, once the registration is done, download the zip file. \
Once it's done, unszip the file and place the uncompressed files in your matlab/toolbox/suit/toobox/path. \
Read the read me of suit for more details. \

## Descriptions of the codes : 

first_analysis.m : function with all the process you may run for your  \
second_analysis.m : \
main_first_analysis.m: \
main_second_analysis.m: \





