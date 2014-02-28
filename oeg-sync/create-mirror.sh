#!/bin/bash

#
# Copyright (c) 2012-2013 Ontology Engineering Group,
#                         Universidad Politécnica de Madrid, Spain
# 	http://www.oeg-upm.net/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# 	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

USER=ocorcho
PASSWORD=$2
ORG=oeg-upm
TEAMID=568017  #This can be obtained doing  curl -u ''$USER:$PASSWORD'' https://api.github.com/orgs/$ORG/teams
REPO_URL=$1
REGEX="^https:\/\/github.com/([a-zA-Z0-9_\.-]+)/([a-zA-Z0-9_\.-]+)$"

display_usage() { 
    echo "This script creates a mirror repository in https://github.com/oeg-upm" 
    echo "Usage: create-mirror.sh <original-repo-url> <<your password>>"
    echo "Eg. create-mirror.sh https://github.com/nandana/misc-scripts <<your password>>"
} 

# check for the number of parameters
if [  $# -le 1 ]
 then 
  display_usage
  exit 1
fi 

#validate the repository argument and extract the name
if [[ $REPO_URL =~ $REGEX ]]; then
    REPO=${1##*/}
    echo "Cloning the repository '$REPO'"
else
    echo "The repository parameter '$1' does not match the pattern https://github.com/<user>/<repo>"
    exit 1
fi

# create an empty repository for the corresponding organisation and assigning it to the corresponding team inside the organisation
#Uncomment the following if it is for a single user
#curl -u ''$USER:$PASSWORD'' https://api.github.com/user/repos -d '{"name":"'$REPO'"}'
#Use the following if it is for an organisation and a team (although the team bit does not seem to work right now)
curl -u ''$USER:$PASSWORD'' https://api.github.com/orgs/$ORG/repos -d '{"name":"'$REPO'"}'
curl -u ''$USER:$PASSWORD'' -X PUT https://api.github.com/teams/$TEAMID/repos/$ORG/$REPO

# create a mirrored clone
git clone --mirror $REPO_URL.git
# set the url to make the push easier
cd $REPO.git
#git remote set-url --push origin https://$USER:$PASSWORD@github.com/$USER/$REPO
git remote set-url --push origin https://$USER:$PASSWORD@github.com/$ORG/$REPO

# Update the mirror
git fetch -p origin
git push --mirror

