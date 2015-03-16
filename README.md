## Overview

The microarray data analysis realm is ever growing through the development of various tools, open source and commercial. However there is absence of predefined rational algorithmic analysis workflows or batch standardized processing to incorporate all steps, from raw data import up to the derivation of significantly differentially expressed gene lists. This absence obfuscates the analytical procedure and obstructs the massive comparative processing of genomic microarray datasets. Moreover, the solutions provided, heavily depend on the programming skills of the user, whereas in the case of GUI embedded solutions, they do not provide direct support of various raw image analysis formats or a versatile and simultaneously flexible combination of signal processing methods.

Gene ARMADA (Automated Robust MicroArray Data Analysis) is a MATLAB implemented platform with a GUI. This suite integrates all steps of microarray data analysis including automated data import, noise correction and filtering, normalization, statistical selection of differentially expressed genes, clustering, classification and annotation. In its current version, Gene ARMADA fully supports 2 coloured cDNA arrays, Affymetrix oligonucleotide arrays, Agilent 1-channel arrays plus custom arrays for which experimental details are given in tabular form (Excel spreadsheet, comma separated values, tab-delimited text formats). It also supports the analysis of already processed results through its versatile import editor. Besides being fully automated, Gene ARMADA incorporates numerous functionalities of the Statistics and Bioinformatics Toolboxes of MATLAB. In addition, it provides numerous visualization and exploration tools plus customizable export data formats for seamless integration by other analysis tools or MATLAB, for further processing.

Gene ARMADA provides a highly adaptable, integrative, yet flexible tool which can be used for automated quality control, analysis, annotation and visualization of microarray data, constituting a starting point for further data interpretation and integration with numerous other tools.

See also http://www.grissom.gr/armada/

Download Gene ARMADA MatLab routines [https://drive.google.com/folderview?id=0Bzc-2ewV6Zf3bkxpX1dhNWJBTXM&usp=sharing here] and as a stand-alone application [https://drive.google.com/uc?id=0Bzc-2ewV6Zf3SUZSREo5a3htaEE&export=download here]

Find affymetrix libraries and probe sequences at http://217.128.147.202/affy

## Citation

If you use ARMADA for your study, please cite the following (PubMed ID: [http://www.ncbi.nlm.nih.gov/pubmed/19860866 19860866])

Aristotelis Chatziioannou, Panagiotis Moulos and Fragiskos N Kolisis:
*Gene ARMADA: an integrated multi-analysis platform for microarray data implemented in MATLAB*
_BMC Bioinformatics 2009, 10:354_.

Please do not forget citing the software if you use it to analyze your data. It is the only reward for us and the strongest motivation to keep maintaining, upgrading and enriching it.

## Latest news
## version 2.3.6
### Major updates
Fixed a bug in probe summarization that caused non-reproducible results under circumstances.
Fixed a bug that allowed Analysis objects with non-normalized data to be included in the list of Analyses to be subjected to statistical analysis, causing a crash under circumstances.
### Minor updates
Added additional information in the Analysis report, containing information about the probe summarization method.
Fixed proper display of program version.
A reperformed statistical analysis with no results is now an empty list instead of keeping the previous result.
## version 2.3.5
## Major updates
Added the option to perform kNN missing value imputation in the gene space instead of only the sample space (imputation distance calculated also on rows instead of only columns of the data matrix). 
## version 2.3.4
## Minor updates
Fixed a bug in Fuzzy C-means clustering that prevented the export of clustering results when clustering replicates 
## version 2.3.3
### Major updates
Added the ability to choose the type of defining final poor spots in 2-channel arrays: common poor spots from both channels (default) or the union of poor spots from any channel
Updated the Batch Programmer to support the above change
### Minor updates
Fixed minor bug with signal-to-noise filtering threshold
## version 2.3.2
### Minor updates
Fixed a parameters bug in Normalization editor window for 2-colour arrays
Fixed a method selection bug in BEst.m
### version 2.3.1
### Major updates
Added more controls to BEst background correction method for in 2-colour arrays, specifically control over the percentile and the loess span of the respective methods
Updated the Batch Programmer for two-colour arrays to support BEst
### Minor updates
Updated available ImaGene flags
## version 2.3.0
### Major updates
Added a novel method (BEst) for background correction in 2-colour arrays
Added full support for 2-channel platforms where only one channel has been used for hybridization
Added the possibility of intensity summarization of probes with the same names before or after normalization
Added full support for Illumina microarrays (import and process of data exported from BeadStudio) supporting Rank Invariant and Quantile normalization
Added a second, less strict option in Trust Factor filtering
Gene ARMADA moved to google code!
### Minor updates
Several smaller bug fixes
