param([string] $TargetDirectory, [string] $OutDirectory)

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
        The CreateHashtable cmdlet creates a nested hashtable structure mimicing the filesystem.
    .PARAMETER FileSystem
        Array of filenames and folders.
    .PARAMETER HashSystem
        Empty Hashtable that will structure all the folders and filenames.
#>

    [CmdletBinding()]
    param(
        [System.Collections.ArrayList]$FileSystem,
        [hashtable]$HashSystem
    )


    $Temp = $FileSystem[0];
    If ($Temp -isnot [System.IO.DirectoryInfo]) {
        $HashSystem.Add($Temp, $Temp);
    # Check if it is already present within the base of the HashSystem.
    } ElseIf ($HashSystem.ContainsKey($Temp)){
        $FileSystem.Remove($Temp);
        CreateHashtable -FileSystem $FileSystem -HashSystem $HashSystem.$Temp;
    # Create a new hashtable and traverse into the hashtable.
    } Else {
        $HashSystem.Add($Temp, @{});
        $FileSystem.Remove($Temp);
        CreateHashtable -FileSystem $FileSystem -HashSystem $HashSystem.$Temp;
    }
}

function ExtractSystem {
<#
    .SYNOPSIS
        Cycles through each file within the directory 
    .DESCRIPTION
#>

    [CmdletBinding()]
    param(
        [System.Array]$Dir
    )

    $HashSystem = @{}
    foreach($File in $Dir) {
        $SplitFilename = $File -Split '\\';
        $List = New-Object System.Collections.ArrayList($null);
        $List.AddRange($SplitFilename[4..($SplitFilename.Count - 1)]);
        CreateHashtable -FileSystem $List -HashSystem $HashSystem;
    }

    Return $HashSystem;
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

    $HashSystem = ExtractSystem -Dir $DirList;

    $FolderName = $Dir | Split-Path -Leaf;

    WriteStartXml -Name $FolderName;

    CreateXml -Parent $HashSystem;

    WriteEndXml;
}

#################################################################
#                         Start Script                          #
#################################################################

# Set in the global scope since XmlTextWriter behaves strangely.
$global:XmlWriter = New-Object System.Xml.XmlTextWriter($OutDirectory, $null);

main -Dir $TargetDirectory;