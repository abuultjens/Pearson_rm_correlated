#!/bin/bash


INFILE=${1}
OUTFILE=${2}
N_SPLIT=10


# generate random prefix for all tmp files
RAND_1=`echo $((1 + RANDOM % 100))`
RAND_2=`echo $((100 + RANDOM % 200))`
RAND_3=`echo $((200 + RANDOM % 300))`
RAND=`echo "${RAND_1}${RAND_2}${RAND_3}"`

# make fofn from infile
head -1 ${INFILE} | tr ',' '\n' | tail -n +2 > ${RAND}_fofn.txt

# make fake target file
echo "INDEX,VAL" > ${RAND}_out.csv
for TAXA in $(cat ${RAND}_fofn.txt); do
        RAND_1=`echo $((1 + RANDOM % 100))`
        RAND_2=`echo $((100 + RANDOM % 200))`
        RAND_3=`echo $((200 + RANDOM % 300))`
        RAND_4=`echo $((300 + RANDOM % 400))`
        RAND_5=`echo $((400 + RANDOM % 500))`
        RAND_6=`echo $((500 + RANDOM % 600))`
        echo "${TAXA},${RAND_1}${RAND_2}${RAND_3}.${RAND_4}${RAND_5}${RAND_6}" >> ${RAND}_out.csv
done

# calc pearson R
python ~/github/pearson_correlation/pearsonR.py ${RAND}_out.csv ${INFILE} ${RAND}_test_pearson.csv

# rm sign
tr -d '-' < ${RAND}_test_pearson.csv | cut -b1-17 > ${RAND}_INDEX.csv

# paste and tr tab for comma
paste ${RAND}_INDEX.csv ${INFILE} | tr '\t' ',' > ${RAND}_INDEX_test.csv

# make nr index
tail -n +2 ${RAND}_INDEX.csv | sort | uniq > ${RAND}_uniq_list.csv
FOFN=${RAND}_uniq_list.csv

# make dir for tmp files
mkdir ${RAND}

# get number of taxa in fofn
N_TAXA=`wc -l ${FOFN} | awk '{print $1}'`

# split fofn
split -d -l ${N_SPLIT} ${FOFN} ${RAND}/FOFN_${RAND}_

# make group fofn
ls ${RAND}/FOFN_${RAND}_* > ${RAND}/${RAND}_FOFN.txt

# loop through groups
for GROUP in $(cat ${RAND}/${RAND}_FOFN.txt); do

	FILE=`echo ${GROUP}`

	# loop through isolates in group
	for TAXA in $(cat ${FILE}); do
		grep ^"${TAXA}," ${RAND}_INDEX_test.csv | head -1 >> ${RAND}_${OUTFILE} &
	done

	wait

done

# write outfile header
head -1 ${INFILE} > ${OUTFILE}

# write outfile
cut -f 2- -d ',' ${RAND}_${OUTFILE} >> ${OUTFILE}

# rm tmp files		
rm -r ${RAND}
rm *${RAND}*


