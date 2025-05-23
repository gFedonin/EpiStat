package Epistat;
#Epistat - the set of utilities for searching of associations on a phylogenetic tree
#2022 - Alexey D. Neverov neva_2000 (at) mail.ru
our $VERSION=0.10.2;
=head1 NAME

epistat - the set of utilities for the searching for associations on a phylogenetic tree

=head1 TERMS

Event - the change of character states on a branch of phylogenetic tree, e.g. mutation in a genome site or the change of phenotypic states

Site - the integer identifier for the set of events. It corresponds to a genome or a protein site where mutations occurred or to the set of specific phenotypic states, e.g. possible phenotypic reactions on a drug treatment.

=head1 DESCRIPTION

This is a stub module that contains command-line utilities for searching for associations between events on a phylogenetic tree.
Events may be mutations in genome sites for which pairwise epistatic statistics would be calculated or mutations and changes of phenotypic states for which associations of mutations and phenotype changes are calculated.

The method is based on the following publications:

    1. Kryazhimsky S., et. al. Prevalence of Epistasis in the Evolution of Influenza A Surface Proteins. 2011 PLoS Genetics 7(2):e1001301
    2. Neverov A.D., et al. Coordinated Evolution of Influenza A Surface Proteins. 2015 PLoS Genetics 11(8):e1005404
    3. Neverov A.D., et al. Episodic evolution of coadapted sets of amino acid sites in mitochondrial proteins. 2021 PLoS Genetics 17(1):e1008711.
    4. Neverov A.D., et al. Coordinated evolution at amino acid sites of SARS-CoV-2 spike. Elife. 2023 Feb 8;12:e82516. doi: 10.7554/eLife.82516.

Pipeline scripts:

    estimate_tau.pl - estimates average waiting time for an event along a phylogenetic lineage. This parameter is used for parametrization of epistatic statistics.

    run_epistat.pl - starts the search for associations. The script requires the phylogenetic tree in the branch list format (XPARR) where for each branch the sets of events in the background and in the foreground are provided.
        All events within common sites are aggregated, e.g. mutations in the common genome site or phenotype changes for the common phenotype ID.
        The main result of processing the data is a list of all site pairs with corresponding p-values calculated according to the null-model which assumes that events in each site are inpependent of other sites. 

    estimate_fdr.pl - estimates FDR for p-values for pairs of sites.

    mk_coevolmtx.pl - calculates pairwise pseudocorrelation statistics, e.i. normalized statistics that are analogs of covariances of random descrete variables on the phylogeneetic tree.

    minvert/cor2pcor.R - calculates paiwise partial correlations for the matrix of pseudocorrelation statistics using the cor2pcor package for R

    minvert/psicov.R - inverts pseudocorrelation matrix using Lasso.

Scrips that typically are not used directly but required for the analysis:

    epistat.pl - the main script in the pipeline, it calculates paiwise association statictics for pairs of sites.
        This script is typically called from run_epistat.pl, however, it could be called separately for drawing events on the tree.
    shuffle_incidence_matrix.R - randomly shuffles events on the branches of the tree preserving the number of events in each site and on each branch.
    sample2xparr.pl - converts output of shuffle_incidence_matrix.R into trees in XPARR format.
    fake_sample.pl - calculates p-value statistics for the tree with randomly shuffled events on branches. Used for the estimating of the false discovery rates (FDR).

Scripts command line templates and usage parameters are provided in the header of each script file as comments. The documentation in the POD format for scripts is in the preparation.

Input data format:
The input data is a phylogenetic tree with a list of substitutions on branches in XPARR format:

    Header
    RootID
    BranchLine+
    
    Header="child\tparent\tlength"
    
    RootID="\w+" - any string containing letters or digits
    BranchLine = "NodeID\tParentNodeID\tBranchLength\tSynSiteList\tNonSynMutList\tNonSynMutList"
    site=\d+ - site in the reference sequence, positive number
    SynSiteList = "site(;site)*" - a list of sites, in which synonymous substitutions has occured on this edge
    NonSynMutList = "mutation(;mutation)*" - alist of amino acid substitutions on this edge
    mutation = "AsiteB"
    A and B is one letter amino acid code

You can find an example of XPARR tree in epistat_examples, e.g. epistat_examples/intragene/alleles/sars2_s/S.xparr

XPARR formatted trees can be generated from the output of pylognetic reconstruction program which can reconstruct both the tree and the ancestor states. The mk_xparr.pl script can be used to generate XPARR from tree and alignment:

mk_xparr.pl -t <tree_NWK> [options] <alignment_FASTA>

Here <tree_NWK> is a newick formated tree, where the bootstrap-slot is filled with internal nodes' identifiers, and <alignment_FASTA> is a FASTA alignment of both terminal and ancestor sequences.

=head1 AUTHOR

Alexey Dmitrievich Neverov neva_2000 (at) mail.ru

=head1 LICENCE

GPL v. 3.0

=head1 INSTALLATION

Install perl 5 (you can use perlbrew if you like)

Install R

Install python 2 (typically system python for linux, you can also use pyenv with miniconda)

Install GNU Parallel

Install R packages:

    BiRewire package for R:

    To install this package, start R console (version "4.0") and enter:

    if (!requireNamespace("BiocManager", quietly = TRUE))
        install.packages("BiocManager")
    BiocManager::install("BiRewire")

    For older versions of R, please refer to the appropriate Bioconductor release.

    Enter at the R console: install.packages("corpcor").

    Enter at the R console: install.packages("glasso").

    Enter at the R console: install.packages("getopt").

    If R packages have been installed in the local directory add the path to the directory to the R_LIBS environment variable or add the following to your .bash_profile:
    
        if [ -n $R_LIBS ]; then
            export R_LIBS=/usr/me/local/R/library:$R_LIBS
        else
            export R_LIBS=/usr/me/local/R/library
        fi

Install Epistat:

    Clone the repository or download and unzip the release archive.
    NOTE: The Build.PL uses Pod::Select, part of the Pod-Parser distribution which will be removed from the Perl core since version 5.32.
    In the case of occurring of the following compilation error: "Can't locate Pod/Select.pm in @INC" try
        cpan install Pod::Select
    type:
        cd /path/to/unpacked/epistat/distributive
        perl Build.PL
        ./Build installdeps
        ./Build build
        ./Build test
        ./Build install --install_base=/where/to/installed/epistat

    Create two system variables: 
        EPISTAT_HOME pointing to '/where/to/installed/epistat/bin' directory and
        EPISTAT_LIB pointing to the '/where/to/installed/epistat/lib/perl5'.
        On linux you can modify your .bash_profile, for example:

            export EPISTAT_HOME=/where/to/installed/epistat/bin
            export EPISTAT_LIB=/where/to/installed/epistat/lib/perl5

=head1 QUICK_START

These instructions are for linux.

    chmod -R 775 /where/to/installed/epistat/epistat_examples
    cd /where/to/installed/epistat/epistat_examples
 #example 1: The search for intragenic concordant and discordant evolution
    cd intragene/alleles/sars2_s

 Run these commands from the shell:

 #This script estimates 'tau' parameter and prints it to S.tau. Copy the value of "TAU=" from S.tau to the field "TAU=" in S.epistat.prm.
        $EPISTAT_HOME/estimate_tau.pl -b 0.95 S.xparr > S.tau
 #It launches the analysis
        $EPISTAT_HOME/run_epistat.pl -x S.xparr -m 2 -p 50000 S.epistat.prm run_epistat.prm
 #It estimates FDRs for upper p-values
        $EPISTAT_HOME/estimate_fdr.pl S.upper.pvalue.unord_pairs.sites.fdr.prm > S.upper.pvalue.unord_pairs.sites.fdr
 #It estimates FDRs for lower p-values
        $EPISTAT_HOME/estimate_fdr.pl S.lower.pvalue.unord_pairs.sites.fdr.prm > S.lower.pvalue.unord_pairs.sites.fdr
 #It calculates the pseudocorrelations for site pairs. Negative values are ignored (NonNegativeElementFilter="1" in the S.mk_coevolmtx.prm).
        $EPISTAT_HOME/mk_coevolmtx.pl –m Z-score S.mk_coevolmtx.prm
 #It calculates the pseudocorrelations for site pairs. Does not ignore the negative values (NonNegativeElementFilter="0" in the S.all.mk_coevolmtx.prm).
        $EPISTAT_HOME/mk_coevolmtx.pl –m Z-score S.all.mk_coevolmtx.prm
 #It calculates the partial correlations for the matrix of positive pseudocorrelation statistics.
        $EPISTAT_HOME/minvert/cor2pcor.R -f S.block.mtx -l 0.9 -n 0 -s .cor2pcor.n0.l90.R.out
 #It builds the table of concordantly evolving pairs of sites having upper p-values<4.4e-4
 #To start, you need to modify the field "Path=" in the file S.up00044.FDR10.mk_summary.cfg setting up to the actual path to the example folder, e.g. 
 # Path="/where/to/installed/epistat/epistat_examples/intragene/alleles/sars2_s"
        $EPISTAT_HOME/mk_summary.pl -u -a S.up00044.FDR10.mk_summary.cfg S.cor2pcor.n0.l90.R.out>S.cor2pcor.n0.l90.up00044.FDR10.tab
 #It builds the table of discordantly evolving pairs of sites having lower p-values<5.2e-4
 #To start, you need to modify the field "Path=" in the file S.lp0052.FDR10.mk_summary.cfg setting up to the actual path to the example folder, e.g. 
 # Path="/where/to/installed/epistat/epistat_examples/intragene/alleles/sars2_s"
        $EPISTAT_HOME/mk_summary.pl -u -a S.lp0052.FDR10.mk_summary.cfg -s 1 S.all.mtx>S.zscores.lp0052.FDR10.tab
 #
 #example 2: The search for associations of mutations with the changes of susceptible/resistant phenotypic states on the tree branches
    cd /where/to/installed/epistat/epistat_examples/intergene/mtb_gwas/Amikacin
 #Copy the value of "TAU=" from Amikacin.tau to the field "TAU=" in Amikacin.epistat.prm
    $EPISTAT_HOME/estimate_tau.pl -b 0.95 Amikacin.xparr > Amikacin.tau
    $EPISTAT_HOME/run_epistat.pl -x Amikacin.xparr -m 2 -p 10000 Amikacin.epistat.prm run_epistat.prm
 #Estimate FDRs for upper and lower p-values at once
    parallel $EPISTAT_HOME/estimate_fdr.pl "Amikacin.{}.pvalue.fdr.prm>Amikacin.{}.pvalue.fdr" ::: upper lower
 #
 #example 3: The search for concordant evolution of sites with control for their associations with phenotypes for 9 anti-tuberculosis drugs
 #  For multiple phenotype analysis the additional file with p-values of associations of sites and phenotypes is required - *.site2pheno
 #  Note: this analysis in longer than the analysis without control of phenotypes by the factor of <the_number_of_phenotypes> 
    cd /where/to/installed/epistat/epistat_examples/intragene/alleles/mtb/phen
    $EPISTAT_HOME/estimate_tau.pl -b 0.95 9drugs.xparr > 9drugs.tau
    $EPISTAT_HOME/run_epistat.pl -x 9drugs.xparr -m 2 -p 10000 epistat.phen.prm run_epistat.prm
 #Estimate FDRs for upper and lower p-values at once
    cat estimate_fdr.txt|parallel $EPISTAT_HOME/estimate_fdr.pl "{}.prm>{}"
    $EPISTAT_HOME/mk_coevolmtx.pl –m Z-score 9drugs.mk_coevolmtx.prm
    $EPISTAT_HOME/mk_coevolmtx.pl –m Z-score 9drugs.all.mk_coevolmtx.prm
    $EPISTAT_HOME/minvert/cor2pcor.R -f 9drugs.block.mtx -l 0.9 -n 0 -s .cor2pcor.n0.l90.R.out
 #Before the start modify files
 # 9drugs.pairs2.upper.FDR5.mk_summary.cfg and
 # 9drugs.pairs2.lower.FDR5.mk_summary.cfg
 # setting up the thresholds corresponding to the 5% FDR for the upper pvalue (in the first file) an the lower p-value (in the second file)
    $EPISTAT_HOME/mk_summary.pl -u -a 9drugs.pairs2.upper.FDR5.mk_summary.cfg 9drugs.cor2pcor.n0.l90.R.out>9drugs.cor2pcor.n0.l90.FDR5.tab
	$EPISTAT_HOME/mk_summary.pl -u -a 9drugs.pairs2.lower.FDR5.mk_summary.cfg -s 1 9drugs.all.mtx>9drugs.z-score.FDR5.tab

1;