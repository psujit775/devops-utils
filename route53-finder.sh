#!/bin/bash

SLEEPY_FACE="\xf0\x9f\xa5\xb1\0\x00"
SEARCH="\xf0\x9f\x94\x8d\0\x00"
HELP_TEXT="Example: ./route53-finder.sh <hosted-zone-id> <text-to-search>"

finder () {
  
  aws route53 list-resource-record-sets --hosted-zone-id $hosted_zone_id --query 'ResourceRecordSets[?starts_with(Name, '\'${text}\'')]' --output=json|jq -r '.[] | [.Name, .Type, .TTL, (.ResourceRecords[] | .Value)]'

}


args_checker () {
  if [ -z $1 ]; then
    echo -e "Hosted Zone not provided ${SLEEPY_FACE}"
    echo -e $HELP_TEXT
    exit 0
  elif [ -z $2 ]; then
    echo -e "Can't search empty value ${SLEEPY_FACE}"
    echo -e "$HELP_TEXT"
  else
    echo  -e "Searching ${SEARCH}"
    hosted_zone_id=$1
    text=$2
    finder $hosted_zone_id $text
  fi


}

args_checker $1 $2
