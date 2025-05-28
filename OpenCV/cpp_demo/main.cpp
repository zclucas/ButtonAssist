
#include <iostream>
#include <Windows.h>
#include <chrono>
#include <vector>
#include "../ImageFinder.h"

int main()
{
    int x, y;
    // 获取开始时间点
    auto start = std::chrono::high_resolution_clock::now();

    auto result = FindImage("11.png", 0, 0, 1920, 1080, 90, &x, &y);
    // 获取结束时间点
    auto end = std::chrono::high_resolution_clock::now();

    // 计算耗时（毫秒）
    auto duration_ms = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

    // 输出结果
    std::cout << "time: " << duration_ms.count() << " ms" << std::endl;

    // 打印结果
    if (result == 1)
    {
        std::cout << "Image found at (" << x << ", " << y << ")" << std::endl;
    }
    else
    {
        std::cout << "Image not found" << std::endl;
    }

    return 0;
}