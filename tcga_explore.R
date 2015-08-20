# https://wiki.nci.nih.gov/display/TCGA/Mutation+Annotation+Format+%28MAF%29+Specification

library(data.table)
library(reshape2)
library(class)
setwd("~/Documents/DataStoreRetrieval")
## merge tcga with 1000genomes
tcga1<-read.table("genome.wustl.edu_BRCA.IlluminaGA_DNASeq.Level_2.2.0.0.maf",
                 row.names = NULL,sep = "\t", skip = 1)
tcga2 <- read.table("genome.wustl.edu_BRCA.IlluminaGA_DNASeq.Level_2.3.2.0.somatic.maf",
                    row.names = NULL,sep = "\t", skip = 1)
tcga3 <- read.table("genome.wustl.edu_BRCA.IlluminaGA_DNASeq.Level_2.5.1.0.somatic.maf",
                    row.names = NULL,sep = "\t", skip = 1)
tcga4 <- read.table("genome.wustl.edu_BRCA.IlluminaGA_DNASeq.Level_2.5.3.0.somatic.maf",
                    row.names = NULL,sep = "\t", skip = 1)


# Fix shifted column names
old_names <- names(tcga1)
new_names <- c(old_names[2:length(old_names)], "nada")
colnames(tcga1) <- new_names
colnames(tcga2) <- new_names
colnames(tcga3) <- new_names
colnames(tcga4) <- new_names


# combine
tcga1 <- as.data.table(tcga1)
tcga2 <- as.data.table(tcga2)
tcga3 <- as.data.table(tcga3)
tcga4 <- as.data.table(tcga4)

l = list(tcga1,tcga2,tcga3,tcga4)
tcga <- rbindlist(l, use.names = T, fill = TRUE)

# create column for Tumor Sample Ids
tcga$Sample_Name <- substr(tcga$Tumor_Sample_Barcode, 1,12)
length(unique(tcga$Sample_Name)) #773 samples
33963/507 #avg mutations per sample

# Subset needed columns
tcga_sub <- subset(tcga, 
                    select = c("Chromosome", "Start_Position", "End_Position", "Variant_Classification",
                               "reference_WU", "variant_WU", "gene_name_WU", "Sample_Name"), 
                    Variant_Type=='SNP')
tcga_sub <- data.table(tcga_sub)
tcga_sub[,Unique_ID:= paste0(Chromosome, '_',
                              Start_Position, '_',
                              reference_WU, '_',
                              variant_WU)]

setkey(tcga_sub,NULL)
tcga_sub <- unique(tcga_sub)
# exploration
length(table(tcga_sub[,Unique_ID]))
barplot(table(tcga_sub[,gene_name_WU]))
barplot(table(tcga_sub$gene_name_WU[which(!(tcga_sub$gene_name_WU %in% c("T", "C", "G", "A")))]))
barplot(table(tcga$Sample_Name))
tcga_sub[,Mut_count :=.N, by = 'gene_name_WU']
tcga_sub[,High_mut_count :=ifelse(Mut_count >7 & Mut_count <5000,1,0)]
tcga_sub$gene_name_WU <- as.character(tcga_sub$gene_name_WU)

tcga_sub <- as.data.table(tcga_sub)
library(ggplot2)
ggplot() +
  geom_bar(data = subset(tcga_sub, Mut_count >1 & Mut_count <5000), aes(x = gene_name_WU, fill = as.factor(High_mut_count)))+
  geom_text(data = subset(tcga_sub,High_mut_count==1), 
            aes(x = gene_name_WU, y = Mut_count, label = gene_name_WU),
            size = 3)

table(subset(tcga_sub, High_mut_count ==1)$gene_name_WU)
#ABCA13 COL14A1   MUC16  PIK3CA    TP53     TTN   USH2A 
#    8       9      11      16      27      29       8 

write.csv(tcga,'tcga_combi.csv', row.names =F)
rm(tcga1,tcga2,tcga3,tcga4); gc()





### 1000 Genomes
#vcf_summary <- read.table("1000genomesVFC2.txt")
hgenome1 <- read.table("VariantCallFile10prc.vcf")
hgenome2 <- read.table("ASN.dindel.20100804.sites.vcf")
hgenome3 <- read.table("AFR.dindel.20100804.sites.vcf")
hgenome4 <- read.table("EUR.dindel.20100804.sites.vcf")

hgenome1 <- as.data.table(hgenome1)
hgenome2 <- as.data.table(hgenome2)
hgenome3 <- as.data.table(hgenome3)
hgenome4 <- as.data.table(hgenome4)

l = list(hgenome1,hgenome2,hgenome3,hgenome4)

hgenome <- rbindlist(l, use.names = T, fill = T)
## type of mutaion
hgenome <- as.data.frame(hgenome)
hgenome_sub <- subset(hgenome, select = c("V1", "V2", "V4", "V5"))
colnames(hgenome_sub) <- c("Chromosome", "Start_Position", "reference_WU", "variant_WU")

hgenome_sub <- as.data.table(hgenome_sub)
hgenome1_sub <- hgenome1_sub[which(nchar(reference_WU)==1),]
hgenome_sub[,Unique_ID:= paste0(Chromosome, '_',
                             Start_Position, '_',
                             reference_WU, '_',
                             variant_WU)]

## Reshape for KNN
tcga_sub2 <- tcga_sub[,.(Sample_Name, Unique_ID)]
tcga_sub2[,Freq:=.N, by =c("Sample_Name", "Unique_ID")]
mcast <- dcast(tcga_sub2, Sample_Name~Unique_ID, length) #52000 columns!!
mcast <- data.table(mcast)
mcast[,label:=1]
rm(tcga_sub2)

hgenome_sub[,Sample_Name :=.N]
hgenome_sub <- hgenome1_sub[,.(Sample_Name, Unique_ID)]
hgenome_sub[,Freq:=.N, by =c("Sample_Name", "Unique_ID")]
hcast <- dcast(hgenome_sub, Sample_Name~Unique_ID, length)
hcast <- data.table(hcast)
hcast[,label:=0]
rm(hgenome1_sub)

l =list(mcast, hcast)
combi = rbindlist(l, use.names = T,fill = T)
#All_ID = unique(combi$Unique_ID)
write.table(train, "training_set.txt", row.names = FALSE)
write.table(test, "testing_set.txt", row.names = FALSE)

n = nrow(combi)
train_size = n*.8
test_size = n*.2
train = combi[sample(1:n,train_size),]
# too big, split up
train[is.na(train)]<-0
chunk_size = nrow(train)/6
train1 <- train[1:chunk_size,]
train1[is.na(train1)] <- 0
train2 <- train[(chunk_size+1):2*chunk_size,]
train2[is.na(train2)] <- 0
train3 <- train[2*chunk_size+1: 3*chunk_size,]
train3[is.na(train3)] <- 0
train4 <- train4[3*chunk_size+1: 4*chunk_size,]
train4[is.na(train4)] <- 0
train5 <- train[4*chunk_size+1: 5*chunk_size,]
train5[is.na(train5)] <- 0
train6 <- train[5*chunk_size+1: 6*chunk_size,]
train6[is.na(trai63)] <- 0
l <- list(train1, train2, train3, train4, train5, train6)
train2 <- rbindlist(l)
#train <- train[complete.cases(train),]

cl = train$label

test = combi[sample(1:n,test_size),]
test[is.na(test)]<-0
#test <- test[complete.cases(test),]
#test[,Freq:=.N, by = Unique_ID]


clf <- knn(train, test, cl = cl, k =5, prob = T)
attributes(.Last.value)
attributes(prob)


#for( i in length(hgenome1$info)){
#  print(strsplit(strsplit(hgenome1$info,';', fixed = TRUE)[[i]][41], '=')[[1]][2])
#  #print(strsplit(strsplit(hgenome1$info,';', fixed = TRUE)[[i]][41], '=')[[1]][2])
#  #hgenome1$AF[i] <- strsplit(strsplit(hgenome1$info,';', fixed = TRUE)[[i]][4], '=')[[1]][2]
#}

