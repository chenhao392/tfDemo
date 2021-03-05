#!/usr/bin/perl

use strict;
use warnings;

if($#ARGV <3){
	print "Usage:\n";
	print "\tARGV[0]: white space separated file 1\n";
	print "\tARGV[1]: white space separated file 2\n";
	print "\tARGV[2]: id to index, in file 1 (1-based)\n";
	print "\tARGV[3]: id to index, in file 2 (1-based)\n";
	print "\tARGV[4]: optional: output file name\n";
	print "\tARGV[5]: optional: U12,E1,E2 or I12 for union, exclusive or intersect\n";
	print "\tARGV[6]: optional: perl boolean indicating file headed or not, default false/0\n";
	print "\tARGV[7]: optional: perl boolean indicating output file headed or not, default false/0\n";
	print "\tARGV[8]: optional: perl regular expression for defining columns, default \\s+ \n";
	exit;
}

my $file1=$ARGV[0];
my $file2=$ARGV[1];
my $index1=$ARGV[2]?$ARGV[2]:1;
my $index2=$ARGV[3]?$ARGV[3]:1;
my $choice=$ARGV[5]?$ARGV[5]:"U12";
my $isHeaded=$ARGV[6]?$ARGV[6]:0;
my $outHeaded=$ARGV[7]?$ARGV[7]:0;
my $sepBy=$ARGV[8]?$ARGV[8]:"\\s+";

my ($data1Ref,$indexHead1,@head1)=load_table($file1,$index1);
my ($data2Ref,$indexHead2,@head2)=load_table($file2,$index2);
my %data1=%{$data1Ref};
my %data2=%{$data2Ref};
$file1=~s/\..*//;
$file2=~s/\..*//;
my $outFile=$ARGV[4]?$ARGV[4]:$file1.$file2."_merged.txt";

open FILE, ">$outFile" or die "$!\n";
	if($choice eq "E1"){
		if($outHeaded){
			print FILE "$indexHead1";
			foreach(@head1){print FILE "\t$_";}print FILE "\n";
		}
		foreach my $key(sort keys %data1){
			if(!defined $data2{$key}){
				foreach my $line(@{$data1{$key}}){
					print FILE "$key\t$line\n";
				}
			}
		}
	}
	elsif($choice eq "E2"){
		if($outHeaded){
			print FILE "$indexHead2";
			foreach(@head2){print FILE "\t$_";}print FILE "\n";
		}
		foreach my $key(sort keys %data2){
			if(!defined $data1{$key}){
				foreach my $line(@{$data2{$key}}){
					print FILE "$key\t$line\n";
				}
			}
		}
	}
	elsif($choice eq "I12"){
		if($outHeaded){
			print FILE "$indexHead1";
			foreach(@head1){print FILE "\t$_";}
			foreach(@head2){print FILE "\t$_";}print FILE "\n";
		}
		foreach my $key(sort keys %data1){
			if(defined $data2{$key}){
				foreach my $line1(@{$data1{$key}}){
					foreach my $line2(@{$data2{$key}}){
						print FILE "$key\t$line1\t$line2\n";
					}
				}
			}
		}
	}
	elsif($choice eq "U12"){
		if($outHeaded){
			print FILE "$indexHead1";
			foreach(@head1){print FILE "\t$_";}
			foreach(@head2){print FILE "\t$_";}print FILE "\n";
		}
		foreach my $key(sort keys %data1){
			foreach my $line1(@{$data1{$key}}){
				if(defined $data2{$key}){
					foreach my $line2(@{$data2{$key}}){
						print FILE "$key\t$line1\t$line2\n";
					}
				}
				else{
					print FILE "$key\t$line1";
					for(0..$#head2){print FILE "\tNA";}print FILE "\n";
				}
			}
		}
	
		foreach my $key(sort keys %data2){
			if(!defined $data1{$key}){
				foreach my $line2(@{$data2{$key}}){
					print FILE "$key";
					for(0..$#head1){print FILE "\tNA";}
					print FILE "\t$line2\n";
				}
			}
		}
	}
	elsif($choice eq "U1"){
		if($outHeaded){
			print FILE "$indexHead1";
			foreach(@head1){print FILE "\t$_";}
			foreach(@head2){print FILE "\t$_";}print FILE "\n";
		}
		foreach my $key(sort keys %data1){
			foreach my $line1(@{$data1{$key}}){
				if(defined $data2{$key}){
					foreach my $line2(@{$data2{$key}}){
						print FILE "$key\t$line1\t$line2\n";
					}
				}
				else{
					print FILE "$key\t$line1";
					for(0..$#head2){print FILE "\tNA";}print FILE "\n";
				}
			}
		}
	}
	elsif($choice eq "U2"){
		if($outHeaded){
			print FILE "$indexHead2";
			foreach(@head1){print FILE "\t$_";}
			foreach(@head2){print FILE "\t$_";}print FILE "\n";
		}
		foreach my $key(sort keys %data2){
			foreach my $line2(@{$data2{$key}}){
				if(defined $data1{$key}){
					foreach my $line1(@{$data1{$key}}){
						print FILE "$key\t$line1\t$line2\n";
					}
				}
				else{
					print FILE "$key";
					for(0..$#head1){print FILE "\tNA";}
					print FILE "\t$line2\n";
				}
			}
		}
	}
	else{
		die "Wrong choice: $choice . It has to be E1, E2, U1, U2, I12 or U12 .";
	}
close FILE;




sub load_table{
	my ($file,$index)=@_;
	my (%data,@head,$indexHead);
	open FILE, "<$file" or die "$!\n";
	while(<FILE>){
		chomp;
		if($_ =~ /^#/){next;}
		my @l=split(/$sepBy/,$_);
		my $id=splice(@l,$index-1,1);
		if($. == 1 && $isHeaded){@head=@l;$indexHead=$id;}
		elsif($. == 1 && !$isHeaded){
			push @{$data{$id}},join("\t",@l);
			@head=@l;
			for(my $i=0;$i<scalar(@head);$i++){
				$head[$i]="example." . $head[$i];
			}
			$indexHead="example." . $id;
			}
		else{
			push @{$data{$id}},join("\t",@l);
		}
	}
	close FILE;
	return (\%data,$indexHead,@head);
}
