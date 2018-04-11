#!/bin/bash
function extractFromXML() {
  echo $1 | xpath -q -e '//member[name="'$2'"]/value/string/text()'
}

function getXMLrpc() {
  echo "<?xml version='1.0'?>"
  echo "<methodCall>"
  echo "  <methodName>getLatestBuilds</methodName>"
  echo "  <params>"
  echo "    <param><value><string>"$1"</string></value></param>"
  echo "    <param>"
  echo "      <value><struct>"
  echo "        <member><name>__starstar</name><value><boolean>1</boolean></value></member>"
  echo "        <member><name>package</name><value><string>"$2"</string></value></member>"
  echo "      </struct></value>"
  echo "    </param>"
  echo "  </params>"
  echo "</methodCall>"
}

xmlrpc=rpc$$.xml
getXMLrpc "$1" "$2" > $xmlrpc

latestBuild=$(curl --data @$xmlrpc http://brewhub.devel.redhat.com/brewhub)
rm rpc$$.xml

package_name=$(extractFromXML "$latestBuild" "package_name")
version=$(extractFromXML "$latestBuild" "version")
release=$(extractFromXML "$latestBuild" "release")
nvr=$(extractFromXML "$latestBuild" "nvr")

url=http://download.eng.bos.redhat.com/brewroot/packages/$package_name/$version/$release/win/$nvr.i686.zip
wget $url
