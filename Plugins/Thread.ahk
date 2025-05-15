#Requires AutoHotkey v2.0
/**
 * Credits to https://github.com/Descolada/AHK-v2-libraries for mutex and semaphore class. Got too lazy to remake it.
 */ 
class Mutex {
    __New(name?, initialOwner := 0, securityAttributes := 0) {
        if !(this.ptr := DllCall("CreateMutex", "ptr", securityAttributes, "int", !!initialOwner, "ptr", IsSet(name) ? StrPtr(name) : 0))
            throw Error("Unable to create or open the mutex", -1)
    }
    Lock(timeout:=0xFFFFFFFF) => DllCall("WaitForSingleObject", "ptr", this, "int", timeout, "int")
    Release() => DllCall("ReleaseMutex", "ptr", this)
    __Delete() => DllCall("CloseHandle", "ptr", this)
}
class Semaphore {
    __New(initialCount, maximumCount?, name?, securityAttributes := 0) {
        if IsSet(initialCount) && IsSet(maximumCount) && IsInteger(initialCount) && IsInteger(maximumCount) {
            if !(this.ptr := DllCall("CreateSemaphore", "ptr", securityAttributes, "int", initialCount, "int", maximumCount, "ptr", IsSet(name) ? StrPtr(name) : 0))
                throw Error("Unable to create the semaphore", -1)
        } else if IsSet(initialCount) && initialCount is String {
            if !(this.ptr := DllCall("OpenSemaphore", "int", maximumCount ?? 0x0002, "int", !!(name ?? 0), "ptr", IsSet(initialCount) ? StrPtr(initialCount) : 0))
                throw Error("Unable to open the semaphore", -1)
        } else
            throw ValueError("Invalid parameter list!", -1)
    }
    Wait(timeout:=0xFFFFFFFF) => DllCall("WaitForSingleObject", "ptr", this, "int", timeout, "int")
    Release(count := 1, &out?) => (out := DllCall("ReleaseSemaphore", "ptr", this, "int", count, "int*", &prevCount:=0), prevCount)
    __Delete() => DllCall("CloseHandle", "ptr", this)
}

class ThreadPool {
    __New(threads := 4) {
        this.stop := false
        this.tasks := []
        this.workers := []
        uniqueSuffix := A_TickCount
        this.queueMutex := Mutex("Global_Queue_" uniqueSuffix)
        this.Semaphore := Semaphore(0, threads, "Semaphore_" uniqueSuffix)
        this.amount := threads
        
        createWorker(*) {
            WorkerThread(tp, Semaphore, mutex, *) {
                while !tp.stop {
                    if Semaphore.Wait() != 0
                        continue
                    if mutex.Lock() != 0
                        continue
                    if tp.tasks.Length > 0 {
                        task := tp.tasks.RemoveAt(1)
                        mutex.Release()
                        try task()
                        catch as e
                            OutputDebug "Task failed: " e.Message
                    } else {
                        mutex.Release()
                    }
                }
            }
            
            worker := {}
            worker.state := "Waiting"
            worker.callback := CallbackCreate(WorkerThread.Bind(this, this.Semaphore, this.queueMutex))
            worker.threadHandle := DllCall(
                "CreateThread",
                "Ptr", 0,
                "UInt", 0,
                "Ptr", worker.callback,
                "Ptr", 0,
                "UInt", 0,
                "UInt*", 0,
                "Ptr")
            this.workers.Push(worker)
        }
        
        Loop threads {
            createWorker()
            ThreadPool.HyperSleep(50, "us", 300)
        }
    }
    ; In Progress
    /*addThreads(threads) {
        if !(IsNumber(threads) && threads > 0)
            return 0
        this.Semaphore.amount := threads + this.Semaphore.amount
        DllCall("ReleaseSemaphore", "Ptr", this.Semaphore.Ptr, "Int", this.Semaphore.amount, "Ptr", 0)
        DllCall("CloseHandle", "Ptr", this.Semaphore.Ptr)
        this.Semaphore.Ptr := DllCall(
            "kernel32.dll\CreateSemaphore",
            "Ptr", 0,
            "Int", 0,
            "Int", this.Semaphore.amount,
            "Str", "Semaphore",
            "Ptr")
        Loop threads {
            this.newWorker()
            ThreadPool.HyperSleep(50, "us", 300)
        }
    }*/

    enqueue(task) {
        if !Type(task) = "Func" { 
            throw "Invalid task"
        }
        this.queueMutex.Lock()
        this.tasks.Push(task)
        this.queueMutex.Release()
        this.Semaphore.Release(1)
        ThreadPool.HyperSleep(50, "us", 300)
    }

    stopThreads() {
        this.stop := true
        this.Semaphore.Release(this.amount)
        for worker in this.workers {
            DllCall("WaitForSingleObject", "Ptr", worker.threadHandle, "UInt", 0xFFFFFFFF)
            DllCall("CloseHandle", "Ptr", worker.threadHandle)
        }
    }

    __Delete() {
        this.stop := true
        this.Semaphore.Release(this.amount)
        for worker in this.workers {
            DllCall("WaitForSingleObject", "Ptr", worker.threadHandle, "UInt", 0xFFFFFFFF)
            DllCall("CloseHandle", "Ptr", worker.threadHandle)
            if worker.HasProp("callback")
                CallbackFree(worker.callback)
        }
        this.queueMutex.__Delete()
        this.Semaphore.__Delete()
    }

    static HyperSleep(time, unit := "ns", threshold := 30000) {
        static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
        static freqNs := freq / 1000000000
        static freqUs := freq / 1000000
        static freqMs := freq / 1000
        DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
        if (unit = "ms") {
            finish := begin + time * freqMs
        } else if (unit = "us") {
            finish := begin + time * freqUs
        } else {
            finish := begin + time * freqNs
        }
        current := 0  
        while (current < finish) {
            DllCall("QueryPerformanceCounter", "Int64*", &current := 0)
            if ((finish - current) > threshold) {
                DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
                DllCall("Sleep", "UInt", 1)
                DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
            }
        }
    }
}