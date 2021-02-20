#!/bin/bash

#work directory generation
workdir="/tmp/task-3-$(tr -dc A-Za-z0-9_- </dev/urandom | head -c 8 | xargs)"
mkdir ${workdir}

#check input arguments
badargs=false
if [ ${#1} -gt 0 -a ${#2} -gt 0 ] 
then
    
    if echo $1 | egrep '^[0-9a-zA-Z]+[-_.]*[0-9a-zA-Z]+$' &>/dev/null
    then
        ghuser=$1
    else
        badargs=true
    fi

    if echo $2 | egrep '^[0-9a-zA-Z]+[-_.]*[0-9a-zA-Z]+$' &>/dev/null
    then
        ghrep=$2
    else
        badargs=true
    fi
    
else
    badargs=true
fi

if ${badargs}
then
    echo 'No arguments entered, assuming GitHub user and repository is ant-design and ant-design respectivly.'
    echo
    ghuser=ant-design
    ghrep=ant-design
fi

#try to download page whith pull requests
echo "Try to download page whith open pull requests from https://github.com/${ghuser}/${ghrep}/pulls?q=is%3Aopen+"
curl https://github.com/${ghuser}/${ghrep}/pulls?q=is%3Aopen+ > ${workdir}/pg1
echo

#looking for how much pages of pull requests
numb_pgs=$(cat ${workdir}/pg1 | awk -F'<' '/data-total-pages/ {print$5}' | awk -F'"' '/data-total-pages/ {print$4}')

#download all rest pages (if more then one) with pull requests list
if [ ${#numb_pgs} -gt 0 ]
then
    np=2
    echo "More then one page with pull requests. Downloading all pages..."
    while [ ${numb_pgs} -ge ${np} ]
    do
        echo "Page ${np}"
        curl "https://github.com/${ghuser}/${ghrep}/pulls?page=${np}&q=is%3Aopen+" > ${workdir}/pg${np}
        echo
        let np+=1
    done
fi

#all pullers
#cat ${workdir}/pg1 | awk -F'<' '/Open pull requests created by/ {print$2}' | awk -F'>' '{print$2}' > pullers

#set cycle dilimiter as "\n"
IFS=$'\n'
#save result of parsing here
touch ${workdir}/result

#parsing every downloaded file
for pgfile in $(ls ${workdir}/pg[0-9]*)
do
    #initialise values for each file:
    #variable stores issue number of pull request
    issue_value=
    #who created pull request
    user_name=
    #is PR with label?
    lbl_xst=false
    #how many checks in total
    chcks=0
    #how many checks is OK
    chcksok=0
    
    #progress bar
    np=0
    numb_lines=$(wc -l ${pgfile} | cut -d" " -f1)
    let step=${numb_lines}/50
    echo "Processing ${pgfile}..."

    for str in $(cat ${pgfile})
    do

        #show the progress bar
        [[ ${np}%${step} -eq 0 ]] && echo -n "#"
        let np+=1
        
        #try to look for issue_value
        iss_val=$(echo ${str} | awk -F'"' '/div id="issue_/ {print$2}')
        #echo "iss_val=${iss_val}"
        #echo "issue_value=${issue_value}"

        #while issue_value is not assigned if statment will looking for first iteration
        if [ ${#issue_value} -eq 0 ]
        then
             [ ${#iss_val} -ne 0 ] && issue_value=${iss_val}
        else
         #issue_value have a value already 
            
            #if we find out next issue_value then it is time to save all values!
            if [ ${#iss_val} -ne 0 ]
            then

                #save all
                echo "${user_name}:${lbl_xst}:${chcksok} / ${chcks}" >> ${workdir}/result

             #else looking for another values and issue_value too
            else
                #
                #try to find user who created the pull request
                usr_nm=$(echo ${str} | awk -F'>|<' '/Open pull requests created by/ {print$3}')
                [ ${#usr_nm} -ne 0 ] && user_name=${usr_nm}
                
                #try to find if label exist
                issue_label=$(echo ${str} | awk '/IssueLabel/ {print}')
                [ ${#issue_label} -ne 0 ] && lbl_xst=true

                #if checks exist then let see how many and how many is ok
                chck_xst=$(echo ${str} | awk -F'"' '/checks OK/ {print$2}')
                if [ ${#chck_xst} -ne 0 ]
                then
                    chcks=$(echo ${chck_xst} | cut -d" " -f3)
                    chcksok=$(echo ${chck_xst} | cut -d" " -f1)
                fi
                
            fi

        fi

    done

    echo
    #save last values for every file
    echo "${user_name}:${lbl_xst}:${chcksok} / ${chcks}" >> ${workdir}/result

done
echo

#find contributors with two or more pull requests
echo "The most active contributors with more then one pull request:"
echo "NMBR_PR USER_NAME"
for str in $(cat ${workdir}/result | cut -d: -f1 | sort | uniq -c)
do
    [ $(echo ${str} | tr -s ' ' | cut -d" " -f2) -gt 1 ] && echo ${str}
done
echo

#pull requests with label
user_name=
np=0
echo "Label is attached to PR of following users:"
for str in $(cat ${workdir}/result | sort)
do
    #check if PR have label
    if $(echo ${str} | cut -d: -f2)
    then
        
        #output will contain only one user name even user have more then one open PR
        usr_nm=$(echo ${str} | cut -d: -f1)
        if [ "${user_name}" != "${usr_nm}" ]
        then
            #will output in four column
            let np+=1
            if [ ${#usr_nm} -lt 8 ]
            then echo -ne "${usr_nm}\t"
            else echo -n ${usr_nm}
            fi
            echo -ne "\t"
            user_name=${usr_nm}
            [[ $np%4 -eq 0 ]] && echo
        fi
    fi
done
echo
echo
#display checks of every open PR
echo "User's PR with checks:"
echo -e "USER_NAME\tCHEKS_OK / CHECKS"
for str in $(cat ${workdir}/result | cut -d: -f1,3 | sort)
do
    #check if PR have chcks
    if [ -n $(echo ${str} | cut -d: -f2) ]
    then
        #
        usr_nm=$(echo ${str} | cut -d: -f1)
        if [ ${#usr_nm} -lt 8 ]
        then echo -ne "${usr_nm}\t"
        else echo -n ${usr_nm}
        fi        
        echo -ne "\t"
        echo ${str} | cut -d: -f2
    fi
done
echo
#user may seve result of parsing if he want
echo "Do you want to save result file?"
read -p "(yes/No): " choise
if [ "${choise:0:1}" = "y" -o "${choise:0:1}" = "Y" ]
then
    #path to save is homedir unless otherwise specified
    read -p "(~/result): " choisepath
    if [ ${#choisepath} -eq 0 ] 
    then 
        choisepath="${HOME}/result"
    else
        [ "${choisepath:0:1}" = "~" ] && choisepath=${HOME}${choisepath:1}
    fi
    cp ${workdir}/result ${choisepath}
fi

#clean up after itself
rm -rf ${workdir}

exit