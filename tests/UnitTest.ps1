$here = Split-Path $MyInvocation.MyCommand.Path

Describe "Render template With Value"{
    It "Should replace a single value"{
        $temp = '<%= $model.name %>'
        $model = @{name = 'foo'}
        $res = Render $temp $model
        $res | Should Be 'foo'
    } 

    It "Should replace a single value in a text"{
        $temp = 'hello <%= $model.name %> hello'
        $model = @{name = 'foo'}
        $res = Render $temp $model
        $res | Should Be 'hello foo hello'
    }

    It "Should replace multiple values in a text"{
        $temp = 'book name <%= $model.name %>, author <%= $model.author %>'
        $model = @{name = 'foo'; author = 'bar'}
        $res = Render $temp $model
        $res | Should Be 'book name foo, author bar'
    }

    It "Should support nested expression in template"{
        $temp = 'book count <%= $model.Count %> Book Name: <% $model | % { %> book: <%= $_ %> <% } %>'
        $model = @("foo", "bar")
        $res = Render $temp $model
        $res | Should Be "book count 2 Book Name: book foo book bar"
    }
}