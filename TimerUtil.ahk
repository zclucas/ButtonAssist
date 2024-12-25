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