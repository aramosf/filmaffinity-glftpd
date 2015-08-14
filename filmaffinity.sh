#!/bin/bash
# Sun Feb  9 00:11:26 CET 2014 aramosf@unsec.net
# filmaffinity rating order for glftpd.
# spanish films
#  
# Tue Aug 11 01:26:33 CEST 2015
# + .fa  archive
# + cleanup script

glroot="/home/glftpd"
gllog="/home/glftpd/ftp-data/logs/filmaffinity.log"
rmv="NUKED VEXTEND EXTENDIDA EXTEND 3D SBS BLURAY DUAL 1080p SPANISH BDRIP MHD AC3 XVID DVDRip x264 READNFO iNTERNAL"
FMSORTEDSCORE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Score"
FMSORTEDGENRE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Genre"
FMSORTEDSUBGENRE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-SubGenre"
SCANDIRS=(${glroot}/site/MOVIES-3DHD-SP/ ${glroot}/site/MOVIES-HD-SP/ ${glroot}/site/MOVIES-RIP-SP/)
cut=13 # (number of characters of string /home/glftpd/)
NFOFILE=".fa"
NFOMSG='echo -e "FilmAffinity\n${n}"|figlet -c -f small && echo -e "\n\n\t\t${u}\n\n\t\t${genre}\n\n"'


test ! -d $FMSORTEDSCORE && mkdir -m777 -p "$FMSORTEDSCORE"
test ! -d $FMSORTEDGENRE && mkdir -m777 -p "$FMSORTEDGENRE"
test ! -d $FMSORTEDSUBGENRE && mkdir -m777 -p "$FMSORTEDSUBGENRE"

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
 html=$(curl -A"Mozilla" -s $u)
 # echo "$html" # Debug
 n=$(echo "$html"|grep -A1 "movie-rat-avg" | tail -1 | sed -e "s|.*\([0-9],[0-9]\).*|\1|g")
 echo "**** NOTA: $w -> $n"|tee -a $gllog
}

function genre {
 genre=$(echo "$html" | sed -e 's#</a>#\n#g' | grep moviegenre | sed -e 's#.*nodoc">##g'| \
   tr '\n' ':'| sed -e 's|:$||')
 subgenre=$(echo "$html" | sed -e 's#</a>#\n#g' | grep movietopic | sed -e 's#.*nodoc">##g'| \
   tr '\n' ':'| sed -e 's|:$||')
 echo "**** GENRE: $genre  -> $w" | tee -a $gllog
 echo "**** SUBGENRE: $subgenre  -> $w" | tee -a $gllog
}

function geturl {
   sleep 2
   echo -n "DuckDuckGo URL: " | tee -a $gllog
   url=$(curl --interface eth0:0 --connect-timeout 2 -s --get --data-urlencode \
   	    "q=$w filmaffinity" -s -L 'http://duckduckgo.com/html/'| \
		grep -i href=\"http://www.filmaffinity.com/e./film| head -1|sed -e 's#.*href="\(.*\)">#\1#')
   echo curl -s --get --data-urlencode "q=$w filmaffinity" -s -L 'http://duckduckgo.com/html/' debug
   echo $url
   if [ -z $url ]; then
   	echo -n "Google URL: " | tee -a $gllog
     url=$(curl -s --get --data-urlencode "q=$w filmaffinity" \
	 http://ajax.googleapis.com/ajax/services/search/web?v=1.0|tr '"' '\n'| \
	 grep /e./film|head -1)
	echo $url
   fi

}

for lnk in `find $FMSORTEDSCORE -type l`; do
  l=$(readlink -m $lnk)
  if [ ! -d $glroot/$l ]; then
    echo "delete link: $l" | tee -a $gllog
    rm "$lnk"
 fi
done


for sect in ${SCANDIRS[*]}; do
 echo "STARTING SECTION $sect"
 for rls in $(find $sect -maxdepth 1 -type d | sed -e "s|${sect}||" |sort|uniq); do
   echo "rls: $rls" |tee -a $gllog
   if [ -h $FMSORTEDSCORE/?/?,?-$rls ]; then
     echo "link exists: $(ls $FMSORTEDSCORE/?/?,?-$rls)" |tee -a $gllog
     continue
   fi
   unrls $rls
   geturl
   u=$( echo $url | sed -e 's|/en/|/es/|')
   n=""
   if [[ $u == *filmaffinity.com* ]]; then
    nota $w
	genre
   else
    echo "--- ERROR NOT FILMAFFINITY LINK: $rls $u" |tee -a $gllog
    n="error"
    test ! -d $FMSORTEDSCORE/Error && mkdir -m777 -p  "$FMSORTEDSCORE/Error"
    ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDSCORE/Error/ERROR-$rls" 2>/dev/null
    continue
   fi


   # Nota
   may=$(echo $n|cut -d, -f1)
   if [[ $n == *[0-9],[0-9]* ]]; then
     test ! -d $FMSORTEDSCORE/$may && mkdir -m777 -p "$FMSORTEDSCORE/$may"
     ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDSCORE/$may/$n-$rls" 2>/dev/null
	 ok=1
   else
    echo "--- ERROR FILM WITHOUT FILMAFFINITY SCORE: $rls $u" |tee -a $gllog
    n="-1"
    test ! -d $FMSORTEDSCORE/Error && mkdir -m777 -p  "$FMSORTEDSCORE/Error"
    ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDSCORE/Error/ERROR-$rls" 2>/dev/null
   fi

   # Genero y Subgenero
   if [ ! -z "$genre" ]; then
     OLDIFS=$IFS IFS=$':'
	 ok=1
	 for g in $genre; do
	    g=$(echo $g|sed 's#/#_#g') # Hay veces que meten una /
	    if [[ ! "$g" == *['!'\"@\#\$%^\&*{}+\^.\<\>]* ]]; then 
     	  test ! -d $FMSORTEDGENRE/$g && mkdir -m777 -p "$FMSORTEDGENRE/$g"
  	      ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDGENRE/$g/$rls" 2>/dev/null
		  #echo ln -s $(echo ${sect}${rls}| cut -c$cut-) $FMSORTEDGENRE/$g/$rls # debug
		else
		  echo "genre $g string error"
		fi
	 done
	 IFS=$OLDIFS
   else
    g="-1"
    echo "--- ERROR FILM WITHOUT FILMAFFINITY GENRE: $rls $u" |tee -a $gllog
	test ! -d $FMSORTEDGENRE/Error && mkdir -m777 -p  "$FMSORTEDGENRE/Error"
    ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDGENRE/Error/ERROR-$rls" 2>/dev/null

   fi

   if [ ! -z "$subgenre" ]; then
     OLDIFS=$IFS IFS=$':'
	 ok=1
	 for g in $subgenre; do
	    g=$(echo $g|sed 's#/#_#g') # Hay veces que meten una /
	   if [[ ! "$g" == *['!'\"@\#\$%^\&*{}+\^.\<\>]* ]]; then 
     	test ! -d "$FMSORTEDSUBGENRE/$g" && mkdir -m777 -p "$FMSORTEDSUBGENRE/$g"
  	    ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDSUBGENRE/$g/$rls" 2>/dev/null
		# echo ln -s $(echo ${sect}${rls}| cut -c$cut-) $FMSORTEDSUBGENRE/$g/$rls # debug
	   else
		  echo "subgenre $g string error"
	   fi

	 done
	 IFS=$OLDIFS
   else
    g="-1"
    echo "--- ERROR FILM WITHOUT FILMAFFINITY SUBGENRE: $rls $u" |tee -a $gllog
   fi





   # Se crea NFO y Directorio dentro de la release con nota/generos
   if [ $ok -eq 1 ]; then
     gen=$( echo $genre |cut -d: -f1)
     echo mkdir "$(echo ${sect}${rls})/[FA]=-_Score_${n}_Genre_${gen}-=[FA]" #debug
     mkdir "$(echo ${sect}${rls})/[FA]=-_Score_${n}_Genre_${gen}-=[FA]" 2>/dev/null
     test ! -z $NFOFILE && eval ${NFOMSG} > ${sect}${rls}/$NFOFILE
     ok=0
   fi

 done
done



