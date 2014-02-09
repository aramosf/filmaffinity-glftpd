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

function unrls {
 y=""; g=""; x=""; w="";
 # remove .*[year].*
 y=$(echo $rls | sed -e 's|\(.*[1-2][0-9]\{3\}\)\..*|\1|g' | sed -e 's|\.| |g')
 #echo "y -> $y"
 #remove nuked
 nu=$( echo $y|sed -e 's#^NUKED-##')
 #echo "nu -> $nu"
 # remove group
 g=$(echo $nu | sed -e 's|-.*||g')
 #echo "g -> $g"
 # remove rmv words
 x=$(echo $g|eval $(echo -n "sed "; for i in $rmv; do
    echo -n " -e"; echo -n " s/$i//ig "; done))
 #echo "y -> $y"
 w=$(echo $x| sed -e 's| AO | |' -e 's| AOU | |g' -e 's| OU | |g')
 echo "unrls rls: $w"|tee -a $gllog
}

function nota {
 #nota
 n=$(curl -A"Mozilla" -s $u|grep -A1 "movie-rat-avg" | tail -1 | sed -e "s|.*\([0-9],[0-9]\).*|\1|g")
 echo "**** NOTA: $w -> $n"|tee -a $gllog
}

for lnk in `find /home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Score/ -type l`; do
  l=$(readlink -m $lnk)
  if [ ! -d $glroot/$l ]; then
    echo "delete link: $l" | tee -a $gllog
    rm $lnk
 fi
done


for sect in ${SCANDIRS[*]}; do
 echo "STARTING SECTION $sect"
 for rls in $(find $sect -maxdepth 1 -type d | sed -e "s|${sect}||" |sort|uniq); do
   echo "rls: $rls" |tee -a $gllog
   if [ -h $FMSORTED/?/?,?-$rls ]; then
     echo "link exists: $(ls $FMSORTED/?/?,?-$rls)" |tee -a $gllog
     continue
   fi
   unrls $rls
   url=$(curl -s --get --data-urlencode "q=$w filmaffinity" http://ajax.googleapis.com/ajax/services/search/web?v=1.0|tr '"' '\n'|grep /e./film|head -1)
  #echo "curl -s --get --data-urlencode \"q=$w filmaffinity\" http://ajax.googleapis.com/ajax/services/search/web?v=1.0|tr '\"' '\n'|grep /e./film|head -1"
   u=$( echo $url | sed -e 's|/en/|/es/|')
   echo "url->$u" |tee -a $gllog
   n=""
   if [[ $u == *filmaffinity.com* ]]; then
    nota $w
   else
    echo "--- ERROR NOT FILMAFFINITY LINK: $rls $u" |tee -a $gllog
    n="error"
    test ! -d $FMSORTED/Error && mkdir -m777 -p  $FMSORTED/Error
    ln -s $(echo ${sect}${rls}| cut -c$cut-) $FMSORTED/Error/ERROR-$rls 2>/dev/null
    continue
   fi
   may=$(echo $n|cut -d, -f1)
   if [[ $n == *[0-9],[0-9]* ]]; then
     test ! -d $FMSORTED/$may && mkdir -m777 -p $FMSORTED/$may
     ln -s $(echo ${sect}${rls}| cut -c$cut-) $FMSORTED/$may/$n-$rls 2>/dev/null
   fi
 done
done



