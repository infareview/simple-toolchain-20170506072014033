#!/bin/bash


######################################################################### Informatica Code Reviewer ########################################################################################
################################################################################ Version 1 #################################################################################################
#### Create Date - 24/04/2017 #############################
#### Created By  - Gaurav Sharma ##########################
#### Email in case of any issues - gaush031@in.ibm.com ####

#### Script to get Workflow and Session Details of any Workflow .XML extract from the Repository Manager. ####
#### File Name should be given as argument with the Script for execution. For executing the Script over file Test.XML give command -- [ sh Infa_Code_Reviewer.sh Test.XML ] ####
#### Output of the Script will be a .log file with name passed as argument. Example - If Script executed for Text.XML output log file will be Test.log ####

#### Variable Assignment ####
i=1
#### Log file extension ####
        extention='.log'
echo Source.txt > fname_tmp.txt 2>/dev/null
if [ $? -ne 0 ]
then
   # die with unsuccessful shell script termination exit status # 1
   echo -e "Script completed with Error \nPermission denied for Creating File : Please check the create File inside the Directory." > Infa_Code_Reviewer_error.txt
   exit 1
fi
        file_name="$(sed 's/.xml//g' fname_tmp.txt)" 2>/dev/null
#### Output File Name ####
        log="$file_name$extention"
#### TO check if File exist in Directory ####
if [ ! -f Source.txt ]
then
   # die with unsuccessful shell script termination exit status # 2
   echo -e "Script completed with Error \nFile not Found : Please check the File inside the Directory." > Infa_Code_Reviewer_error.txt
   rm fname_tmp.txt
   exit 2
fi
#### Mapping count in the Workflow ####
        count="$(grep  -c MAPPINGNAME Source.txt 2>/dev/null)"
#### Extracting Session Tag value in Session.xml ####
                sed -n '/<SESSION DESCRIPTION/,/<\/SESSION>/p' Source.txt > Session.xml
#### Extracting MAPPING value in Session.xml ####
                                sed -n '/<MAPPING DESCRIPTION/,/<\/MAPPING>/p' Source.txt > Mapping.xml
#### Extracting Workflow Name ####
        wf_name="$(grep 'WORKFLOW DESCRIPTION' Source.txt | cut -d'"' -f12)"
        echo "========================== $wf_name ========================== " > $log
if [ $count -eq 0 ]
then
   # die with unsuccessful shell script termination exit status # 3
   echo -e "Script completed with Error \nFile Format Incorrect : Please check the File format, It should be XML File of Workflow exported from Repository Manager." > Infa_Code_Reviewer_error.txt
   rm fname_tmp.txt
   exit 3
fi
#### Extracting SESSION DESCRIPTION details for each Session separately ####
echo -e "\n========================== SESSION PROPERTIES ==========================\n" >> $log
for (( j=1 ; j <= $count  ; j++ ))
        do
                awk '/SESSION DESCRIPTION/{i++}i=='"$j"'' Session.xml > abc.txt
                                awk '/MAPPING DESCRIPTION/{i++}i=='"$j"'' Mapping.xml > def.txt
        #### Session Name ####
                        s_name="$(grep 'MAPPINGNAME' abc.txt |cut -d'"' -f8)"
                                        echo -e "\n$j. SESSION : $s_name" >> $log
        #### Mapping Name ####
                        m_name="$(grep 'MAPPINGNAME' abc.txt |cut -d'"' -f6)"
                                        echo -e "\n   MAPPING : $m_name" >> $log
        #### Session Log File ####
                        s_log_fname="$(grep 'Session Log File Name' abc.txt |cut -d'"' -f4)"
                        Slog_Dir="$(grep 'Session Log File directory' abc.txt | cut -d'"' -f4|sed 's/&#x5c;/\//g'|sort|uniq |sed '/^$/d')"
                                        echo -e "\n   SESSION LOG FILE NAME : $s_log_fname   " >> $log
                                        echo -e "\n   SESSION LOG FILE DIRECTORY : $Slog_Dir   " >> $log
        #### Write Backward Compatible Session ####
                        wbc="$(grep 'Write Backward Compatible Session Log File' abc.txt |awk '{print Source.txt0}' |sed 's/[=">/]//g')"
                                        echo -e "\n   WRITE BACKWARD COMPATIBLE LOG FILE : $wbc   " >> $log
        #### Stop on Errors ####
                        Stop_error="$(grep 'Stop on errors' abc.txt | cut -d'"' -f4)"
                                        echo -e "\n   STOP ON ERRORS : $Stop_error" >> $log
        #### Commit Interval ####
                        commit_interval="$(grep 'Commit Interval' abc.txt |cut -d'"' -f4)"
                                        echo -e "\n   COMMIT INTERVAL : $commit_interval \n" >> $log
                #### Sources used in Mapping ####
                                        echo '   SOURCE TABLES : ' >> $log
                                                grep 'SESSIONEXTENSION DSQINSTNAME' abc.txt | cut -d'"' -f8 |sort|uniq >> $log
                #### Targets used in Mapping ####
                                        echo -e "\n   TARGET TABLES : " >> $log
                                                grep 'SESSIONEXTENSION NAME ="Relational Writer"' abc.txt |cut -d'"' -f4|sort|uniq >> $log
                                        echo -e "\n   TARGET FILES : " >> $log
                                                grep 'Output filename' abc.txt | cut -d'"' -f4 |sort|uniq >> $log
                        Output_Dir="$(grep 'Output file directory' abc.txt | cut -d'"' -f4|sed 's/&#x5c;/\//g'|sort|uniq |sed '/^$/d')"
                                        echo -e "\n   TARGET FILES DIRECTORY : \n $Output_Dir   " >> $log
        #### Rejected Files ####
                        r_filename="$(grep 'Reject filename' abc.txt |cut -d'"' -f4)"
                                        echo -e "\n   REJECTED FILES : \n $r_filename   " >> $log
                        Reject_Dir="$(grep 'Reject file directory' abc.txt | cut -d'"' -f4|sed 's/&#x5c;/\//g'|sort|uniq |sed '/^$/d')"
                                        echo -e "\n   REJECTED FILES DIRECTORY : \n $Reject_Dir   " >> $log
                                                                                grep 'TRANSFORMATION DESCRIPTION' def.txt | awk -F\" '{print $4,": ",$2}' >> $log
        echo -e '\n-----------------------------------------------------------------------------------------------------------------------------------------------------------------------' >> $log
        done
                echo -e "\n========================== WORKFLOW PROPERTIES ==========================\n" >> $log
                #### Parameter File used in Workflow ####
                        param="$(grep 'Parameter Filename' Source.txt |  cut -d'"' -f4|sed 's/&#x5c;/\//g'|sort|uniq |sed '/^$/d')"
                                        echo -e "   PARAMETER FILE : $param \n" >> $log
                                        echo '   CONNECTIONS : ' >> $log
                #### Connection Values used in Workflow ####
                        connection="$(grep 'CONNECTIONREFERENCE' Source.txt | cut -d'"' -f12 | sort|uniq|sed '/^$/d')"
                                        echo -e "\t\t $connection " >> $log
echo -e '\n======================================================================= END OF REPORT =========================================================================================' >> $log
        #### Delete Temp Files ####
rm fname_tmp.txt
rm Session.xml
rm abc.txt
############################################################################################################################################################################################
######################################################################################## END OF SCRIPT #####################################################################################
############################################################################################################################################################################################
