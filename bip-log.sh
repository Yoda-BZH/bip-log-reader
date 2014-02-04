#!/bin/bash

file=$1

if [ -z "$file" ]
then
	echo "No file input"
	exit 1
fi

## see http://misc.flogisoft.com/bash/tip_colors_and_formatting#colors1
colora="1"
colorb="2"
colorc="3"
colord="4"
colore="5"
colorf="6"
color0="88"
color1="89"
color2="94"
color3="98"
color4="101"
color5="105"
color6="109"
color7="114"
color8="124"
color9="128"

IFS="
"

for line in `cat $file`
do
	lineTime=`echo $line | cut -d" " -f 2`
	lineToken=`echo $line | cut -d" " -f 3`
	lineUser=`echo $line | cut -d" " -f 4 | cut -d! -f 1`
	lineText=`echo $line | cut -d" " -f 5-`
	case "$lineToken" in
		"-!-")
			#echo "testing $lineUser $lineText"
			if [[ $lineUser == mode/* ]]
			then
				echo ">>> Mode change $lineUser $lineText"
				continue	
			fi

			if [[ $lineText == *has\ joined* ]]
			then
				echo -en ">>> Join: "
				echo -e $lineUser $lineText
				continue
			fi
			
			if [[ $lineText == *has\ quit* ]]
			then
				echo -en "<<< Quit: "
				echo -e $lineUser $lineText
				continue
			fi

			if [[ $lineText == *changed\ topic\ of* ]]
			then
				echo -en "+++ $lineUser"
				echo -e $lineText
				continue
			fi

			if [[ $lineText == *is\ now\ known\ as\ * ]]
			then
				echo -e "+++ $lineUser $lineText"
				continue
			fi

			echo "Unknow token: $line"
			;;
		">"|"<")
			## I am talking
			if [ $lineToken == ">" ]
			then
				lineUser=${lineUser/:/}
				colorNumber="208"
				bracketsColor="21"
			## other people are talking
			else
				## this could be improved
				md5User=`echo $lineUser | md5sum`
				charUser=${md5User:0:1}
				charUser=${charUser,,}
				color="color$charUser"
				colorNumber=${!color}
				bracketsColor="226"
			fi

			echo -n "$lineTime "
			echo -en "\e[38;5;${bracketsColor}m<\e[0m"
			echo -en "\e[38;5;${colorNumber}m$lineUser\e[0m"
			echo -en "\e[38;5;${bracketsColor}m>\e[0m"
			echo " $lineText"
			;;
	esac
done
