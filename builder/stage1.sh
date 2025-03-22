#!/bin/bash
# 指定脚本使用 bash 解释器运行

set -eux
# set -eux: 
# -e: 如果命令返回非零状态，立即退出脚本
# -u: 使用未定义变量时退出脚本
# -x: 打印每个命令及其参数（用于调试）

# Chores
workdir=$(pwd)
# 获取当前工作目录并赋值给变量 workdir
pip_exe="${workdir}/python_standalone/python.exe -s -m pip"
# 定义 pip_exe 变量，指向 Python 独立版本的 pip 命令路径

export PYTHONPYCACHEPREFIX="${workdir}/pycache1"
# 设置 PYTHONPYCACHEPREFIX 环境变量，指定 Python 缓存目录位置
export PIP_NO_WARN_SCRIPT_LOCATION=0
# 设置 PIP_NO_WARN_SCRIPT_LOCATION 环境变量，禁止 pip 警告脚本安装位置不在 PATH 中

ls -lahF
# 列出当前目录下的所有文件和目录，显示详细信息（包括权限、大小等）

# Download Python Standalone
curl -sSL \
https://github.com/astral-sh/python-build-standalone/releases/download/20250317/cpython-3.12.9+20250317-x86_64-pc-windows-msvc-install_only.tar.gz \
    -o python.tar.gz
# 使用 curl 下载 Python 独立版本的压缩包，保存为 python.tar.gz
tar -zxf python.tar.gz
echo "Python Standalone 解压完成"
mv python python_standalone
echo "Python Standalone 重命名完成"

# 运行 generate-pak5.sh 脚本
"$workdir"/generate-pak5.sh
echo "generate-pak5.sh 脚本执行完成"

# 运行 generate-pak7.sh 脚本
"$workdir"/generate-pak7.sh
echo "generate-pak7.sh 脚本执行完成"



# PIP installs
$pip_exe install --upgrade pip wheel setuptools
echo "pip、wheel 和 setuptools 升级完成"

$pip_exe install -r "$workdir"/pak2.txt
$pip_exe install -r "$workdir"/pak3.txt
$pip_exe install -r "$workdir"/pak4.txt
$pip_exe install -r "$workdir"/pak5.txt
$pip_exe install -r "$workdir"/pak6.txt
$pip_exe install -r "$workdir"/pak7.txt
$pip_exe install -r "$workdir"/pak8.txt



# Tweak for transparent-background. TODO: remove if upstream updated.
# https://github.com/plemeri/transparent-background/blob/f54975ce489af549dcfc4dc0a2d39e8f69a204fd/setup.py#L45
$pip_exe install --upgrade albucore albumentations
echo "albucore 和 albumentations 升级完成"

# Install comfyui-frontend-package, version determined by ComfyUI.
$pip_exe install -r https://github.com/comfyanonymous/ComfyUI/raw/refs/heads/master/requirements.txt
echo "ComfyUI 前端依赖安装完成"

$pip_exe list
# 列出所有已安装的 pip 包

# 验证 PyTorch 安装
$pip_exe list | grep torch  # 应显示 torch 2.3.0+cu121
echo "PyTorch 安装验证完成"

cd "$workdir"
# 切换到工作目录

# Add Ninja binary (replacing PIP Ninja if exists)
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip \
    -o ninja-win.zip
# 下载 Ninja 构建工具的最新版本，保存为 ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir"/python_standalone/Scripts
# 解压 ninja-win.zip 到 python_standalone/Scripts 目录，-q 静默模式，-o 覆盖已存在的文件
rm ninja-win.zip
echo "Ninja 构建工具安装完成"

# Add aria2 binary
curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip \
    -o aria2.zip
# 下载 aria2 下载工具的最新版本，保存为 aria2.zip
unzip -q aria2.zip -d "$workdir"/aria2
# 解压 aria2.zip 到 aria2 目录
mv "$workdir"/aria2/*/aria2c.exe  "$workdir"/python_standalone/Scripts/
echo "aria2 下载工具安装完成"
rm aria2.zip
# 删除 aria2.zip 文件

# Add FFmpeg binary
curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/7.1.1/ffmpeg-7.1.1-full_build.zip \
    -o ffmpeg.zip
# 下载 FFmpeg 的最新版本，保存为 ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir"/ffmpeg
# 解压 ffmpeg.zip 到 ffmpeg 目录
mv "$workdir"/ffmpeg/*/bin/ffmpeg.exe  "$workdir"/python_standalone/Scripts/
echo "FFmpeg 安装完成"
rm ffmpeg.zip
# 删除 ffmpeg.zip 文件

cd "$workdir"
# 切换到工作目录
du -hd1
echo "磁盘使用情况显示完成"
