# PSTemplate
PSTemplate is a powershell template engine inspired by underscore.js

JSTemplate supports two types of syntax:

    <%= .. %> Evaluate the powershell expression 

    <% ... %> Execute the powershell code in between.

### Example 1 - Evaluate a powershell expression in a string template:

    Import-Module "PsTemplate.psm1"

    $templateString = 'Say <%= $model.name %> to foo'

    $model = @{name = 'bar'}
    
    # Output: Say bar to foo
    ConvertFrom-String $templateString $model
    
### Example 2 - Execute powershell code in a string template:

    $templateString = 'book count <%= $model.Count %> Book Name: <% $model | % { %>book <%= $_ %> <% } %>'
    
    $model = @("foo", "bar")
    
    # Output: book count 2 Book Name: foo bar
    ConvertFrom-String $templateString $model
    
### Example 3 - Evaluate a powershell expression in a file template

Template file: books.xml

    <books>
	    <book>
	      <% $model | % { %>
		      <name> <%= $_ %> </name>
	      <% } %>
	    </book>
    </books>

Usage:

    Import-Module "PsTemplate.psm1"
    
    $fileName = "books.xml"
    
    $model = @("foo", "bar")
    
    ConvertFrom-File $fileName $model

Output:

    <books>
	    <book>
		      <name> foo </name>
	        <name> bar </name>
	    </book>
    </books>
  

### Unit Tests
  
The unit test is based on pester. To run the test

    go.ps1 test
    
### More examples can be found in "tests/UnitTest.ps1"
