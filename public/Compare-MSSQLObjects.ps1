Function Compare-MSSQLObjects{
    <#
            .SYNOPSIS
            try to compare the latest two files given its exported name
            .DESCRIPTION
            -
            .PARAMETER Path
            The path which the files will reside in
            .PARAMETER Name
            The base name of the files to look for
            .NOTES
            taken from https://www.mssqltips.com/sqlservertip/4310/simple-tsql-code-comparison-with-powershell/
            full credit of the code goes to Tim Smith, just expanded his code a bit
            .EXAMPLE
            Compare-MSSQLObjects -Path 'C:\Files\' -Name 'stpCompare'
            will look into the folder c:\files and try to find the two latest written files which fit the regex pattern stpCompare_\d{8}_\d{4}
            if not two files is found an error will occur and execution will be terminted, otherwise the files will be loaded into memory and converter to HTML and line for line 
            compared, if they differ they will show up as BOLD in the right hand column output will be saved as an html file inteh same foler as specified in Path
    #>
    [cmdletbinding()]
    Param(
        [string]$Path= 'c:\sqlcompareobjects\',
        [Parameter(Mandatory=$true)][string]$Name
    )
    Begin{
        $lastfiles = Get-ChildItem -Path $Path | Where-Object {$_.Fullname -match ($Name+'_\d{8}_\d{4}')} | Sort-Object {$_.LastWriteTime} -Descending |  Select-Object -first 2 -ExpandProperty FullName
        if($lastfiles.count -ne 2){
            Write-Warning ('Sorry there is not two files in path {0} with the name {1} so comparison is impossible' -f ($Path,$Name))
            BREAK
        }
        else{
            $newestfile = $lastfiles[0]
            $almostnewestfile = $lastfiles[1]
        }

    }
    Process
    {
        $sqlobject2 = Get-Content $newestfile
        $sqlobject1 = Get-Content $almostnewestfile

        $dummy = $newestfile -match '\d{8}_\d{4}'
        $newestdate = $Matches[0]
        $dummy = $almostnewestfile -match '\d{8}_\d{4}'
        $almostnewestdate = $Matches[0]


        $htmlbody = '<html><head><title></title></head><body><p><table><tr><th>Existing T-SQL from '+$almostnewestdate+'</th><th>New T-SQL from '+$newestdate+'</th></tr>'

        $column1 = $sqlobject1 | ForEach-Object {$x = 1} { New-Object PSObject -Property @{ Line = $x;Html = '<tr><td>' + $x + '</td><td>' + $_ + '</td></tr>' }; $x++ }
        $column2 = $sqlobject2 | ForEach-Object {$x = 1} { New-Object PSObject -Property @{ Line = $x;Html = '<tr><td>' + $x + '</td><td>' + $_ + '</td></tr>' }; $x++ }

        $columnhighlight = ''
        $lengthloop = $column2.Length
        $begin = 1

        while ($begin -le $lengthloop)
        {
            $highlight1 = $column1 | Where-Object {$_.Line -eq $begin} | Select-Object Html
            $highlight2 = $column2 | Where-Object {$_.Line -eq $begin} | Select-Object Html

            ### If logic if lines are the same or not
            if ($highlight1.Html -ne $highlight2.Html)
            {
                $columnhighlight += ($highlight2.Html).Replace('<td>','<td><b><i>').Replace('</td>','</i></b></td>')
            }
            else
            {
                $columnhighlight += $highlight2.Html
            }
            $begin++
        }

        $tableone = $htmlbody + '<td><table><tr><th>Line Number</th><th>TSQL:</th></tr>' + $column1.Html + '</table></td>'
        $tabletwo = $tableone + '<td><table><tr><th>Line Number</th><th>TSQL:</th></tr>' + $columnhighlight + '</table></td></table></p></body></html>'

        $finalresult = $path + $Name +'_comparing_outputs_'+$almostnewestdate+'_and_'+$newestdate + '.html'
        $tabletwo | Out-File $finalresult -Force
    }
} #END Compare-MSSQLObjects