library(tidiverse)
### New TE content for TE_data ####
TEs_SW2 <- read.table("TEs_SW_custom.txt", fill = TRUE, 
                      col.names = c("Sample", "Counts", "Aligned_bp", "Contig", "Hit_length", "Annotation", "Class", "Contig_length"))
TEs_SW2 <- filter(TEs_SW2, TEs_SW2$Contig_length != "NA")
TEs_SW2 <- filter(TEs_SW2, TEs_SW2$Class != "Satellite")
TEs_SW2 <- filter(TEs_SW2, TEs_SW2$Class != "Low_complexity")
TEs_SW2 <- filter(TEs_SW2, TEs_SW2$Class != "Simple_repeat")
TEs_SW2 <- filter(TEs_SW2, TEs_SW2$Class != "rRNA")
TEs_SW2 <- filter(TEs_SW2, TEs_SW2$Counts > 10)


unique(TEs_SW2$Class)
TE_gc_2 <- TEs_SW2 %>% group_by(Sample) %>% summarise(TotReads = sum(Counts), GenCont = sum(Aligned_bp)/(1091184475*0.3)) 
TE_gc_2$Sample <- TE_gc_2$Sample %>% str_replace("no_mt.fastq.gz", "") 
