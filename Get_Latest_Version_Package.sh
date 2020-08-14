#!/usr/bin/env bash

#---------------------------------------------
#Date: 06/20/2020
#Code by: Juan Felipe Garcia
#---------------------------------------------

DEVHUB_URL=$1
PACKAGE_NAME=$2


NUM_PACKAGES=$(jq -c '.packageDirectories | length' sfdx-project.json)
echo "## Getting Version From Project File sfdx-project.json"
for (( i=0; i<$NUM_PACKAGES; i++ ))
do
	PACKAGE=$(jq -r ".packageDirectories[${i}].package" sfdx-project.json)
	echo "$PACKAGE - $PACKAGE_NAME"
	if [ "$PACKAGE" == "$PACKAGE_NAME" ]; then
		VERSION=$(jq -r .packageDirectories[0].versionNumber sfdx-project.json)
		MAYOR_VERSION="$(cut -d'.' -f1 <<< "$VERSION")"
		MINOR_VERSION="$(cut -d'.' -f2 <<< "$VERSION")"
		PATCH_VERSION="$(cut -d'.' -f3 <<< "$VERSION")"
	fi	
done

PACKAGE2_ID=$(jq -r ".packageAliases.${PACKAGE_NAME}"  sfdx-project.json)

echo "## Getting Latest Build Number for Package: $PACKAGE_NAME ($PACKAGE2_ID) "
RESULT=$(sfdx force:data:soql:query --json --usetoolingapi --targetusername="$DEVHUB_URL" --query="SELECT BuildNumber, SubscriberPackageVersionId FROM Package2Version WHERE MajorVersion=${MAYOR_VERSION} AND MinorVersion=${MINOR_VERSION} AND PatchVersion=${PATCH_VERSION} AND Package2Id='${PACKAGE2_ID}' ORDER BY BuildNumber DESC LIMIT 1" )
BUILD_NUMBER=$(jq -r .result.records[0].BuildNumber <<< "$RESULT")
PACKAGE_ID=$(jq -r .result.records[0].SubscriberPackageVersionId <<< "$RESULT")

if [ "$BUILD_NUMBER" != null ]; then
	NEW_VERSION="${MAYOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}.${BUILD_NUMBER}"
	echo "## Recent Build Number found:${BUILD_NUMBER}  New Version: ${NEW_VERSION}  Package ID: $PACKAGE_ID"
	echo "$PACKAGE_ID" > PID.txt
else
	echo "No Records found for query, Result:"
	echo "$RESULT"
fi
