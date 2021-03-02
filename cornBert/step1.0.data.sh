# download the maize B73 version 4 genome, annotation and expression datasets
mkdir data
wget https://download.maizegdb.org/Zm-B73-REFERENCE-GRAMENE-4.0/Zm-B73-REFERENCE-GRAMENE-4.0.fa.gz
wget https://download.maizegdb.org/Zm-B73-REFERENCE-GRAMENE-4.0/Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.gff3.gz
wget https://download.maizegdb.org/GeneFunction_and_Expression/Sekon_expression_atlas/B73_RefGen_v4/walley_fpkm.txt

gunzip Zm-B73-REFERENCE-GRAMENE-4.0.fa.gz
gunzip Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.gff3.gz
mv Zm-B73-REFERENCE-GRAMENE-4.0.fa Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.gff3 walley_fpkm.txt  data
