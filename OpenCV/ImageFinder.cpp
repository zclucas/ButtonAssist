#include "ImageFinder.h"
#include <opencv2/opencv.hpp>
#include <windows.h>

// 捕获屏幕指定区域的函数
cv::Mat captureScreen(int x, int y, int width, int height)
{
    HDC hDesktopDC  = GetDC(NULL);
    HDC hCaptureDC  = CreateCompatibleDC(hDesktopDC);
    HBITMAP hBitmap = CreateCompatibleBitmap(hDesktopDC, width, height);
    SelectObject(hCaptureDC, hBitmap);

    BitBlt(hCaptureDC, 0, 0, width, height, hDesktopDC, x, y, SRCCOPY | CAPTUREBLT);

    BITMAPINFOHEADER bi;
    bi.biSize          = sizeof(BITMAPINFOHEADER);
    bi.biWidth         = width;
    bi.biHeight        = -height;  // 负值表示从上到下扫描
    bi.biPlanes        = 1;
    bi.biBitCount      = 32;
    bi.biCompression   = BI_RGB;
    bi.biSizeImage     = 0;
    bi.biXPelsPerMeter = 0;
    bi.biYPelsPerMeter = 0;
    bi.biClrUsed       = 0;
    bi.biClrImportant  = 0;

    cv::Mat mat(height, width, CV_8UC4);
    GetDIBits(hCaptureDC, hBitmap, 0, height, mat.data, (BITMAPINFO *)&bi, DIB_RGB_COLORS);

    DeleteObject(hBitmap);
    DeleteDC(hCaptureDC);
    ReleaseDC(NULL, hDesktopDC);

    return mat;
}

extern "C" IMAGEFINDER_API int __cdecl FindImage(const char *targetPath,
                                                 int searchX,
                                                 int searchY,
                                                 int searchW,
                                                 int searchH,
                                                 int matchThreshold,
                                                 int *x,
                                                 int *y)
{
    if (matchThreshold > 100)
        matchThreshold = 100;
    else if (matchThreshold < 0)
        matchThreshold = 0;
    double threshold = matchThreshold / 100.0;

    // std::cerr << "image path:" << targetPath << std::endl;

    // 加载模板图像
    cv::Mat templateImage = cv::imread(targetPath, cv::IMREAD_UNCHANGED);
    if (templateImage.empty())
    {
        std::cerr << "Could not open or find the template image." << std::endl;
        return 0;
    }

    // 截取屏幕区域
    cv::Mat capturedImage = captureScreen(searchX, searchY, searchW, searchH);
    if (capturedImage.empty())
    {
        std::cerr << "Failed to capture screen region." << std::endl;
        return 0;
    }

    // 创建结果矩阵
    int result_cols = capturedImage.cols - templateImage.cols + 1;
    int result_rows = capturedImage.rows - templateImage.rows + 1;
    cv::Mat result(result_rows, result_cols, CV_32FC1);

    // 进行模板匹配
    matchTemplate(capturedImage, templateImage, result, cv::TM_CCOEFF_NORMED);

    // 归一化结果
    normalize(result, result, 0, 1, cv::NORM_MINMAX, -1, cv::Mat());

    // 获取最大匹配位置
    double minVal, maxVal;
    cv::Point minLoc, maxLoc;
    minMaxLoc(result, &minVal, &maxVal, &minLoc, &maxLoc);

    // 检查匹配值是否超过阈值
    if (maxVal >= threshold)
    {
        // 计算模板在屏幕上的实际中心坐标
        cv::Point topLeft(maxLoc.x + searchX, maxLoc.y + searchY);
        cv::Point center(topLeft.x + templateImage.cols / 2, topLeft.y + templateImage.rows / 2);

        // 打印模板在屏幕上的中心坐标
        // std::cout << "Template found at center coordinates: (" << center.x << ", " << center.y << ")" << std::endl;

        // 移动鼠标到模板中心位置
        // SetCursorPos(center.x, center.y);

        *x = static_cast<int>(topLeft.x);
        *y = static_cast<int>(topLeft.y);
        // 打印模板在屏幕上的中心坐标
        std::cout << "Template found at center coordinates: (" << *x << ", " << *y << ")" << std::endl;

        // std::cout << "find success" << std::endl;
        return 1;
    }
    else
    {
        return 0;
    }
}