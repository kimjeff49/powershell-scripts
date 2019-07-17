param([string] $TargetDirectory)

<#
    .SYNOPSIS
        Mimics some JUnit XML attributes.
    .DESCRIPTION
        JUnitXmlData is a class for creating objects out of JUnit XML attributes, but can be
        modified to hold more data from JUnit XML outputs 
#>
class JUnitXmlData {
    [string]$Filename;
    [string]$Tests;
    [string]$Failures;

    JUnitXmlData(
        [string]$fn,
        [string]$t,
        [string]$f
    ){
        $this.Filename = $fn;
        $this.Tests = $t;
        $this.Failures = $f;
    }
}
function WriteStartXml {
param ([string]$Name)

<# 
    .SYNOPSIS
        Writes the beginning of the XML File.
    .DESCRIPTION
        The WriteStartXml function specifies the type of indentation, number of indentations, and
        the indentation character. Then adds the starter tag to specify xml version and adds the
        root folder.
#>

    $XmlWriter.Formatting = 'Indented';
    $XmlWriter.Indentation = 1;
    $XmlWriter.IndentChar = "`t";
    $XmlWriter.WriteStartDocument();
    $XmlWriter.WriteStartElement("Folder");
    $XmlWriter.WriteAttributeString("name", $Name);
}
function WriteEndXml {

<#
    .SYNOPSIS
        Writes the end of the XML File.
    .DESCRIPTION
        The WriteEndXml function finishes and closes the root tag then usese the .Flush() function
        to unload the buffer and to write onto the file. Then the function closes the file with
        the Close() function.
#>

    $XmlWriter.WriteEndElement();
    $XmlWriter.WriteEndDocument();
    $XmlWriter.Flush();
    $XmlWriter.Close();
}

function CreateHashtable {
<#
    .SYNOPSIS
        Recursive function to make nested hashmaps based on the attributes of a file's path.
    .DESCRIPTION
        The CreateHashtable cmdlet takes in a parameter of type ArrayList named Attributes and
        a parameter of type hashtable named MultiAttribute. The Attributes parameter passes
        an Arraylist of a .spec.ts file's path split by its '\'.

        For example:
            Path: "History\International_History\CV_International\CV_Locale_Asia1.spec.ts"
            List: [History, International_History, CV_International, CV_Local_Asia1.spec.ts]
        
        The MultiAttribute parameter passes an empty hashmap that the recursive function will
        nest hashmaps into. The hashmap is passed in as a parameter instead of being declared
        as a local varaible within the function because the function is recursive and also needs
        to start at the root directory every function call of CreateHashtable within
        ExtractAttributes.
    .PARAMETER Attributes
    .PARAMETER MultiAttribute
#>

    [CmdletBinding()]
    param(
        [System.Collections.ArrayList]$Attributes,
        [hashtable]$MultiAttribute
    )

    # Check if it is .spec.ts.
    $Temp = $Attributes[0];
    If ($Temp -like "*.spec.ts") {
        $MultiAttribute.Add($Temp, $Temp);
    # Check if it is already present within the base of the MultiAttribute.
    } ElseIf ($MultiAttribute.ContainsKey($Temp)){
        $Attributes.Remove($Temp);
        CreateHashtable -Attributes $Attributes -MultiAttribute $MultiAttribute.$Temp;
    # Create a new hashtable and traverse into the hashtable.
    } Else {
        $MultiAttribute.Add($Temp, @{});
        $Attributes.Remove($Temp);
        CreateHashtable -Attributes $Attributes -MultiAttribute $MultiAttribute.$Temp;
    }
}

function ExtractAttributes {
<#
    .SYNOPSIS
        Cycles through each file within the directory 
    .DESCRIPTION
#>

    [CmdletBinding()]
    param(
        [System.Array]$Dir
    )

    $MultiAttribute = @{}
    foreach($File in $Dir) {
        $SplitFilename = $File -Split '\\';
        $List = New-Object System.Collections.ArrayList($null);
        $List.AddRange($SplitFilename[4..($SplitFilename.Count - 1)]);
        CreateHashtable -Attributes $List -MultiAttribute $MultiAttribute;
    }

    Return $MultiAttribute;
}

function CreateXml {

<#
    .SYNOPSIS
    .DESCRIPTION
#>

    [CmdletBinding()]
    param(
        [hashtable]$Parent
    )

    $Parent.GetEnumerator() | Foreach-Object {
        $i = $_;
        if ($i.Value -is [hashtable]) {
            $XmlWriter.WriteStartElement("Folder")
            $XmlWriter.WriteAttributeString("name", $i.Key);
            CreateXml -Parent $i.Value -Xmls $Xmls;
            $XmlWriter.WriteEndElement();
        } else {
            $XmlWriter.WriteStartElement("File");
            $XmlWriter.WriteAttributeString("name", $i.Key);
            $XmlWriter.WriteEndElement();
        }
    }
}

function main {

<#
    .SYNOPSIS
    .DESCRIPTION
#>

    [CmdletBinding()]
    param(
        [string] $Dir
    )

    $DirList = Get-ChildItem -Recurse -Path $Dir

    $MappedAttributes = ExtractAttributes -Dir $DirList;

    WriteStartXml;

    CreateXml -Parent $MappedAttributes;

    WriteEndXml;
}

#################################################################
#                         Start Script                          #
#################################################################

# Set in the global scope since XmlTextWriter behaves strangely.
$OutFile = "C:\Users\LQL3ZSL\Desktop\Example2.xml";
$global:XmlWriter = New-Object System.Xml.XmlTextWriter($OutFile, $null);

main -Dir $TargetDirectory;