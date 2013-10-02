#!/bin/bash

GITHUB_API='https://api.github.com/';

user=$1;
location=$2;
repository=$3;


[ $user ] || {
  echo 'You need to supply a user for the script, exitting.';
  exit 1;
};
[ $repository ] || {
  echo 'You need to supply the name of the repository, exitting.';
  exit 1;
};
[ $location ] || location='./';

# We need to swap the spaces for '_' because of bash syntax
hashes=$( grep -r 'TODO:' $location | sed -n "s/\([^:]*\):#* *TODO: *\([^ ]*.*\)/\1=\2/p" | sed 's/ /_/g' )

# First get the left field
files=(
  $( echo -e "$hashes" | awk --field-separator = '{ print $1 }'; )
);
# Then get the associated todo rule
rules=(
  $( echo -e "$hashes" | awk --field-separator = '{ print $2 }'; )
);
# Get the number of hashes present
hash_amount=${#files[@]};

for (( hash_number; hash_number<$hash_amount; hash_number++ )); do
  current_file=${files[$hash_number]};
  current_rule=$( echo ${rules[$hash_number]} | sed 's/_/ /g' );
  curl -i -u $user -d "{\"title\":\"$current_rule\",\"body\":\"$current_file\"}" ${GITHUB_API}repos/${user}/${repository}/issues
done;
