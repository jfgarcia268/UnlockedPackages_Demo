#!/usr/bin/env bash

#---------------------------------------------
#Date: 06/20/2020
#Code by: Juan Felipe Garcia
#---------------------------------------------

DEVHUB_URL=$1

echo "## Getting Version From Project File sfdx-project.json"
VERSION_ATTRIBUTE=$(jq .packageDirectories[0].versionNumber sfdx-project.json)
VERSION="${VERSION_ATTRIBUTE//\"}"
MAYOR_VERSION="$(cut -d'.' -f1 <<< "$VERSION")"
MINOR_VERSION="$(cut -d'.' -f2 <<< "$VERSION")"
PATCH_VERSION="$(cut -d'.' -f3 <<< "$VERSION")"

echo "## Getting Latest Build Number"
RESULT=$(sfdx force:data:soql:query --json --usetoolingapi --targetusername="$DEVHUB_URL" --query="SELECT BuildNumber, SubscriberPackageVersionId FROM Package2Version WHERE MajorVersion=${MAYOR_VERSION} AND MinorVersion=${MINOR_VERSION} AND PatchVersion=${PATCH_VERSION} ORDER BY BuildNumber DESC LIMIT 1" )
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

