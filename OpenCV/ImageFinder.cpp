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

// 计算两个矩形的交并比（IOU）
double computeIOU(const cv::Rect &rect1, const cv::Rect &rect2)
{
    // 计算交集区域
    cv::Rect intersection = rect1 & rect2;
    if (intersection.empty())
        return 0.0;

    double interArea = intersection.area();
    double unionArea = rect1.area() + rect2.area() - interArea;
    return interArea / unionArea;
}

// 非极大值抑制（NMS）算法
std::vector<cv::Rect> nonMaximumSuppression(const std::vector<cv::Rect> &rects,
                                            const std::vector<float> &scores,
                                            double scoreThreshold,
                                            double iouThreshold)
{
    std::vector<int> indices;
    for (int i = 0; i < scores.size(); ++i)
    {
        if (scores[i] >= scoreThreshold)
        {
            indices.push_back(i);
        }
    }

    // 按匹配分数降序排序
    std::sort(indices.begin(), indices.end(), [&](int a, int b) {
        return scores[a] > scores[b];
    });

    std::vector<bool> suppressed(indices.size(), false);
    std::vector<cv::Rect> selected;

    for (int i = 0; i < indices.size(); ++i)
    {
        if (suppressed[i])
            continue;

        int current = indices[i];
        selected.push_back(rects[current]);

        for (int j = i + 1; j < indices.size(); ++j)
        {
            if (suppressed[j])
                continue;

            int next = indices[j];
            if (computeIOU(rects[current], rects[next]) > iouThreshold)
            {
                suppressed[j] = true;
            }
        }
    }

    return selected;
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
    // 匹配分数阈值
    double scoreThreshold = matchThreshold / 100.0;

    // 1. 加载模板图像
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

    // 2. 转换为灰度图（提高处理速度）
    cv::Mat grayLarge, graySmall;
    cv::cvtColor(capturedImage, grayLarge, cv::COLOR_BGR2GRAY);
    cv::cvtColor(templateImage, graySmall, cv::COLOR_BGR2GRAY);

    // 3. 模板匹配
    cv::Mat result;
    cv::matchTemplate(grayLarge, graySmall, result, cv::TM_CCOEFF_NORMED);

    // 4. 设置阈值并查找匹配位置
    // NMS重叠阈值
    const double nmsThreshold = 0.3;

    std::vector<cv::Rect> rects;
    std::vector<float> scores;

    // 遍历所有匹配结果
    for (int y = 0; y < result.rows; y++)
    {
        for (int x = 0; x < result.cols; x++)
        {
            float score = result.at<float>(y, x);
            if (score >= scoreThreshold)
            {
                rects.push_back(cv::Rect(x, y, templateImage.cols, templateImage.rows));
                scores.push_back(score);
            }
        }
    }

    // 5. 检查是否有匹配结果
    if (rects.empty())
    {
        std::cout << "no find" << std::endl;
        return 0;
    }

    // 6. 应用非极大值抑制
    std::vector<cv::Rect> selected = nonMaximumSuppression(rects, scores, scoreThreshold, nmsThreshold);

    // 7. 检查NMS后是否有结果
    if (selected.empty())
    {
        std::cout << "not find" << std::endl;
        return 0;
    }

    cv::Rect &rect = selected.front();
    // 计算模板在屏幕上的实际中心坐标
    cv::Point topLeft(rect.x + searchX, rect.y + searchY);
    cv::Point center(topLeft.x + templateImage.cols / 2, topLeft.y + templateImage.rows / 2);

    // 打印模板在屏幕上的中心坐标
    std::cout << "Template found at center coordinates: (" << center.x << ", " << center.y << ")" << std::endl;

    // 移动鼠标到模板中心位置
    // SetCursorPos(center.x, center.y);

    *x = static_cast<int>(topLeft.x);
    *y = static_cast<int>(topLeft.y);

    return 1;
}