# SW_TE_dynamics
Data and analysis code for the exploration of TE dynamics in the Seychelles warbler

The bioinformatic pipeline to curate the genomic data followed Lee et al., 2026a: https://www.biorxiv.org/content/10.64898/2026.04.16.719046v1

The genomic data can be found here: https://zenodo.org/records/14717915

The bioinformatic pipeline can be found in the repository associated with that preprint: https://zenodo.org/records/18500278

The scripts "Trimmomatic.sh", "BWA_script.sh", "clean_bam.sh", "SNPs_SW.sh" and "PLINK_homozyg.sh" are scripts used in the bioinformatic pipeline used for this analysis, but some corrections, including SNP imputation are presented in Lee et al., 2026a.

Finally, the inbreeding coefficients used in the study, found in "Inbreeding_final.csv" were obtained following Lee at al., (2026b). The pipeline for obtaining those coefficients can be found here: https://github.com/kiran-lee/InbreedingDepressionSeychellesWarbler 

To obtain genomic TE content per individual, I ran the "mt_removal.sh" on the fastq files of the genomic data collected for the Seychelles warbler. The mictochondrial DNA removal is important to not confound TE annotation, and the resulting fastq files were deposited in a Samples directory. I used the "dnaPipeTE_cmd_array.sh" script to obtain individual detialed TE content by comparing reads to my curated TE library "reduced.fasta". I used the "Obtain_GTEC.R" script to obtain individual GTEC.

After wrangling the data from the Seychelles warbler database, obtaining inbreeding coefficients and individual GTEC, I arranged individuals in parent-offspring trios using the "PedigreeCorrected.xlsx" file and finally obtained the main dataset for analysis named "custom_TE_gen_data_Ch2.csv". The statistical analysis and figures are produced by the "Ch2_analysis_script.R"

Preprints which use the dataset:
Lee, K. G. L., Bartleet-Cross, C., Dong, S., González-Mollinedo, S., Pinto, A., Lee, C. Z., Sparks, A., van der Velde, M., Manarrelli, M.-E., Holden, T., of Environment, S. D., Tucker, R., Maher, K. H., Hipperson, H., Slate, J., Komdeur, J., Richardson, D. S., Dugdale, H. L., & Burke, T. (2026a). A Seychelles warbler genomic toolkit. BioRxiv. https://doi.org/10.64898/2026.04.16.719046

Lee, K. G. L., Pinto, A., Dong, S., González-Mollinedo, S., Lee, C. Z., Slate, J., Komdeur, J., Richardson, D. S., Dugdale, H. L., & Burke, T. (2026b). Inbreeding depression by polygenic load following a severe population bottleneck. BioRxiv. https://doi.org/10.64898/2026.06.03.729877

A complete repository of the PhD thesis can be found here: 

For any additional questions: sergiogonmoll[at]gmail.com or h.l.dugdale[at]rug.nl
