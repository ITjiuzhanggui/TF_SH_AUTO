
# -*- coding:utf-8 -*-

import sys
import re


def read_file():
    if len(sys.argv) < 2:
        print("Usage %s logcat"%sys.argv[0])
        sys.exit(-1)

    filename = sys.argv[1]
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        print("Error: ", e)
        lines = None
        sys.exit(-1)
    return lines


def calc_avg_fps(lines):
    if lines is None:
        print("Error: lines is None")
        sys.exit(-1)

    fps_sum = 0.0
    num = 1
    tmp_lines = []
    for line in lines:
        fps = re.search(r"seconds: (\d+\.\d+)", line)
        if fps:
            tmp_lines.append(line)

    for line in tmp_lines[:29]:
        fps = re.search(r"seconds: (\d+\.\d+)", line)
        if fps:
            fps_sum += float(fps.group(1))
            num += 1

    print("num:", num)

    avg_fps = fps_sum / num
    print("the avg fps of %d: %0.3f" % (num, avg_fps))
    return avg_fps


def main():
    lines = read_file()
    avg_fps = calc_avg_fps(lines)
    # print("fps的平均值是:", avg_fps)


if __name__ == '__main__':
    main()

