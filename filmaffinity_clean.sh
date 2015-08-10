#!/bin/bash
# Sun Feb  9 00:11:26 CET 2014 aramosf@unsec.net
# filmaffinity rating order for glftpd.
# spanish films

glroot="/home/glftpd"
gllog="/home/glftpd/ftp-data/logs/filmaffinity.log"
rmv="NUKED VEXTEND EXTENDIDA EXTEND 3D SBS BLURAY DUAL 1080p SPANISH BDRIP MHD AC3 XVID DVDRip x264 READNFO iNTERNAL"
FMSORTED="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Score"
SCANDIRS=(${glroot}/site/MOVIES-3DHD-SP/ ${glroot}/site/MOVIES-HD-SP/ ${glroot}/site/MOVIES-RIP-SP/)
cut=13 # (number of characters of string /home/glftpd/)
NFOFILE=".fa"
NFOMSG='echo -e "FilmAffinity\n${n}"|figlet -c -f small'

for lnk in `find /home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Score/ -type l`; do
  l=$(readlink -m $lnk)
  if [ ! -d $glroot/$l ]; then
    echo "delete link: $l" | tee -a $gllog
    rm $lnk
 fi
done


for sect in ${SCANDIRS[*]}; do
 echo "STARTING SECTION $sect"
 for score_error in $(find $sect -maxdepth 2 -type d -iname "*Score_error*"); do
   echo "delete scoreerror: $score_error" |tee -a $gllog
   rmdir "$score_error"
 done
 for novotes in $(find $sect -maxdepth 2 -type d -iname "*Score_novotes*"); do
   echo "delete novotes: $novotes" |tee -a $gllog
   rmdir "$novotes"
 done

done

echo "deleteing $FMSORTED/Error folder" | tee -a $gllog
rm -rf $FMSORTED/Error
