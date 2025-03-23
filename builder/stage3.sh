#!/bin/bash
# 启用严格模式，确保脚本在遇到错误时立即停止执行，并输出调试信息
set -eux

# 在 stage3.sh 顶部添加：
output_dir="$workdir/builder"  # 确保输出到 builder 目录

# 列出当前目录下的所有文件和目录，包括详细信息（权限、大小、修改时间等）以及符号链接标记
ls -lahF

# 显示 ComfyUI_Windows_portable 目录的磁盘使用情况，深度限制为 2 级子目录，结果以人类可读的格式显示
du -hd2 ComfyUI_Windows_portable

# 显示 ComfyUI_Windows_portable/ComfyUI/custom_nodes 目录的磁盘使用情况，深度限制为 1 级子目录，结果以人类可读的格式显示
du -hd1 ComfyUI_Windows_portable/ComfyUI/custom_nodes

# 列出 ComfyUI_Windows_portable/ComfyUI/models 目录中每个文件和子目录的磁盘使用情况，结果以人类可读的格式显示
du -h ComfyUI_Windows_portable/ComfyUI/models

# 将模型目录与其余部分分离以便单独压缩
# 创建目标目录结构，用于存放分离后的模型文件
mkdir -p m_folder/ComfyUI_Windows_portable/ComfyUI
# 将模型目录移动到新创建的目标目录中
mv "ComfyUI_Windows_portable/ComfyUI/models" "m_folder/ComfyUI_Windows_portable/ComfyUI/models"
# 使用 git 恢复原始 models 目录内容，以便保留完整的项目结构
git -C "ComfyUI_Windows_portable/ComfyUI" checkout "models"

# 使用 7-Zip 对主目录进行高压缩率归档，采用 LZMA2 算法，分卷大小为 2140000000 字节（约 2GB），适用于 GitHub 的上传限制
"C:\Program Files\7-Zip\7z.exe" a -t7z -m0=lzma2 -mx=7 -mfb=64 -md=128m -ms=on -mf=BCJ2 -v2140000000b "$output_dir/ComfyUI_Windows_portable_$(date +%Y%m%d).7z" ComfyUI_Windows_portable

# 如果需要更快的压缩速度，可以注释掉上述命令并启用以下命令
# 使用 ZIP 格式对主目录进行低压缩率归档，分卷大小为 2140000000 字节
# "C:\Program Files\7-Zip\7z.exe" a -tzip -v2140000000b ComfyUI_Windows_portable_cu126.zip ComfyUI_Windows_portable

# 进入包含模型文件的临时目录
cd m_folder
# 使用 ZIP 格式对模型文件进行归档，分卷大小为 2140000000 字节
"C:\Program Files\7-Zip\7z.exe" a -tzip -v2140000000b "$output_dir/models_$(date +%Y%m%d).zip" ComfyUI_Windows_portable
# 将生成的压缩文件移动到上一级目录
mv ./*.zip* ../
# 返回到脚本初始工作目录
cd ..

# 再次列出当前目录下的所有文件和目录，验证压缩文件是否生成成功
ls -lahF

################################################################################
# 关于 7-Zip 压缩的注意事项：

# 分卷大小设置为 2140000000 字节，因为 GitHub 对单个文件的上传大小有限制。

# LZMA2 算法比 LZMA 快约 75%，但需要更多的内存。
# 参数 "-mx=5 -mfb=32 -md=16m" 等效于 7-Zip GUI 中的“正常压缩”级别。

# 出于好奇，进行了以下对比测试：
# 测试条件：9181 个文件夹，61097 个文件，总大小约 11 GiB

# "-mx=7 -mfb=64 -md=32m"
# 归档大小：4398 MiB，压缩比：0.426，耗时：1050 秒

# "-mx=5 -mfb=32 -md=16m"
# 归档大小：4490 MiB，压缩比：0.429，耗时：840 秒

# "-mx=3 -mfb=32 -md=4m"
# 归档大小：4795 MiB，压缩比：0.459，耗时：565 秒

# 综合考虑压缩比和耗时，选择了“正常压缩”方案。此外，该方案的解压速度也较为理想。
################################################################################ 