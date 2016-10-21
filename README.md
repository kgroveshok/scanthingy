# scanthingy

# A Scanner, Document Storage and Print Server

This is based loosly of my old scanner menu I wrote a decade ago.

Added many new features such as PDF packaging and OCR extraction

# Setup

1. Use (with any possible changes for your environment) the install.sh script to 
build all the bits

2. Set SCANDOCS in your bashrc to point to where you want the scanner doc root to be
by default it will be ~/Documents/Scanner

3. The awesome Elastic Search can make local document indexing handy and
making use of the FESS web spider automates much of the process as it can also use local files

That's it really!

Then use desktop_client.sh to fire up the menu and get scanning :-)



# Print Server

This was originally designed for running on my PI and I used (and included some config files to help) the following website:

CUPS config based on https://samhobbs.co.uk/2014/07/raspberry-pi-print-scanner-server


# TODO

On repackage PDF, only rebuild if any files are newer than the existing PDF


