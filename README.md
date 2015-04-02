# vir-comp

Requirements:

- mafft

  Can be downloaded from:

    http://mafft.cbrc.jp/alignment/software/

- Rscript (command line R)
  - getopt package

  Can be found from:
  
    http://cran.r-project.org/src/contrib/getopt_1.20.0.tar.gz

  on OSX should be installed at:

    /Library/Frameworks/R.framework/Resources/library/

- perl

Installation instructions:
- ensure Rscript and perl are in your path.  If not this can be done by editing your bash, cshell or similar config file.

add paths to shell config file, for example:

  setenv PATH /Library/Frameworks/R.framework/Resources/bin/:/opt/local/bin:/opt/local/sbin:$PATH 

or create sym links to areas already in your path locations, for example:

  ln -s /Library/Frameworks/R.framework/Resources/bin/Rsync /usr/bin/
