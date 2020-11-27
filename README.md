# e-cervelet
e-cervelet is a pipeline that allows you to make first-order and second-order analysis on the cerebellum thanks the SUIT functions. All the code use a specific database available here : https://openneuro.org/datasets/ds002105/versions/1.1.0

<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/e-cervelet.png height="300" width="300">
</div>

# Introduction 
## Scientific context for the developement of this code : 
This code was written at the Institut des Neurosciences de la Timone (INT Marseille France) for a team of researchers interested in the analysis of fmri scans of the cerebellar. The aims of this codes is to propose a fully automatic first level analysis and second level analysis for dataset specific to the cerebellar activities. For that, the code use the functions of the Suit toolbox, a toolbox developed by the diedrichsen lab for the analysis of the cerebellar. 


## the database used : Multi Domain Task Battery
https://openneuro.org/datasets/ds002105/versions/1.1.0


# Run the code

## Work environement 
this project was developped on a personal laptop Dell Latitude 3500. \
OS : Ubuntu 18.04.5 LTS 64 bits \
RAM : 31,3 Gio \
processor : Intel® Core™ i7-8565U CPU @ 1.80GHz × 8 \
graphic card :  Intel® UHD Graphics 620 (WHL GT2) \
GNOME 3.28.2 \
Stockage capabilities : 1,0 To \

## dependencies
MatlabR2020a with the spm12 toolbox and suit toolbox.
MatlabR2020a : it should work with R2018 and higher version but i haven't checked yet \ 
spm12 \
Suit \

### how to install SPM
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

### how to install Suit

official website of suit : http://www.diedrichsenlab.org/imaging/suit.htm \
go to the download page :http://www.diedrichsenlab.org/imaging/suit_download.htm \

you need to register, once the registration is done, download the zip file. \
Once it's done, unszip the file and place the uncompressed files in your matlab/toolbox/suit/toobox/path. \
Read the read me of suit for more details. \

## Illustration of the pipeline

<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/flow-chart.png>
</div>

## Descriptions of the codes : 

first_analysis.m : function with all the processes you could run for your first order analysis \
second_analysis.m : function with all the processes you could run for your second order analysis \
This two function are orgonised with a swhitch case stylte, each corresponding to a a stage of the pipeline. \

main_first_analysis.m: file where you loop your processes throught the subjects and where you define the stage you need \
main_second_analysis.m: same as previous but for second order analysis \

# result Second Level Analysis ( 18 subjects )


<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/report_second_level/screen-lvl2_01.png
</div>

<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/report_second_level/screen-lvl2_02.png
</div>

<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/report_second_level/screen-lvl2_03.png
</div>

# Dentate nuclei

## Illustration of the pipeline 



## Getting the mean Bold image

The mean bold image is calculate thanks to the function get_meanBold.m

## mask extraction

The mask of the dentate nuclei is extracted from the mean bold image thanks to tools of MRIcron.
The tools used is the 3D brush. I localise the dentate nuclei manualy according to its hypointensity on the axial view. I place the centerof the brush on the center of the dentate nuclei. I set the parameters manually according to how the mask change.

<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/setting_dentate_roi.png height="700" width="700">
</div>

Test with one subject

<div align="center">
  <img src=https://github.com/MaximeDdnn/e-cervelet/blob/main/test_dentate_roi.png
</div>t : 





