
Function Render([string]$template, $model){
    $p = _Parse $template
    $p | % {Write-Host $_}
    $str = _Fill $model $p
    return $str
}

Function _Parse([string]$templateStr){
    $stack = Create-Stack
    $result = _Split $templateStr $stack
    return $result
}

Function _Fill($model, $stack){
    $str = ''
    $expression = ""
    $inBolck = $false
    While(-not (IsEmpty-Stack $stack) ){
        $value = Top-Stack $stack
        $stack = Pop-Stack $stack
        switch ($value){
            "<%="   {
                $str += Invoke-Expression $expression
                $inBolck = $false
                break
            }
            "<%"    {
                $str += Invoke-Expression $expression
                $inBolck = $false
                break
            }
            "%>"    {
                $inBolck = $true
                $expression = ""
                break
            }
            Default {
                if($inBolck){
                    $expression += $value
                }
                else{
                    $str += $value
                }
                break
            }
        }
    }
    return $str
}

Function _Split([string]$templateStr, $stack){
    $startIndex = 0
    $templateLen = $templateStr.Length
    while($startIndex -lt $templateLen){
        foreach( $p in @("<%=", "<%", "%>")){
            $temp = $templateStr.IndexOf($p, $startIndex)
            $currentValue = ''
            if($temp -lt 0){
                continue
            }

            if($temp -gt $startIndex){
                 $currentValue = $templateStr.SubString($startIndex, $temp - $startIndex)
            }
            elseif($temp -eq $startIndex){
                $currentValue = $p
            }
            $stack = Push-Stack $stack $currentValue
            $startIndex += $currentValue.Length
            break
        }
    }
    return $stack
}

Function Create-Stack(){
    return ,@()
}
Function Clear-Stack($stack){
    $stack.Clear()
    return @()
}

Function Push-Stack($stack, $value){
    $stack += $value
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

Export-ModuleMember @( 'Render' )