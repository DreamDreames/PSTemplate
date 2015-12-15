
Function Render([string]$template, $model){
    $str = _Parse $template $model
    return $str
}

Function _Find-Index([string]$templateStr, $startIndex){
    $regex = [regex]"<%=|%>|<%";
    return $regex.Matches($templateStr) | foreach {$_.Index} | Sort | Get-Unique
}

Function _Parse($templateStr, $model){
    $indexes = _Find-Index $templateStr
    Write-Host "template: $templateStr, index: $indexes"
    if(-not $indexes){
        return $templateStr
    }
    $pos = 0
    $stack = Create-Stack
    $containsExp = $False
    $expression = ''
    $depth = 0
    $indexes | % {
        $exp = $templateStr.SubString($pos, $_ - $pos)
        $cur = $templateStr.SubString($_)
        switch -regex ($cur){
            "^<%=" {
                $stack = _Move-Forward $stack $exp "<%=" $depth
                $pos = "<%=".Length
                $containsExp = $True
                $depth ++
                break
            }
            "^<%" {
                $stack = _Move-Forward $stack $exp "<%" $depth
                $pos = "<%".Length
                $containsExp = $True
                $depth ++
                break
            }
            "^%>"{
                $stack = _Move-Forward $stack $exp "" $depth
                $stack= _Evaluate $stack
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
        $stack = _Move-Forward $stack $templateStr.SubString($pos) "" $depth
    }
    $exp = Join-Stack $stack
    Write-Host "To be invoke: $exp"
    if($containsExp){
        Write-Host "Invoke... $model"
        Invoke-Expression "$exp"
        Write-Host $expression
        return $expression
    }
    return $exp
}

Function _Move-Forward($stack, $exp, $pivot, $depth){
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

Function _Evaluate($stack){
    $expression = ''
    while( -not (IsEmpty-Stack $stack)){
        $temp = Top-Stack $stack
        $stack = Pop-Stack $stack
        if(-not $temp){
            continue
        }
        if($temp -eq "<%="){
            $stack = Push-Stack $stack ('$expression += $(' + "$expression" + ');')
            return ,$stack
        }
        elseif($temp -eq "<%"){
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

Export-ModuleMember @( 'Render' )