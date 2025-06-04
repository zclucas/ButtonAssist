#Requires AutoHotkey v2.0

GetAmpersandSequence(str) {
    sequence := Map()
    counter := 1
    needle := "&[xc]"  ; 正则表达式匹配 &x 或 &c

    foundPos := 1
    while (foundPos := RegExMatch(str, needle, &match, foundPos)) {
        sequence[counter] := match[0]  ; 按顺序编号存储
        counter += 1
        foundPos += match.Len  ; 移动到匹配后的位置继续搜索
    }

    return sequence
}

ExtractNumbers(Text, Pattern) {
    ; 转义Pattern中的特殊字符
    Pattern := RegExReplace(Pattern, "[.*+?()\[\]{}|^$\\]", "\$0")
    ; 将 pattern 中的中英文冒号统一替换为正则通配 [:：]
    Pattern := RegExReplace(Pattern, "[:：]", "[:：]")
    SymbolMap := GetAmpersandSequence(Pattern)

    ; 优化数字匹配模式，区分千分位和普通数字
    Pattern := RegExReplace(Pattern, "&x", BuildNumberPattern())
    Pattern := RegExReplace(Pattern, "&c", "(.*)")

    if (RegExMatch(Text, Pattern, &Match)) {
        Result := []
        for i, Value in Match {
            if (i == 0)
                continue

            if (SymbolMap[i] == "&x") {
                ; 智能处理千分位和普通数字
                tempValue := ProcessNumberValue(Value)
            } else {
                tempValue := Value
            }
            Result.Push(tempValue)
        }
        return Result
    }
    return ""
}

BuildNumberPattern() {
    ; 千分位模式：必须包含逗号且格式正确
    ThousandFormat := "\d{1,3}(?:,\d{3})+(?:\.\d+)?"
    ; 普通数字模式：不包含逗号或仅含小数点
    NormalFormat := "[+-]?\d+(?:\.\d+)?"
    ; 小数模式：以小数点开头
    DecimalFormat := "[+-]?\.\d+"

    return "(" ThousandFormat "|" NormalFormat "|" DecimalFormat ")"
}

ProcessNumberValue(Value) {
    Cleaned := StrReplace(Value, ",")
    Cleaned := StrReplace(Cleaned, "，", "")
    Cleaned := StrReplace(Cleaned, "＋", "+")
    Cleaned := StrReplace(Cleaned, "－", "-")

    if (IsFloat(Cleaned)) {
        ; 处理整数部分前导零
        Cleaned := RegExReplace(Cleaned, "^([+-])?0+(\d)", "$1$2")

        ; 处理小数部分末尾零
        return RegExReplace(Cleaned, "(\.\d*?[1-9])0+$|(\.)0+$", "$1$2")
    }

    ; 处理整数前导零
    return Integer(RegExReplace(Cleaned, "^0+(\d)", "$1"))
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
