#!/bin/bash
# Sun Feb  9 00:11:26 CET 2014 aramosf@unsec.net
# filmaffinity rating order for glftpd.
# spanish films

glroot="/home/glftpd"
gllog="/home/glftpd/ftp-data/logs/filmaffinity.log"
rmv="NUKED VEXTEND EXTENDIDA EXTEND 3D SBS BLURAY DUAL 1080p SPANISH BDRIP MHD AC3 XVID DVDRip x264 READNFO iNTERNAL"
FMSORTEDSCORE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Score"
FMSORTEDGENRE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Genre"
FMSORTEDSUBGENRE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-SubGenre"
FMSORTEDDIRECTOR="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Director"
SCANDIRS=(${glroot}/site/MOVIES-3DHD-SP/ ${glroot}/site/MOVIES-HD-SP/ ${glroot}/site/MOVIES-RIP-SP/)
cut=13 # (number of characters of string /home/glftpd/)
NFOFILE=".fa"

OLDIFS=$IFS IFS=$'\n'

for lnk in `find $FMSORTEDSCORE -type l`; do
  l=$(readlink -m $lnk)
  if [ ! -d $glroot/$l ]; then
    echo "delete link from score: $l" | tee -a $gllog
    rm $lnk
 fi
done

for lnk in `find $FMSORTEDGENRE -type l`; do
  l=$(readlink -m $lnk)
  if [ ! -d $glroot/$l ]; then
    echo "delete link from genre: $l" | tee -a $gllog
    rm "$lnk"
 fi
done

for lnk in `find $FMSORTEDSUBGENRE -type l`; do
  l=$(readlink -m $lnk)
  if [ ! -d $glroot/$l ]; then
    echo "delete link from subgenre: $l" | tee -a $gllog
    rm "$lnk"
 fi
done

for lnk in `find $FMSORTEDDIRECTOR -type l`; do
  l=$(readlink -m $lnk)
  if [ ! -d $glroot/$l ]; then
    echo "delete link from subgenre: $l" | tee -a $gllog
    rm "$lnk"
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

# for dir in $(find $sect -maxdepth 2 -type d -iname '*_Score_*'); do
#   echo "delete fadir: $dir" |tee -a $gllog
#   rmdir "$dir"
# done

done

echo "deleteing $FMSORTEDSCORE/Error folder" | tee -a $gllog
rm -rf "$FMSORTEDSCORE/Error"

echo "deleteing $FMSORTEDGENRE/Error folder" | tee -a $gllog
rm -rf "$FMSORTEDGENRE/Error"

echo "deleteing $FMSORTEDSUBGENRE/Error folder" | tee -a $gllog
rm -rf "$FMSORTEDSUBGENRE/Error"

echo "deleteing $FMSORTEDDIRECTOR/Error folder" | tee -a $gllog
rm -rf "$FMSORTEDDIRECTOR/Error"


IFS=$OLDIFS
