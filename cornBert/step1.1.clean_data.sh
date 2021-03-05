# bin for extracting promoter seq from genome
wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit
wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/twoBitInfo
chmod 755 faToTwoBit
chmod 755 twoBitInfo
mkdir bin
mv faToTwoBit twoBitInfo
#chrom size
./bin/faToTwoBit data/Zm-B73-REFERENCE-GRAMENE-4.0.fa data/Zm-B73-REFERENCE-GRAMENE-4.0.2bit
./bin/twoBitInfo data/Zm-B73-REFERENCE-GRAMENE-4.0.2bit stdout | sort -k2rn > data/b73.chrom.sizes
#gene anno
grep "ID=gene" data/Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.gff3|grep -Pv '(B73V4)|(Pt)|(Mt)' |sed 's/^/Chr/'>data/gene.gff3
#upstream seq
bedtools flank -i data/gene.gff3 -g data/b73.chrom.sizes -l 1000 -r 0 -s > data/genes.1kb.promoters.bed
more data/genes.1kb.promoters.bed |sed 's/ID=gene://'|sed 's/;.*//'|perl -ane '$F[2]=$F[8];print "$F[0]";for(1..7){print "\t$F[$_]";}print "\n";' >data/ids.1kb.promoters.bed
bedtools getfasta -fi data/Zm-B73-REFERENCE-GRAMENE-4.0.fa -bed data/ids.1kb.promoters.bed -name -tab -fo data/genes.1kb.promoters.fa
more data/genes.1kb.promoters.fa |sed 's/::Chr.*\t/\t/' >data/genes.1kb.promoters.tab.txt
tail -n +2 data/walley_fpkm.txt |sed 's/NA/0/g' >data/gene.fpkm.txt
#final data table
./bin/merge_two_files.pl data/genes.1kb.promoters.tab.txt data/gene.fpkm.txt 1 1 data/table.txt I12
head -n 30000 data/table.txt >data/train.table.txt
tail -n 13428 data/table.txt >data/test.table.txt
cut -f2 data/train.table.txt >data/train.promoter.txt
