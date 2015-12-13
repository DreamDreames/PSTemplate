
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
    $indexes | % {
        $exp = $templateStr.SubString($pos, $_ - $pos)
        $cur = $templateStr.SubString($_)
        switch -regex ($cur){
            "^<%=" {
                Write-Host "Push1: $exp Pos before push: $pos"
                $stack = _Move-Forward $stack $exp "<%="
                $pos = "<%=".Length
                break
            }
            "^<%" {
                Write-Host "Push2: $exp Pos before push: $pos"
                $stack, $pos = _Move-Forward $stack $exp "<%"
                $pos = "<%".Length
                break
            }
            "^%>"{
                Write-Host "Push and pop: $exp Pos before push: $pos"
                $stack = _Move-Forward $stack $exp ""
                $stack= _Evaluate $stack
                $pos = "%>".Length
                break
            }
            Default {
                break
            }
        }
        $pos += $_
        Write-Host "New Pos: $pos"
    }
    if($pos -lt $templateStr.Length){
        $stack = Push-Stack $stack $templateStr.SubString($pos)
    }
    return Join-Stack $stack
}

Function _Move-Forward($stack, $exp, $pivot){
    if($exp){
        $stack = Push-Stack $stack $exp
    }
    if($pivot){
        $stack = Push-Stack $stack $pivot
    }

    return ,$stack
}

Function _Evaluate($stack)
{
    $expression = ""
    while(-not (IsEmpty-Stack $stack)){
        $temp = Top-Stack $stack
        $stack = Pop-Stack $stack
        if(-not $temp){
            continue
        }
        if($temp -eq "<%="){
            Write-Host "Evaluate: $expression"
            $value = Invoke-Expression $expression
            $t = Join-Stack $stack
            Write-Host "Value: $value Current Stack: $t"
            $stack = Push-Stack $stack $value
            return ,$stack
        }
        elseif($temp -eq "<%"){
            Write-Host "Evaluate: $expression"
            $value = Invoke-Expression $expression
            $stack = Push-Stack $stack $value
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
    return @()
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
        return @()
    }

    return ,$stack[0..($count - 2)]
}

Function IsEmpty-Stack($stack){
    return ($stack.Count -le 0)
}

Function Join-Stack($stack){
    $result = ""
    if($stack){
        $stack | ? {$result += $_}
    }
    return $result
}

Export-ModuleMember @( 'Render' )