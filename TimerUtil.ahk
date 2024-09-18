; 回调函数，间隔，持续时间，参数
HoldKey(callback, endCallback, period, leftTime, key)
{
    holdTimer := Timer(callback, period, key)
    funcObj := ReleaseKey.Bind(holdTimer, endCallback, key)
    SetTimer funcObj, -leftTime, -1
}

ReleaseKey(holdTimer, callback, key)
{
    holdTimer := ""
    callback(key)
}

class Timer
{
    __New(callback, period, key)
    {
        this.binding := callback.Bind(key)
        this.period := period
        this.priority := 0
        this.On()
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