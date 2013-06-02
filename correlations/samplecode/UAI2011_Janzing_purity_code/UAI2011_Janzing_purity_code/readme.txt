Matlab implementation of the paper: 
"Detecting low-complexity unobserved causes"
Dominik Janzing, Eleni Sgouritsa, Oliver Stegle, Jonas Peters, Bernhard Schölkopf. UAI 2011.

*** LICENSE ***

This project is licensed under (Free)BSD License.
Parts of the code are licensed under the GNU Public License version 3.
Each source code file contains notes about which license applies.

*** DIRECTORY STRUCTURE ***

./experiments
    Contains the code to produce the figures presented in the paper.
	Licensed under FreeBSD.
	
./data
    Contains the SNP data.
	
./purity_code
	Contains the main code of the paper.
	Licensed under FreeBSD apart from the files auroc.m and roc.m that are licensed under the terms of the GNU General Public License.

./exportfig 
    Makes exporting figures from MatLab easy.

./results
	Produced figures of the experiments are saved in this folder.
	
*** REQUIREMENTS ***
	
The code is written in Matlab and needs Matlab's Statistics Toolbox.

*** REPRODUCING FIGURES OF THE PAPER ***

The exp_ files contained in the /experiments folder correspond to the experiments performed in the paper.
Run first the startup file and then the following files to reproduce the results of the paper:

- exp_simulatedSNPs: for Fig. 3(a)
- exp_simulatedSNPs_Conf_Reconstruction: for Fig. 3(b-d)
- exp_realSNPs_model1: for Fig. 4
- exp_realSNPs_model2: for Fig. 5

The output will be stored in the results folder.

*** CITATION ***

If you use this code, please cite the following paper:
Dominik Janzing, Eleni Sgouritsa, Oliver Stegle, Jonas Peters, Bernhard Schölkopf.
"Detecting low-complexity unobserved causes"
UAI 2011

*** PROBLEMS / QUESTIONS ***

If you have problems or questions, please do not hesitate to send an email:
eleni.sgouritsa ---at--- tuebingen.mpg.de
