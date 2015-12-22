$root = Split-Path $MyInvocation.MyCommand.Path
Import-Module "$root\PsTemplate.psm1"

$soundResult =  @(
@{"name" = "NOT_BUILT";  "ordinal" = "3"}, 
@{"name" = "ABORTED";    "ordinal" = "4"}, 
@{"name" = "SUCCESS";    "ordinal" = "0"}, 
@{"name" = "FAILURE";    "ordinal" = "2"}
);


$model = @{
    "taskName" = "ut";
    "stageName"= "commit";
    "gitUrl"   = "https://tfs.slb.com/tfs/slb1/Prism/_git/CDaaS";
    "soundResults" = $soundResult
}

RenderFile "$root\Config_Template.xml" $model | Out-File "$root\Config_Actual.xml" 