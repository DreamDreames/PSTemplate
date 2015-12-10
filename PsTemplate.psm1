
Function Render([string]$template, $model){
    $p = _Parse $template
    $str = _Fill $model $p
    return $str
}

Function _Parse([string]$templateStr){
    $stack = Create-Stack
    $result = _Split $templateStr 0 $stack
    return $result
}

Function _Fill($model, $stack){
    $str = ''
    $expression = ""
    $inBolck = $false
    While(-not (IsEmpty-Stack $stack) ){
        $value = Pop-Stack $stack
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

Function _Split([string]$templateStr, [int]$startIndex, $stack){
    if($startIndex -lt 0 -or $startIndex -ge $templateStr.Length){
        return $stack
    }

    @("<%=", "<%", "%>") | % {
        $temp = $templateStr.IndexOf($_, $startIndex)
        if($temp -ge $startIndex){
            $currentValue = ''
            if($temp -gt $startIndex){
                $currentValue = $templateStr.SubString($startIndex, $temp - $startIndex)
            }
            else {
                $currentValue = $_
            }
            $nextIndex = $startIndex + $currentValue.Length
            return _Split $templateStr $nextIndex $stack
        }
    }
    return $stack
}

Function Create-Stack(){
    return @()
}
Function Clear-Stack($stack){
    $stack = @()
}

Function Push-Stack($stack, $value){
    $stack += $value
}

Function Pop-Stack($stack){
    if( IsEmpty-Stack $stack ){
        return $null
    }
    return $stack[-1]
}

Function IsEmpty-Stack($stack){
    return ($stack.Count -le 0)
}

Export-ModuleMember @( 'Render' )