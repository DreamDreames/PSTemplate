$here = Split-Path $MyInvocation.MyCommand.Path
$data = "$here\testfiles"

Describe "Render Template With Model"{
    It "Should replace a single value"{
        $temp = '<%= $model.name %>'
        $model = @{name = 'foo'}
        Render $temp $model | Should Be 'foo'
    } 

    It "Should replace a single value in a text"{
        $temp = 'hello <%= $model.name %> hello'
        $model = @{name = 'foo'}
        Render $temp $model | Should Be 'hello foo hello'
    }

    It "Should replace multiple values in a text"{
        $temp = 'book name <%= $model.name %>, author <%= $model.author %>'
        $model = @{name = 'foo'; author = 'bar'}
        Render $temp $model | Should Be 'book name foo, author bar'
    }

    It "Should support nested expression in template"{
        $temp = 'book count <%= $model.Count %> Book Name: <% $model | % { %>book <%= $_ %> <% } %>'
        $model = @("foo", "bar")
        Render $temp $model | Should Be "book count 2 Book Name: book foo book bar "
    }

    It "Should be able to render tempalte without model"{
        $temp = 'this is an empty template'
        Render $temp '' | Should Be $temp
    }

    It "Should be able to output newline with evaluate value expression"{
        $fileName = "TemplateEvaluateValue.txt"
        $file = "$data\$fileName"
        $model = @{name = 'foo'}
        $expected = gc "$data\Expected_$fileName" | Out-String
        RenderFile $file $model | Should Be $expected
    }

    It "Should be able to support nested expression with newline"{
        $fileName = "TemplateExecuteCode.xml"
        $file = "$data\$fileName"
        $model = @("foo", "bar")
        $expected = gc "$data\Expected_$fileName" | Out-String
        RenderFile $file $model | Should Be $expected
    }

    It "Should support double quote in template"{
        $temp = '"book count" <%= $model.Count %> "Book Name:" <% $model | % { %>book <%= $_ %> <% } %>'
        $model = @("foo", "bar")
        Render $temp $model | Should Be '"book count" 2 "Book Name:" book foo book bar '
    }

    It "Should support double quote in template"{
        $fileName = "TemplateWithDoubleQuote.xml"
        $file = "$data\$fileName"
        $model = @("foo", "bar")
        $expected = gc "$data\Expected_$fileName" | Out-String
        RenderFile $file $model | Should Be $expected
    }

    It "Should support single quote in template"{
        $fileName = "TemplateWithSingleQuote.xml"
        $file = "$data\$fileName"
        $model = @("foo", "bar")
        $expected = gc "$data\Expected_$fileName" | Out-String
        RenderFile $file $model | Should Be $expected
    }
}