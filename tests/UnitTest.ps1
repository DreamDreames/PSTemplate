$here = Split-Path $MyInvocation.MyCommand.Path

Describe "Render template With Value"{
    It "Should get the code to be replaced"{
        $temp = '<%= $model.name %>'
        $model = @{name = 'foo'}
        $res = Render $temp $model
        $res | Should Be 'foo'
    } 
}