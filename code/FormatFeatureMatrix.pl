#!/usr/bin/perl
use IO::File;
use IO::Handle;

#my $fastafile=$ARGV[0];#uncommnet this statement if called inside matlab
my $fastafile='test'; #commnet this statement if called inside matlab
my $topic='complex';
my $datadir="..\\data\\";
my $blastbindir="..\\blast\\bin\\";
my $blastdatadir="..\\blast\\data\\";
my $featuredir="..\\featurematrix\\";
my $goadb="..\\goa\\";


my @fastafiles;
push(@fastafiles,$fastafile);

foreach my $f(@fastafiles)
{
    convert($f);
}


sub convert
{
    my $file=shift;
    my $datafile=sprintf('%s%s.feature.vectors.txt.predict.multi.labels',$featuredir,$file);
    open my $datafilehandle, ">$datafile" ;

    my $predictinfofile=sprintf('%s%s.feature.vectors.txt.predict.info',$featuredir,$file);
    open my $predictinfofilehandle, ">$predictinfofile" ;

    my $count=0;
    my $data=sprintf("%s$file.feature.vectors.txt",$featuredir);
    open IN, "<$data";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while($dataline=$fh->getline)
    {
           chomp($dataline);
           $count++;
           print "formatting line $count...\n";

           my @tt=split(/\s+/,$dataline);
           my $hit=$tt[1];
           my $t1=shift(@tt);
           my $t2=shift(@tt);
           print $predictinfofilehandle  $t1."\t".$t2."\n";
           my @DD;
           for(my $j=0;$j<@tt;$j++)
           {
                       if($tt[$j]>0)
                       {
                            push(@DD,($j+1).":".$tt[$j]);
                       }
           }

           print $datafilehandle  "1  ".join(' ',@DD)."\n";#pseudo class label
    }
    close IN;
    $fh->close();

    close $datafilehandle;
    close predictinfofilehandle;
}