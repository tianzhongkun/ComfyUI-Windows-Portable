#!/bin/bash
set -eux  # 开启调试模式，显示每条命令并在出错时退出

# 配置 Git 全局设置
git config --global core.autocrlf true
workdir=$(pwd)  # 获取当前工作目录
gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'  # 定义简化的 git clone 命令
export PYTHONPYCACHEPREFIX="$workdir/pycache2"  # 设置 Python 缓存目录
export PATH="$PATH:$workdir/ComfyUI_Windows_portable/python_standalone/Scripts"  # 添加 Python 脚本路径到环境变量

ls -lahF  # 列出当前目录的文件和文件夹

# 配置 HuggingFace-Hub 和 Pytorch Hub 的缓存目录
export HF_HUB_CACHE="$workdir/ComfyUI_Windows_portable/HuggingFaceHub"
mkdir -p "${HF_HUB_CACHE}"
export TORCH_HOME="$workdir/ComfyUI_Windows_portable/TorchHome"
mkdir -p "${TORCH_HOME}"

# 移动 python_standalone 到目标目录
mv  "$workdir"/python_standalone  "$workdir"/ComfyUI_Windows_portable/python_standalone

# 下载并解压 MinGit（便携版 Git）
curl -sSL https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/MinGit-2.49.0-64-bit.zip \
    -o MinGit.zip
unzip -q MinGit.zip -d "$workdir"/ComfyUI_Windows_portable/MinGit
rm MinGit.zip

################################################################################
# 克隆 ComfyUI 主应用
git clone https://github.com/comfyanonymous/ComfyUI.git \
    "$workdir"/ComfyUI_Windows_portable/ComfyUI
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI
git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"  # 切换到最新稳定版本
rm -vrf models  # 清空 models 文件夹
mkdir models  # 重新创建 models 文件夹

# 克隆自定义节点
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes
$gcs https://github.com/ltdrdata/ComfyUI-Manager.git

# 克隆其他节点分类（工作区、通用、控制、视频等）
$gcs https://github.com/crystian/ComfyUI-Crystools.git
$gcs https://github.com/pydn/ComfyUI-to-Python-Extension.git

# General
$gcs https://github.com/akatz-ai/ComfyUI-AKatz-Nodes.git
$gcs https://github.com/Amorano/Jovimetrix.git
$gcs https://github.com/bash-j/mikey_nodes.git
$gcs https://github.com/chrisgoringe/cg-use-everywhere.git
$gcs https://github.com/cubiq/ComfyUI_essentials.git
$gcs https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git
$gcs https://github.com/jags111/efficiency-nodes-comfyui.git
$gcs https://github.com/kijai/ComfyUI-KJNodes.git
$gcs https://github.com/mirabarukaso/ComfyUI_Mira.git
$gcs https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
$gcs https://github.com/rgthree/rgthree-comfy.git
$gcs https://github.com/shiimizu/ComfyUI_smZNodes.git
$gcs https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
$gcs https://github.com/WASasquatch/was-node-suite-comfyui.git
$gcs https://github.com/yolain/ComfyUI-Easy-Use.git

# Control
$gcs https://github.com/chflame163/ComfyUI_LayerStyle.git
$gcs https://github.com/cubiq/ComfyUI_InstantID.git
$gcs https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
$gcs https://github.com/cubiq/PuLID_ComfyUI.git
$gcs https://github.com/Fannovel16/comfyui_controlnet_aux.git
$gcs https://github.com/florestefano1975/comfyui-portrait-master.git
$gcs https://github.com/Gourieff/ComfyUI-ReActor.git
$gcs https://github.com/huchenlei/ComfyUI-IC-Light-Native.git
$gcs https://github.com/huchenlei/ComfyUI-layerdiffuse.git
$gcs https://github.com/Jonseed/ComfyUI-Detail-Daemon.git
$gcs https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
$gcs https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git
$gcs https://github.com/ltdrdata/ComfyUI-Inspire-Pack.git
$gcs https://github.com/mcmonkeyprojects/sd-dynamic-thresholding.git
$gcs https://github.com/twri/sdxl_prompt_styler.git

# Video
$gcs https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git
$gcs https://github.com/FizzleDorf/ComfyUI_FizzNodes.git
$gcs https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
$gcs https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
$gcs https://github.com/melMass/comfy_mtb.git

# More
$gcs https://github.com/akatz-ai/ComfyUI-DepthCrafter-Nodes.git
$gcs https://github.com/city96/ComfyUI-GGUF.git
$gcs https://github.com/cubiq/ComfyUI_FaceAnalysis.git
$gcs https://github.com/digitaljohn/comfyui-propost.git
$gcs https://github.com/kijai/ComfyUI-DepthAnythingV2.git
$gcs https://github.com/kijai/ComfyUI-Florence2.git
$gcs https://github.com/neverbiasu/ComfyUI-SAM2.git
$gcs https://github.com/pythongosssss/ComfyUI-WD14-Tagger.git
$gcs https://github.com/SLAPaper/ComfyUI-Image-Selector.git
$gcs https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git
$gcs https://github.com/CY-CHENYUE/ComfyUI-Janus-Pro.git

################################################################################
# 复制附件文件（包括启动脚本）
cp -rf "$workdir"/attachments/. \
    "$workdir"/ComfyUI_Windows_portable/

du -hd2 "$workdir"/ComfyUI_Windows_portable  # 显示目录大小

################################################################################
# 下载 TAESD 模型，用于实时预览
cd "$workdir"
$gcs https://github.com/madebyollin/taesd.git
mkdir -p "$workdir"/ComfyUI_Windows_portable/ComfyUI/models/vae_approx
cp taesd/*_decoder.pth \
    "$workdir"/ComfyUI_Windows_portable/ComfyUI/models/vae_approx/
rm -rf taesd

# 下载 ReActor 所需模型
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/models
curl -sSL https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth \
    --create-dirs -o facerestore_models/codeformer-v0.1.0.pth
curl -sSL https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth \
    --create-dirs -o facerestore_models/GFPGANv1.4.pth
curl -sSL https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128_fp16.onnx \
    --create-dirs -o insightface/inswapper_128_fp16.onnx
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/config.json \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/config.json
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/confusion_matrix.png \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/confusion_matrix.png
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/model.safetensors \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/model.safetensors
curl -sSL https://huggingface.co/AdamCodd/vit-base-nsfw-detector/resolve/main/preprocessor_config.json \
    --create-dirs -o nsfw_detector/vit-base-nsfw-detector/preprocessor_config.json

# 安装 Impact-Pack 和 Impact-Subpack 的依赖
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Impact-Pack
"$workdir"/ComfyUI_Windows_portable/python_standalone/python.exe -s -B install.py
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Impact-Subpack
"$workdir"/ComfyUI_Windows_portable/python_standalone/python.exe -s -B install.py

################################################################################
# 运行测试（仅使用 CPU），并让自定义节点下载所需模型
cd "$workdir"/ComfyUI_Windows_portable
./python_standalone/python.exe -s -B ComfyUI/main.py --quick-test-for-ci --cpu

################################################################################
# 清理临时文件和日志
rm -vf "$workdir"/ComfyUI_Windows_portable/*.log
rm -vf "$workdir"/ComfyUI_Windows_portable/ComfyUI/user/*.log
rm -vrf "$workdir"/ComfyUI_Windows_portable/ComfyUI/user/default/ComfyUI-Manager

cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes
rm -vf ./ComfyUI-Custom-Scripts/pysssss.json
rm -vf ./ComfyUI-Easy-Use/config.yaml
rm -vf ./ComfyUI-Impact-Pack/impact-pack.ini
rm -vf ./Jovimetrix/web/config.json
rm -vf ./was-node-suite-comfyui/was_suite_config.json

# 重置 ComfyUI-Manager 的状态
cd "$workdir"/ComfyUI_Windows_portable/ComfyUI/custom_nodes/ComfyUI-Manager
git reset --hard
git clean -fxd

cd "$workdir"  # 返回工作目录
