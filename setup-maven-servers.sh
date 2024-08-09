# Initialize the XML strings
MAVEN_SERVERS_XML='';
MAVEN_MIRRORS_XML='';

echo "Setup the Maven server credentials and mirrors for the settings.xml"

# Process servers
for row in $(echo "${MAVEN_SERVERS}" | jq -r '.[] | @base64'); do
    _jq() {
        echo "${row}" | base64 -d | jq -r "${1}"
    }
   export MAVEN_REPO_SERVER_ID=$(_jq '.id')
   export MAVEN_REPO_SERVER_USERNAME=$(_jq '.username')
   export MAVEN_REPO_SERVER_PASSWORD=$(_jq '.password')

   templateReplaced=$(envsubst < $SETTINGS_SERVER_TEMPLATE_FILE);
   MAVEN_SERVERS_XML="${MAVEN_SERVERS_XML}${templateReplaced}"
done

# Process mirrors
for row in $(echo "${MAVEN_MIRRORS}" | jq -r '.[] | @base64'); do
    _jq() {
        echo "${row}" | base64 -d | jq -r "${1}"
    }
   export MAVEN_MIRROR_ID=$(_jq '.id')
   export MAVEN_MIRROR_URL=$(_jq '.url')
   export MAVEN_MIRROR_MIRROROF=$(_jq '.mirrorOf')

   templateReplaced=$(envsubst < $SETTINGS_MIRROR_TEMPLATE_FILE);
   MAVEN_MIRRORS_XML="${MAVEN_MIRRORS_XML}${templateReplaced}"
done

# Export the accumulated XML sections
export MAVEN_SERVERS_XML="$MAVEN_SERVERS_XML"
export MAVEN_MIRRORS_XML="$MAVEN_MIRRORS_XML"

echo "The following servers section that is going to be replaced in the settings.xml:\n $MAVEN_SERVERS_XML"
echo "The following mirrors section that is going to be replaced in the settings.xml:\n $MAVEN_MIRRORS_XML"

# Replace placeholders in the main template
envsubst < ${SETTINGS_TEMPLATE_FILE} > ${SETTINGS_FILE}
cat ${SETTINGS_FILE}
