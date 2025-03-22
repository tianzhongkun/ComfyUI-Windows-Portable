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
# 解压 python.tar.gz 文件
mv python python_standalone
# 将解压后的 python 目录重命名为 python_standalone

# PIP installs
$pip_exe install --upgrade pip wheel setuptools
# 使用 pip 升级 pip、wheel 和 setuptools

$pip_exe install -r "$workdir"/pak2.txt
# 使用 pip 安装 pak2.txt 文件中列出的依赖
$pip_exe install -r "$workdir"/pak3.txt
# 使用 pip 安装 pak3.txt 文件中列出的依赖
$pip_exe install -r "$workdir"/pak4.txt
# 使用 pip 安装 pak4.txt 文件中列出的依赖
$pip_exe install -r "$workdir"/pak5.txt
# 使用 pip 安装 pak5.txt 文件中列出的依赖
$pip_exe install -r "$workdir"/pak6.txt
# 使用 pip 安装 pak6.txt 文件中列出的依赖
$pip_exe install -r "$workdir"/pak7.txt
# 使用 pip 安装 pak7.txt 文件中列出的依赖
$pip_exe install -r "$workdir"/pak8.txt
# 使用 pip 安装 pak8.txt 文件中列出的依赖

# Tweak for transparent-background. TODO: remove if upstream updated.
# https://github.com/plemeri/transparent-background/blob/f54975ce489af549dcfc4dc0a2d39e8f69a204fd/setup.py#L45
$pip_exe install --upgrade albucore albumentations
# 升级 albucore 和 albumentations 包，用于透明背景功能的调整

# Install comfyui-frontend-package, version determined by ComfyUI.
$pip_exe install -r https://github.com/comfyanonymous/ComfyUI/raw/refs/heads/master/requirements.txt
# 从 ComfyUI 的 requirements.txt 文件安装依赖

$pip_exe install -r "$workdir"/pakY.txt
# 使用 pip 安装 pakY.txt 文件中列出的依赖
$pip_exe install -r "$workdir"/pakZ.txt

$pip_exe list
# 列出所有已安装的 pip 包

# 验证 PyTorch 安装
$pip_exe list | grep torch  # 应显示 torch 2.3.0+cu121

# 克隆 APEX 仓库
git clone https://github.com/NVIDIA/apex.git "$workdir"/apex
cd "$workdir"/apex

$pip_exe install -v --disable-pip-version-check --no-cache-dir --no-build-isolation \
  --config-settings="--build-option=--cpp_ext" \
  --config-settings="--build-option=--cuda_ext" .
  
cd "$workdir"
rm -rf "$workdir"/apex

cd "$workdir"
# 切换到工作目录

# Add Ninja binary (replacing PIP Ninja if exists)
curl -sSL https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip \
    -o ninja-win.zip
# 下载 Ninja 构建工具的最新版本，保存为 ninja-win.zip
unzip -q -o ninja-win.zip -d "$workdir"/python_standalone/Scripts
# 解压 ninja-win.zip 到 python_standalone/Scripts 目录，-q 静默模式，-o 覆盖已存在的文件
rm ninja-win.zip
# 删除 ninja-win.zip 文件

# Add aria2 binary
curl -sSL https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip \
    -o aria2.zip
# 下载 aria2 下载工具的最新版本，保存为 aria2.zip
unzip -q aria2.zip -d "$workdir"/aria2
# 解压 aria2.zip 到 aria2 目录
mv "$workdir"/aria2/*/aria2c.exe  "$workdir"/python_standalone/Scripts/
# 将 aria2c.exe 移动到 python_standalone/Scripts 目录
rm aria2.zip
# 删除 aria2.zip 文件

# Add FFmpeg binary
curl -sSL https://github.com/GyanD/codexffmpeg/releases/download/7.1.1/ffmpeg-7.1.1-full_build.zip \
    -o ffmpeg.zip
# 下载 FFmpeg 的最新版本，保存为 ffmpeg.zip
unzip -q ffmpeg.zip -d "$workdir"/ffmpeg
# 解压 ffmpeg.zip 到 ffmpeg 目录
mv "$workdir"/ffmpeg/*/bin/ffmpeg.exe  "$workdir"/python_standalone/Scripts/
# 将 ffmpeg.exe 移动到 python_standalone/Scripts 目录
rm ffmpeg.zip
# 删除 ffmpeg.zip 文件

cd "$workdir"
# 切换到工作目录
du -hd1
# 显示当前目录的磁盘使用情况，按目录深度为 1 显示
