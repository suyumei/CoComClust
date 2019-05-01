#!/usr/bin/perl
#use strict;
use IO::File;
use IO::Handle;
use Archive::Tar;

my $goadb="..\\goa\\";
SplitGOA();
FurtherSplit();
print "finished\n";

sub SplitGOA
{
    my %filehandles;
    my $gofile=$goadb."GOA.new.uniprot.proteins";
    open IN, "<$gofile";
    my $fh=IO::Handle->new_from_fd(fileno IN,r);
    while(my $line=$fh->getline)
    {
       chomp($line);
       my @dataitems=split(/\t/,$line);
       my $proteinid=(split(/\|/,$dataitems[0]))[1];
       print "---$proteinid---\n";
       my $initial=substr($proteinid,0,1);
       if(not exists($filehandles{$initial}))
       {
           my $goafile=$goadb."$initial.goa.part";
           $filehandles{$initial}=new IO::File(">$goafile");
       }
       $filehandles{$initial}->print($line."\n")
    }
    $fh->close();
    close IN;
    foreach my $initial(keys%filehandles)
    {
        $filehandles{$initial}->close();

        print "---compressing $initial.goa.part---\n";
        my $goafile=$goadb."$initial.goa.part";
        if($initial eq 'A')
        {
           system("split -l 2 $goafile");
           # compress($goafile.".1");
#            compress($goafile.".2");
        }
        else
        {
           compress($goafile);
        }

    }
}

sub compress
{
    my $file=shift;
    push(@files,$file);
    my $target = "$file.zip";
    my $tar = Archive::Tar->new();
    $tar->add_files(@files);
    $tar->write($target, COMPRESS_GZIP);

}