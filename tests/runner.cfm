<cfscript>
setting showDebugOutput=false;

param name="url.reporter" default="simple";
param name="url.directory" default="tests.testbox";
param name="url.recurse" default="true";
param name="url.bundles" default="";
param name="url.labels" default="";
param name="url.reportpath" default=expandPath( '/tests/results' );
param name="url.propertiesFilename" default="TEST.properties";
param name="url.propertiesSummary" default="false";
param name="url.editor" default="vscode";
param name="url.bundlesPattern" default="";

include "/testbox/system/runners/HTMLRunner.cfm";
</cfscript>
