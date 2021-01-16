1. Prerequisite for the software
   -matlab
   -activeperl 5.24.1
   -JVM

2. Supported platforms 
   -MS Windows 32-bit/64-bit

3. Subdirectories
   -data: query file and fasta file;
   -code: source code (matlab and perl script);
   -featurematrix: GO term & index, model file, feature vectors. The file initialed with complex should not be deleted;
   -goa: goa files. To accelerate goa searching, the go annotations are arranged in the order of the initial character of uniprot accession (A-Z), advanced users are encouraged to deploy local GOA database;
   -results: prediction results;
   -blast: psiblast tool;

4. Blast database & GOA database
   -unzip all the zipped files and place the unzepped files directly under the subdirectory 'blast/data','featurematrix' and 'goa';
   -blast/data:swissprot.zip.001,swissprot.psq.zip,swissprot.phr.zip;
   -featurematrix:test.homology.zip,test.feature.vectors.zip,test.feature.vectors.txt.predict.multi.zip;
   -goa:A.goa.zip,B.goa.zip,D.goa.zip,E.goa.zip,F.goa.zip,G.goa.zip,Q.goa.zip;

    WARNING: the source codes would fail to work if the requested files (blast/data:swissprot,swissprot.psq;goa:A.goa.part,B.goa.part,D.goa.part,E.goa.part,F.goa.part,G.goa.part,Q.goa.part) are not found in the subdirectories 'blast/data' and 'goa'.
             These files have to be zipped due to github 100MB limit of files.

5. Workflows:
   (1) test data: prepare the query file and its corresponding fasta file, and place the files into the subdirectory 'data'. 
      --each protein should be given as the format complex name:gene symble|Uniprot accession (e.g. COM_2721:TOP1|P11387) (see test). If there is no complex name, use any dummy name (e.g. COM0:TOP1|P11387);
      --each entry in the fasta file (query file name suffixed with .fasta) should be given as the format (see test.fasta)
       >uniprot accession 
       sequence
   (2) Run PSIBlastlargedatadetail.pl in the subdirectory 'code' to obtain homologs.
   (3) Run GenerateFeatureMatrix.pl in the subdirectory 'code' to obtain feature representation. 
       -This step is time-consuming, advanced users are encouraged to deploy local GOA database. The time consumed also dependes on the size of prediction data.
   (4)Run FormatFeatureMatrix.pl in the subdirectory 'code' to format feature representation. 
       -Step (2) ~ (3) could also be called in the script Main.m, but no progress information would appear in Matlab.
   (5) Run script Main.m in the subdirectory 'code' to get co-complex prediction results, the results can be found in the subdirectory 'results' (e.g. test.supervised.learning.cocomplexed.results.txt).
   (6) Run script GetDenseSubgraphs.pl in the subdirectory 'code' to get CFinder and MMC clustering results, the results can be found in the subdirectory 'results' (e.g. test.graph.clustering.CFinder.complexes.results.txt,test.graph.clustering.MMC.complexes.results.txt) 

6. Demo 
   -Run codes as specified in the workflows given the examples in the file test.

7. Applicability
   -Users only need to replace the content of file test and test.fasta in the subdirectory 'data' for new applications.
