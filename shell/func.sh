#!/bin/bash


function  success(){
	echo -e "\033[32m $1 \033[0m"
	return 0
}

function alert(){
	echo -e "\033[33m $1 \033[0m"
	return 0
}

function fail(){
	echo -e "\033[31m $1 \033[0m"
	return 0
}