#!/usr/bin/perl
use IO::File;
use IO::Handle;
use List::Util qw/shuffle/;
use Math::BigFloat;
use POSIX qw/ceil/;
use File::Path ;

#my $proteinpairfile=$ARGV[0];#uncommnet this statement if called inside matlab
my $proteinpairfile='test'; #commnet this statement if called inside matlab

my $topic='complex';
my %map;
my %revnuberingmap;
GetNumbering();
GenerateGraph();

print "MMC clustering...\n";
my $method='MMC';
system("java -jar clustering.jar -graph ..\\data\\$proteinpairfile.binary.graph.txt  -part ..\\data\\$method.$proteinpairfile.binary.graph.clustering.txt  -termination size -minsize 0 -recursive");
print "Get MMC complexes...\n";
GetMMCComplexes();


$method='CFINDER';
my $dir="..\\data\\$proteinpairfile.binary.graph.txt_files\\";
rmtree($dir);
system(".\\CFinder\\CFinder_commandline64.exe -l .\\CFinder\\licence.txt -i ..\\data\\$proteinpairfile.binary.graph.txt");
GetCFinderComplexes();
rmtree($dir);
print "finished\n";

sub GetNumbering
{
    my %indexces;
    my %comindexes;
    my $index=0;
    my $comindex=0;
    my $count=0;
    my $file="..\\data\\$proteinpairfile";
    open IN, "<$file";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while(my $line=$fh->getline)
    {
        chomp($line);
        $count++;
        my @tt=split(/\t/,$line);
        my $g1=(split(/\|/,$tt[0]))[0];
        $g1=(split(/:/,$g1))[1];
        my $p1=(split(/\|/,$tt[0]))[1];
        my $g2=(split(/\|/,$tt[1]))[0];
        $g2=(split(/:/,$g2))[1];
        my $p2=(split(/\|/,$tt[1]))[1];
        $map{$p1}=$g1;
        $map{$p2}=$g2;

        if(not exists($indexces{$p1}))
        {
              $index++;
              $indexces{$p1}=$index;
        }

        if(not exists($indexces{$p2}))
        {
              $index++;
              $indexces{$p2}=$index;
        }
    }
    close IN;
    $fh->close();


    my $pfile="..\\data\\$proteinpairfile.numbering.txt";
    open my $pfilehandle, ">$pfile" ;
    foreach my $p(keys%indexces)
    {
        print $pfilehandle  $p."\t".$indexces{$p}."\n";
    }
    close $pfilehandle;

}

sub GenerateGraph
{
    my $gfile="..\\data\\$proteinpairfile.binary.graph.txt";
    open my $gfilehandle, ">$gfile" ;

    my $mfile="..\\data\\$proteinpairfile.numbering.txt";
    open IN, "<$mfile";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while(my $line=$fh->getline)
    {
        chomp($line);
        my @tt=split(/\t/,$line);
        my $p=$tt[0];
        my $index=$tt[1];
        $nuberingmap{$p}=$index;
        $revnuberingmap{$index}=$p;
    }
    close IN;
    $fh->close();


    my %uniques;
    my $tfile="..\\data\\$proteinpairfile";
    open IN1, "<$tfile";
    my $fh1=IO::Handle->new_from_fd(fileno IN1,r);

    my $rfile="..\\featurematrix\\$proteinpairfile.predict.final.decvalues";
    open IN2, "<$rfile";
    my $fh2=IO::Handle->new_from_fd(fileno IN2,r);

    while((my $line1=$fh1->getline) && (my $line2=$fh2->getline))
    {
        chomp($line1);
        chomp($line2);
        next if($line2<0);
        my @tt=split(/\t/,$line1);
        my $p1=(split(/\|/,$tt[0]))[1];
        my $p2=(split(/\|/,$tt[1]))[1];

        $p1=$nuberingmap{$p1};
        $p2=$nuberingmap{$p2};
        print $gfilehandle $p1."\t".$p2."\n";
    }
    close IN;
    $fh->close();
    close $gfilehandle;
}

sub GetMMCComplexes
{
    my %complexes;
    my $file="..\\data\\MMC.$proteinpairfile.binary.graph.clustering.txt";
    open IN, "<$file";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while(my $line=$fh->getline)
    {
        chomp($line);
        my @aa=split(/\t/,$line);
        my $p=$aa[0];
        for(my $i=1;$i<@aa;$i++)
        {
           my $com=$aa[$i];
           if(not exists($complexes{$com}))
           {
              $complexes{$com}=$p;
           }
           else
           {
               if(($complexes{$com} ne $p) && ($complexes{$com}!~m/^($p,)/) && ($complexes{$com}!~m/,$p,/) && ($complexes{$com}!~m/(,$p)$/))
               {
                  $complexes{$com}=$complexes{$com}.",".$p;
               }

           }
        }
    }
    close IN;
    $fh->close();

    my $rfile="..\\results\\$proteinpairfile.graph.clustering.MMC.complexes.results.txt";
    open my $filehandle, ">$rfile" ;
    foreach my $c(sort{$a<=>$b}keys%complexes)
    {
        my @tt=split(/,/,$complexes{$c});
        for(my $i=0;$i<@tt;$i++)
        {
           my $pi=$tt[$i];
           my $p=$revnuberingmap{$pi};
           my $g=$map{$p};
           $tt[$i]=$g."|".$p;
        }
        print $filehandle $c."\t".join(";",@tt)."\n";
    }
    close $filehandle;

    unlink "..\\data\\MMC.$proteinpairfile.binary.graph.clustering.txt";

}

sub GetCFinderComplexes
{
    my $file="..\\results\\$proteinpairfile.graph.clustering.CFinder.complexes.results.txt";
    open my $filehandle, ">$file" ;

    my $comid=0;
    my $file="..\\data\\$proteinpairfile.binary.graph.txt_files\\cliques";
    open IN, "<$file";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while(my $line=$fh->getline)
    {
        chomp($line);
        next if($line=~m/\#/);
        next if($line eq '');
        my @tt=split(/:/,$line);
        my $t=$tt[1];
        $t=~s/^(\s)//;
        @tt=split(/\s/,$t);
        for(my $i=0;$i<@tt;$i++)
        {
           my $pi=$tt[$i];
           my $p=$revnuberingmap{$pi};
           my $g=$map{$p};
           $tt[$i]=$g."|".$p;
        }

        my $p=$nuberingmap{$pi};
        my $g=$map{$p};
        print $filehandle $comid."\t".join(";",@tt)."\n";
        $comid++;
    }
    close IN;
    $fh->close();
    close $filehandle;

    unlink "..\\data\\$proteinpairfile.numbering.txt";
    unlink "..\\data\\$proteinpairfile.binary.graph.txt";
}