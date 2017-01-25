#!/bin/bash
##

TOP_DIR=$1

echo "ENTER A NUMBER"

read DATA

case $DATA in
	
	1)
		echo "Generating FC Matrices"
		;;
	2)
		echo "You entered two"
		;;
	3)
		echo "You entered three"
		;;

	*)
		echo "You entered something stupid, dumbass"

esac