#!/usr/bin/env bash 
echo Creates prefix.ini .....
# Creates 'prefix.ini' by copying the section name and the parameters below from the 'analyse.ini' coresponding to
# the input parameter 'section'.
# Input: section - name of the rmd(s)
#        prefix  - unique name of the transaction coming from the calling system.
# Output: prefix.ini - unique .ini file containning the name of the report(s) and the aassociated params.
# the params in prefix.ini can be updated by the calling system
# Example of Running: ./createprefixini.sh client-section prefix

#set workingdir
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
echo 'Info :: Parent path = ' $parent_path
cd "$parent_path"
ls -lah
WORKDIR=$parent_path
Rfilename=$WORKDIR/runRmd.R 

#default values for parameters: CLIENTID, YEAR, MONTH, CURRENCY, TO_DIVIDE
export inputini='"analyse.ini"'
export section='client-section'
export prefix='prefix'

#get the section, prefix from commandline argument 
if [ -n $1 ];  then 
 section=$1
fi

if [ -n $2 ];  then 
 prefix=$2
fi

#create the base prefix.ini file from the analyse.ini. prefix.ini might be updated with params coming from UI
#output=$(./analysenext.py -i $inputini -s $section -p $prefix)
result=$(python -c "import analyse_libs; analyse_libs.create_prefix_inifile(${inputini}, '${section}', '${prefix}')")

#set the parameters from the $prefix.ini file
sysconfdir="."
if test -f ${sysconfdir}/${prefix}.ini; then
  . ${sysconfdir}/${prefix}.ini
fi

#delete temp${prefix}.ini
rm -f $WORKDIR/temp${prefix}.ini

