#!/bin/bash

#qoutes.json should exist whith read permission
[ ! -r /tmp/quotes.json ] && curl -s https://yandex.ru/news/quotes/graph_2000.json > /tmp/quotes.json

#initialise values:
#index for json-file
a=0
#index for array
b=0
#sum March qoutes
summa=0
#number of qoutes in March
c=0
#min value in March
mins[b]=1000000
#max value in March
maxs[b]=0

#start parsing quotes.json
while [ ! $(jq '.prices['${a}'][0]' /tmp/quotes.json) = null ]
do
    
    #let date from json
    let dt=$(jq '.prices['${a}'][0]' /tmp/quotes.json)/1000
    
    #work only if month is Мarch
    if [ $(date "+%m" --date='@'${dt}) = 03 ]
    then
        
        #extract year from current value of pair qoute-date
        year=$(date "+%Y" --date='@'${dt})

        #extract year from date and place it in array ${years} for first March itaration in quotes.json 
        if [ "${years[0]}" = "" ]
        then
            years[0]=${year}
            echo "${years[0]} are processing now, please wait..."
        fi
        
        #if year does not change, make calculations for March of current year
        if [ "${years[b]}" = "${year}" ]
        then 
            
            #sum qoutes values of current March
            cur_value=$(jq -r '.prices['${a}'][1]' /tmp/quotes.json)
            summa=$(echo "scale=3; ${summa} + ${cur_value}" | bc)
            let c+=1

            #find min value for March
            if [ 1 -eq $(echo "${mins[b]} > ${cur_value}" | bc) ]
            then
                mins[b]=${cur_value}
            fi

            #find max value for March
            if [ 1 -eq $(echo "${maxs[b]} < ${cur_value}" | bc) ]
            then
                maxs[b]=${cur_value}
            fi            
        else
            
            #else, the March of new year has come, add in ${years} value of new year
            years+=(${year})
            #calculate mean value for last March
            means[b]=$(echo "scale=3; ${summa}/${c}" | bc)
            
            let b+=1
            echo "${years[b]} are processing now, please wait..."

            #initialise values:
            #sum March qoutes
            summa=0
            #number of qoutes in March
            c=0
            #min value in March
            mins[b]=1000000
            #max value in March
            maxs[b]=0

        fi

    else

        #then March was parsed, make a big jump :)
        #to skip almost hole year for next March
        if [ $(date "+%m" --date='@'${dt}) = 04 ]
        then
            let a+=210
        fi

    fi

    let a+=1

done

if [ -n "${years[b]}" -a -z "${means[b]}" ]
then
    #calculate last mean value for last March
    means[b]=$(echo "scale=3; ${summa}/${c}" | bc)
else
    let b-=1
fi

minval=100000
echo
for a in $(seq 0 ${b})
do
    #calculate valotile
    valotile[a]=$(echo "scale=3; ${maxs[a]}/2 - ${mins[a]}/2" | bc)

    #output result
    echo "March ${years[a]}:"
    echo "Min qoute - ${mins[a]}; Max qoute - ${maxs[a]}"
    echo "Mean value - ${means[a]}; Valotile - ${valotile[a]}"

    #calculate min valotile
    if [ 1 -eq $(echo "${valotile[a]} < ${minval}" | bc) ]
    then
        minval=${valotile[a]}
        min_val_year=${years[a]}
    fi
done
echo
echo "The least valotile of all years was in ${min_val_year}."

exit