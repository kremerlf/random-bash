#!/bin/bash

cap=$1
num=$2

echo "/*
Autor: Luiz Felipe Kremer
-----
descricao:
*/

#include <stdio.h>
#include <stdlib.h>

int main(void)
{

	return 0;
}" > $(printf "cap%02d_exe%02d.c" $cap $num) 

