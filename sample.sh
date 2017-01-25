#!/bin/bash
##


# echo "ENTER A NUMBER"
# read DATA

DATA=$1

case $DATA in

	one)
		echo "You entered one"
		;;
	two)
		echo "You entered two"
		;;
	three)
		echo "You entered three"
		;;

	*)
		echo "You entered something else"
		echo "or you entered nothing."
		echo ' '
		echo 'Dumbass.'
		echo ' '

esac