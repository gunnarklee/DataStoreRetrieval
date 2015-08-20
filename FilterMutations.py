__author__ = 'gunnarkleemann'
#specify an aligmnemt and a reference VCF, list the number of header lines to remove from each file

import pandas as pd

def FilterMutations(Align, SkipCt1, ref, hdCt2):
    # the metadata appears to be getting in the way of dataframe construciton so i skip it for now
    #capture mtadata somewhere
    # skiprows to deal with metadata this needs to be dealt with, so that I dont loose lines
    #print SkipCt1
    Person1=pd.read_table(Align, skiprows=SkipCt1)
    #print hdCt2
    MutFile=pd.read_table(ref, skiprows=hdCt2, low_memory=False)

    Person1_fx=fixDATA(Person1)
    MutFile_fx=fixDATA(MutFile)

    FiltList=pd.merge(Person1_fx, MutFile_fx, on=['Mut'], how='inner')
    FiltList.head()
    fileNm= Align+ref
    pd.to_csv(fileNm, FiltList)

# fix column names
def fixDATA (df):

    if '#CHROM' in df.columns:
        df.rename(columns={'#CHROM':'CHROM'}, inplace=True)

    # make mutation address column
    if 'Mut' in df.columns:
        df.drop(["Mut"], axis=1, inplace=True)

    # make mutation address column
    #print df.head()

    chr=df["CHROM"].map(str)
    pos=df["POS"].map(str)
    alt=df["ALT"].map(str)
    df['Mut']='chr'+chr+'-'+pos+'-'+alt

    #make all chrmo
    if len(df["CHROM"][2])>2:
        df["CHROM"] = df["CHROM"].apply(lambda x: x[3:len(x)])
    return df



if __name__== "__main__":
    try:
        Align = sys.argv[1]
        hdCt1 = sys.argv[2]
        ref = sys.argv[3]
        hdCt2 = sys.argv[4]
        #FilterMutations(Align, hdCt1, ref, hdCt2)
    except:

        #https://s3-us-west-2.amazonaws.com/w205genomic/VariantCallFile10prc.vcf
        #personpath="/Users/gunnarkleemann/Dropbox/coursework/BerkeleyDataSciences/Final_Projects/GenomicsData/Galaxy31-[FreeBayes_on_data_30_(variants)].vcf"
        #Bucket='s3:///w205genomic/'
        #Align='VariantCallFile10prc.vcf'
        #personpath=Bucket + Align
        #Clinvarfile="/Users/gunnarkleemann/Dropbox/coursework/BerkeleyDataSciences/Final_Projects/GenomicsData/clinvar.vcf"
        #ref="clinvar_20150804.vcf"
        ##should work dynamically?
        #!aws s3 cp s3://w205genomic/VariantCallFile10prc.vcf . # download the data
        #!aws s3 cp s3://w205genomic/clinvar_20150804.vcf . # download the data

        skipHd1=55
        skipHd2=66
        FilterMutations('VariantCallFile10prc.vcf', skipHd1, 'clinvar_20150804.vcf', skipHd2)


