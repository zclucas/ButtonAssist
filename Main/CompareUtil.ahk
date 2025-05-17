#Requires AutoHotkey v2.0

ExtractNumbers(Text, Pattern) {
    ; 转义Pattern中的特殊字符（如括号）
    Pattern := RegExReplace(Pattern, "[.*+?()\[\]{}|^$\\]", "\$0")

    ; 将Pattern中的x, y, z, w替换为正则表达式的捕获组
    Pattern := RegExReplace(Pattern, "&x", "(\d{1,3}(?:[，,]\d{3})*(?:\.\d+)?)")
    Pattern := RegExReplace(Pattern, "&c", "(.*)")

    ; 使用正则表达式匹配Text
    if (RegExMatch(Text, Pattern, &Match)) {
        ; 提取匹配的数字
        Result := []
        for i, Value in Match {
            if (i == 0)
                continue ; 跳过第一个匹配项（整个匹配文本）

            oriStr := Value
            IsNumber1 := IsNumber(Value)
            Value := StrReplace(Value, ",", "")
            Value := StrReplace(Value, "，", "")
            IsNumber2 := IsNumber(Value)
            if (IsNumber1 || IsNumber2) {
                tempValue := IsFloat(Value) ? Format("{:.4g}", Value) : Integer(Value)
            }
            else {
                tempValue := oriStr
            }
            Result.Push(tempValue)
        }
        return Result
    }
    return "" ; 如果没有匹配到，返回空字符串
}

CompareExtractOperAndNum(expression) {
    ; 初始化两个数组
    operators := []
    numbers := []

    ; 定义支持的运算符
    symbolMap := Map("+", 1, "-", 1, "*", 1, "/", 1, "^", 1)

    ; 遍历表达式，逐个字符检查是否为运算符
    for i, char in StrSplit(expression) {
        if (symbolMap.Has(char)) {
            operators.Push(char)
        }
    }

    while (RegExMatch(expression, "\d+\.?\d*", &match)) {
        numbers.Push(match[0])
        ; 从表达式中移除已匹配的部分
        expression := RegExReplace(expression, match[0], "", , 1)
    }

    return { operators: operators, numbers: numbers }
}

CompareCheckIfValid(compareData) {
    disCount := 0
    for index, value in compareData.ComparToggleArr {
        if (value == 0)
            disCount++
    }

    if (disCount == 4)
        return false
    return true
}

CompareUpdateVariable(compareData) {
    compareData.VariableArr := []
    for index, value in compareData.BaseVariableArr {
        variable := UpdateBaseValue(value, compareData.VariableOperatorArr[index])
        compareData.VariableArr.Push(variable)
    }
}

UpdateBaseValue(baseValue, expression) {
    res := CompareExtractOperAndNum(expression)
    sum := baseValue
    for index, value in res.operators {
        if (value == "+")
            sum += Number(res.numbers[index])
        if (value == "-")
            sum -= Number(res.numbers[index])
        if (value == "*")
            sum *= Number(res.numbers[index])
        if (value == "/")
            sum /= Number(res.numbers[index])
        if (value == "^")
            sum ^= Number(res.numbers[index])
    }
    return sum
}

CompareGetResult(compareData, baseVariableArr) {
    compareData.BaseVariableArr := baseVariableArr
    CompareUpdateVariable(compareData)
    for index, value in compareData.ComparToggleArr {
        if (value == 0)
            continue

        res := GetCompareResultIndex(compareData, index)
        if (!res)
            return false
    }
    return true
}

GetCompareResultIndex(compareData, index) {
    leftValue := compareData.VariableArr[index]
    rightValue := compareData.ComparValueArr[index]
    rightValue := rightValue == "x" ? compareData.VariableArr[1] : rightValue
    rightValue := rightValue == "y" ? compareData.VariableArr[2] : rightValue
    rightValue := rightValue == "w" ? compareData.VariableArr[3] : rightValue
    rightValue := rightValue == "h" ? compareData.VariableArr[4] : rightValue
    if (compareData.ComparTypeArr[index] == 1) {
        return leftValue > rightValue
    }
    else if (compareData.ComparTypeArr[index] == 2) {
        return leftValue >= rightValue
    }
    else if (compareData.ComparTypeArr[index] == 3) {
        return leftValue == rightValue
    }
    else if (compareData.ComparTypeArr[index] == 4) {
        return leftValue <= rightValue
    }
    else if (compareData.ComparTypeArr[index] == 5) {
        return leftValue < rightValue
    }

    return false
}

CoordUpdateVariable(coordData, baseVariableArr) {
    coordData.BaseVariableArr := baseVariableArr
    coordData.VariableArr := []
    for index, value in coordData.BaseVariableArr {
        variable := UpdateBaseValue(value, coordData.VariableOperatorArr[index])
        coordData.VariableArr.Push(variable)
    }
}
