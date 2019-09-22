#!/usr/bin/env bash 
echo Running Analysis .....
# Run(s) the report(s) specified in 'prefix'.ini (section) with the associated parameters.
# The output report is generated in ../output with the name {prefix}{rmd}.pdf
# Input:   prefix  - unique name of the transaction coming from the calling system, the name of the ini file.
# Output: {prefix}{rmd}.pdf
# Example of Running: ./analyse.sh prefix

#set workingdir
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
echo 'Info :: Parent path = ' $parent_path
cd "$parent_path"
ls -lah
WORKDIR=$parent_path
Rfilename=$WORKDIR/runRmd.R 
export inputini="analyse.ini"

#default values for parameters: CLIENTID, YEAR, MONTH, CURRENCY, TO_DIVIDE
prefix='pref'
CLIENTID='42756'
YEAR='2017'
MONTH='2017-09'
CURRENCY='NOK'
TO_DIVIDE='2000'

#get the prefix from commandline argument 
if [ -n $1 ];  then 
 prefix=$1
fi

#set the parameters from the $prefix.ini file
sysconfdir="."
if test -f ${sysconfdir}/${prefix}.ini; then
  . ${sysconfdir}/${prefix}.ini
fi

#set the required parameters from the $prefix.ini configfile
if [ -n ${clientid} ];  then 
 CLIENTID=${clientid}
fi
if [ -n ${year} ];  then 
 YEAR=${year}
fi
if [ -n ${month} ];  then 
 MONTH=${month}
fi
if [ -n ${currency} ];  then
 CURRENCY=${currency}
fi
if [ -n ${to_divide} ];  then 
 TO_DIVIDE=${to_divide}
fi
if [ -n ${startmonth} ];  then 
 STARTMONTH=${startmonth}
fi
if [ -n ${endmonth} ];  then 
 ENDMONTH=${endmonth}
fi

#do the analysis

for rmdfile in $WORKDIR/rmd/${rmd}
do
echo $rmdfile
/usr/bin/env Rscript $Rfilename $WORKDIR $rmdfile ${CLIENTID} ${YEAR} ${MONTH} ${CURRENCY} ${TO_DIVIDE} ${STARTMONTH} ${ENDMONTH} ${prefix}
result=$(python -c "import analyse_libs; analyse_libs.split_filename('${rmdfile}')")
cd rmd
echo ${result}'.'${extension}
mv ${result}'.'${extension} ${prefix}${result}'.'${extension}
mv ${prefix}${result}'.'${extension} ../output
done
