
Function Render([string]$template, $model){
    $str = _Pre $template
    $indexes = _Find-Index $str
    if(-not $indexes){
        return $template
    }

    $str = _Parse $str $indexes 
    $str = _Post (_Evaluate $str $model)

    return $str
}

Function RenderFile([string]$filePath, $model){
    $content = gc $filePath | Out-String

    return Render $content $model
}

Function _Pre([string]$template){
    return $template.Replace('"', '_{^}_')
}

Function _Post([string]$template){
    return $template.Replace('_{^}_', '"')
}

Function _Find-Index([string]$templateStr, $startIndex){
    $regex = [regex]"<%=|%>|<%";
    return $regex.Matches($templateStr) | foreach {$_.Index} | Sort | Get-Unique
}

Function _Parse($templateStr, $indexes){
    $pos = 0
    $stack = Create-Stack
    $depth = 0
    $indexes | % {
        $exp = $templateStr.SubString($pos, $_ - $pos)
        $cur = $templateStr.SubString($_)
        switch -regex ($cur){
            "^<%=" {
                $stack = _Push $stack $exp "<%=" $depth
                $pos = "<%=".Length
                $depth ++
                break
            }
            "^<%" {
                $stack = _Push $stack $exp "<%" $depth
                $pos = "<%".Length
                $depth ++
                break
            }
            "^%>"{
                $stack = _Push $stack $exp "" $depth
                $stack= _Pop $stack $depth
                $pos = "%>".Length
                if($depth -gt 0){$depth -- }
                break
            }
            Default {
                break
            }
        }
        $pos += $_
    }
    if($pos -lt $templateStr.Length){
        $stack = _Push $stack $templateStr.SubString($pos) "" $depth
    }
    $exp = Join-Stack $stack
    return $exp
}

Function _Evaluate($exp, $model){
    $expression = ''
    #Write-Host $exp 
    Invoke-Expression $exp
    return $expression
}

Function _Push($stack, $exp, $pivot, $depth){
    if($exp){
        if($depth -eq 0){
            $exp = '$expression +="' + "$exp" + '";'
        }
        $stack = Push-Stack $stack $exp
    }
    if($pivot){
        $stack = Push-Stack $stack $pivot
    }

    return ,$stack
}

Function _Pop($stack, $depth){
    $expression = ''
    while( -not (IsEmpty-Stack $stack)){
        $temp = Top-Stack $stack
        $stack = Pop-Stack $stack
        if(-not $temp){
            continue
        }
        if($temp -eq "<%="){
            $stack = Push-Stack $stack ('$expression += "$(' + "$expression" + ')";')
            return ,$stack
        }
        elseif($temp -eq "<%"){
            if($depth -eq 1){
                $expression += ';'
            }
            $stack = Push-Stack $stack $expression
            return ,$stack
        }
        else{
            $expression += $temp
        }
    }
    return ,$stack
}


Function Create-Stack(){
    return ,@()
}

Function Clear-Stack($stack){
    $stack.Clear()
    return ,@()
}

Function Push-Stack($stack, $value){
    if($value){
        $stack += $value
    }

    return ,$stack
}

Function Top-Stack($stack){
    if( IsEmpty-Stack $stack){
        return $null
    }

    return $stack[-1]
}

Function Pop-Stack($stack){
    $count = $stack.Count
    if($count -lt 2){
        $stack.Clear()
        $stack = $null
        return ,@()
    }

    return ,$stack[0..($count - 2)]
}

Function IsEmpty-Stack($stack){
    return ($stack.Count -le 0)
}

Function Join-Stack($stack){
    $result = ""
    if($stack){
        $stack | ? {$result += "$_"}
    }
    return $result
}

Export-ModuleMember @( 'Render', 'RenderFile' )