; 回调函数，间隔，持续时间，参数
HoldKey(callback, endCallback, period, leftTime, key)
{
    callback(key)
    action := GetKeyAction(callback, endCallback, key)
    holdTimer := Timer(action, period)
    holdTimer.On()
    funcObj := ReleaseKey.Bind(holdTimer, endCallback, key)
    SetTimer funcObj, -leftTime, -1
}

GetKeyAction(callback, endCallback, key)
{
    ;//闭包
    action()
    {
        global ScriptInfo
        if (ScriptInfo.IsPause)
            return
            
        callback(key)
        funcObj := endCallback.Bind(key)
        looseTime := GetRandonAutoLooseTime()
        SetTimer funcObj, -looseTime
    }
    return action
}



ReleaseKey(holdTimer, callback, key)
{
    holdTimer := ""
    callback(key)
}

class Timer
{
    __New(callback, period)
    {
        this.binding := callback
        this.period := period
        this.priority := 0
    }

    __Delete()
    {
        this.Off()
    }

    On()
    {
        funcObj := this.binding
        SetTimer funcObj, this.period, this.priority
    }

    Off()
    {
        funcObj := this.binding
        SetTimer funcObj, 0
    }
}