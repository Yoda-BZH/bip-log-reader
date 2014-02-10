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

cacheColors="/tmp/bip-log-colors"
if [ -f $cacheColors ]
then
	rm $cacheColors
fi
touch $cacheColors

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
				echo "$lineTime >>> Mode change $lineUser $lineText"
				continue	
			fi

			if [[ $lineText == *has\ joined* ]]
			then
				echo -en "$lineTime >>> Join: "
				echo -e $lineUser $lineText
				continue
			fi
			
			if [[ $lineText == *has\ quit* ]]
			then
				echo -en "$lineTime <<< Quit: "
				echo -e $lineUser $lineText
				continue
			fi
			
			if [[ $lineText == *has\ left* ]]
			then
				echo -en "$lineTime <<< Left: "
				echo -e $lineUser $lineText
				continue
			fi

			if [[ $lineText == *changed\ topic\ of* ]]
			then
				echo -en "$lineTime +++ $lineUser"
				echo -e $lineText
				continue
			fi

			if [[ $lineText == *is\ now\ known\ as\ * ]]
			then
				echo -e "$lineTime +++ $lineUser $lineText"
				continue
			fi

			echo "Unknow token: $line"
			;;
		">"|"<")
			isMe=0
			## I am talking
			if [ "$lineUser" == "*" ]
			then
				isMe=1
				lineUser=`echo $lineText | cut -d" " -f 1`
				lineText=${lineText#* }
			fi

			if [ $lineToken == ">" ]
			then
				lineUser=${lineUser/:/}
				colorNumber="208"
				bracketsColor="21"
			## other people are talking
			else
				cachedColor=`cat $cacheColors | grep "^$lineUser " | cut -d" " -f 2`
				if [ -z "$cachedColor" ]
				then
					## this could be improved
					md5User=`echo $lineUser | md5sum`
					charUser=${md5User:0:1}
					charUser=${charUser,,}
					color="color$charUser"
					colorNumber=${!color}
					echo "$lineUser $colorNumber" >> $cacheColors
				else
					colorNumber=$cachedColor
				fi
				bracketsColor="226"
			fi

			echo -n "$lineTime "
			if [ $isMe -eq 1 ]
			then
				echo -n "*** "
			else
				echo -en "\e[38;5;${bracketsColor}m<\e[0m"
			fi
			echo -en "\e[38;5;${colorNumber}m$lineUser\e[0m"
			if [ $isMe -eq 0 ]
			then
				echo -en "\e[38;5;${bracketsColor}m>\e[0m"
			fi
			echo " $lineText"
			;;
	esac
done

rm $cacheColors
