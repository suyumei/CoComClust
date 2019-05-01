#!/usr/bin/perl
use IO::File;
use IO::Handle;

#my $fastafile=$ARGV[0];#uncommnet this statement if called inside matlab
my $fastafile='test'; #commnet this statement if called inside matlab
my $datadir="..\\data\\";
my $featuredir="..\\featurematrix\\";
my $resultdir="..\\results\\";
my $topic='complex';

GenerateResults();
print "finished\n";


sub GenerateResults
{
    my $no=0;
    my %predictionset;
    my $predictionsetfile="$datadir$fastafile";
    open IN, "<$predictionsetfile";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while(my $line=$fh->getline)
    {
       chomp($line);
       $no++;
       my @tt=split(/\t/,$line);
       $predictionset{$no}=$tt[0]."\t".$tt[1];
    }
    close IN;
    $fh->close();

    my $resultfile=$resultdir."$fastafile.supervised.learning.cocomplexed.results.txt";
    open my $resultfilehandle, ">$resultfile" ;


    print "loading prediction result file:...\n";
    my $predictionresultfile=$featuredir."$fastafile.predict.final.decvalues.txt";
    open IN, "<$predictionresultfile";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while(my $line=$fh->getline)
    {
       chomp($line);
       $no++;
       if($line>0)
       {
          print $resultfilehandle  $predictionset{$no}."\t".$line."\tco-complexed\n";
       }
       elsif($line<0)
       {
          print $resultfilehandle  $predictionset{$no}."\t".$line."\tNOT co-complexed\n";
       }
       else
       {
          print $resultfilehandle  $predictionset{$no}."\t".$line."\tundetermined\n";
       }
    }
    close IN;
    $fh->close();
    close $resultfilehandle;

}