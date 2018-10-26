#!/usr/bin/ksh

trap " echo EXIT  ; kill -kill $$" 0
trap " echo HANGUP  ; kill -kill $$" 1
trap " echo INTR ; kill -kill $$ " 2
trap " echo QUIT  ; kill -kill $$" 3
trap " echo KILL  ; kill -kill $$" 9
trap " echo Term  ; kill -kill $$" 15

echo $$
echo $PPID
while true
do
	echo satya
	sleep 50
done

stty erase 

