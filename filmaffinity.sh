#!/bin/bash
# Sun Feb  9 00:11:26 CET 2014 aramosf@unsec.net
# filmaffinity rating order for glftpd.
# spanish films
#
# Wed 14 Dec 23:01:01 CET 2016
# + fixed duckduckgo search
#
# Tue Aug 11 01:26:33 CEST 2015
# + .fa  archive
# + cleanup script
# Sun Oct 18 00:41:42 CEST 2015
# + director sort

glroot="/home/glftpd"
gllog="/home/glftpd/ftp-data/logs/filmaffinity.log"
rmv="NUKED VEXTEND EXTENDIDA EXTEND 3D SBS BLURAY DUAL 1080p SPANISH BDRIP MHD AC3 XVID DVDRip x264 READNFO iNTERNAL MHD Multi REPACK"
FMSORTEDSCORE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Score"
FMSORTEDGENRE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Genre"
FMSORTEDSUBGENRE="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-SubGenre"
FMSORTEDDIRECTOR="/home/glftpd/site/MOVIES_SORTED/Sorted.By.FA-Director"
SCANDIRS=(${glroot}/site/MOVIES-3DHD-SP/ ${glroot}/site/MOVIES-HD-SP/ ${glroot}/site/MOVIES-RIP-SP/)
cut=13 # (number of characters of string /home/glftpd/)
NFOFILE=".fa"
NFOMSG='echo -e "FilmAffinity\n${n}"|figlet -c -f small && echo -e "\n\n\t\t${u}\n\n\t\t${genre}\n\n"'


test ! -d $FMSORTEDSCORE && mkdir -m777 -p "$FMSORTEDSCORE"
test ! -d $FMSORTEDGENRE && mkdir -m777 -p "$FMSORTEDGENRE"
test ! -d $FMSORTEDSUBGENRE && mkdir -m777 -p "$FMSORTEDSUBGENRE"
test ! -d $FMSORTEDDIRECTOR && mkdir -m777 -p "$FMSORTEDDIRECTOR"

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

function director {
 director=$(echo "$html" | grep -A3 "itemprop=\"director\""| sed -e "s|.*name\">\(.*\)</span></a>.*|\1|g"|\
   grep -v '<' |tr '\n' ':'| sed -e 's|:$||' | sed -e 's|: ||g')  # si son varios directores, hay espacios
 echo "**** Director: $director -> $w"|tee -a $gllog
}

function geturl {
   sleep 2
   echo -n "DuckDuckGo URL: " | tee -a $gllog
   url=$(curl --interface eth0:0 --connect-timeout 2 -s --get --data-urlencode \
   	    "q=$w filmaffinity" -s -L 'http://duckduckgo.com/html/'| \
		grep -i href=\"http://www.filmaffinity.com/e./film| head -1|sed -e 's#.*href="\(.*html\)">.*#\1#')
   #echo curl -s --get --data-urlencode "q=$w filmaffinity" -s -L 'http://duckduckgo.com/html/' debug
   echo $url
   #
   if [ -z $url ]; then
   echo "Second try.. wait 5 seconds"; sleep 5
   echo -n "DuckDuckGo(2) URL: " | tee -a $gllog
   url=$(curl --connect-timeout 10 --get --data-urlencode \
   	    "q=$w filmaffinity" -s -L 'https://duckduckgo.com/html/'| \
		egrep -i href=\"http.?://www.filmaffinity.com/e./film| head -1|sed -e 's#.*href="\(.*html\)">.*#\1#')
   echo $url

   fi
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
   ok=0
   echo "rls: $rls" |tee -a $gllog
   if [ $( ls $FMSORTEDSCORE/?/?,?-$rls | wc -l ) -gt 1 ]; then # Hay veces que hay dos links con dos notas
		 echo "deleting duplicate rating $rls" | tee -a $gllog
		 #ls -l $FMSORTEDSCORE/?/?,?-$rls
		 rm $FMSORTEDSCORE/?/?,?-$rls
   fi
   if [ -h $FMSORTEDSCORE/?/?,?-$rls ]; then
     echo "link exists: $(ls $FMSORTEDSCORE/?/?,?-$rls)" |tee -a $gllog
     if [ -z $1 ]; then continue; fi
   fi
   unrls $rls
   geturl
   u=$( echo $url | sed -e 's|/en/|/es/|')
   n=""
   if [[ $u == *filmaffinity.com* ]]; then
    nota $w
	genre
	director
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

   # Director
   if [ ! -z "$director" ]; then
     OLDIFS=$IFS IFS=$':'
	 ok=1
	 for d in $director; do
	    d=$(echo $d|sed 's#/#_#g') # Hay veces que meten una /
	    if [[ ! "$d" == *['!'\"@\#\$%^\&*{}+\^.\<\>]* ]]; then 
     	  test ! -d $FMSORTEDDIRECTOR/$d && mkdir -m777 -p "$FMSORTEDDIRECTOR/$d"
  	      ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDDIRECTOR/$d/$rls" 2>/dev/null
		  #echo ln -s $(echo ${sect}${rls}| cut -c$cut-) $FMSORTEDGENRE/$g/$rls # debug
		else
		  echo "director $d string error"
		fi
	 done
	 IFS=$OLDIFS
   else
    d="-1"
    echo "--- ERROR FILM WITHOUT FILMAFFINITY DIRECTOR: $rls $u" |tee -a $gllog
	test ! -d $FMSORTEDDIRECTOR/Error && mkdir -m777 -p  "$FMSORTEDDIRECTOR/Error"
    ln -s $(echo ${sect}${rls}| cut -c$cut-) "$FMSORTEDDIRECTOR/Error/ERROR-$rls" 2>/dev/null

   fi





   # Se crea NFO y Directorio dentro de la release con nota/generos
   if [ $ok -eq 1 ]; then
     gen=$( echo $genre |cut -d: -f1)
     #echo mkdir "$(echo ${sect}${rls})/[FA]=-_Score_${n}_Genre_${gen}-=[FA]" #debug
     mkdir "$(echo ${sect}${rls})/[FA]=-_Score_${n}_Genre_${gen}-=[FA]" 2>/dev/null
     test ! -z $NFOFILE && eval ${NFOMSG} > ${sect}${rls}/$NFOFILE
     ok=0
   fi

 done
done



