#!/bin/bash
set -eu

echo '#' > pak5.txt

array=(
https://github.com/comfyanonymous/ComfyUI/raw/refs/heads/master/requirements.txt
https://github.com/crystian/ComfyUI-Crystools/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/ComfyUI_essentials/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/ComfyUI_FaceAnalysis/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/ComfyUI_InstantID/raw/refs/heads/main/requirements.txt
https://github.com/cubiq/PuLID_ComfyUI/raw/refs/heads/main/requirements.txt
https://github.com/Fannovel16/comfyui_controlnet_aux/raw/refs/heads/main/requirements.txt
https://github.com/Fannovel16/ComfyUI-Frame-Interpolation/raw/refs/heads/main/requirements-no-cupy.txt
https://github.com/FizzleDorf/ComfyUI_FizzNodes/raw/refs/heads/main/requirements.txt
https://github.com/Gourieff/ComfyUI-ReActor/raw/refs/heads/main/requirements.txt
https://github.com/huchenlei/ComfyUI-layerdiffuse/raw/refs/heads/main/requirements.txt
https://github.com/jags111/efficiency-nodes-comfyui/raw/refs/heads/main/requirements.txt
https://github.com/kijai/ComfyUI-KJNodes/raw/refs/heads/main/requirements.txt
https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Impact-Pack/raw/refs/heads/Main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Impact-Subpack/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Inspire-Pack/raw/refs/heads/main/requirements.txt
https://github.com/ltdrdata/ComfyUI-Manager/raw/refs/heads/main/requirements.txt
https://github.com/melMass/comfy_mtb/raw/refs/heads/main/requirements.txt
https://github.com/WASasquatch/was-node-suite-comfyui/raw/refs/heads/main/requirements.txt
)

temp_file=$(mktemp)  # 创建临时文件

for url in "${array[@]}"; do
    curl -sSLf "$url" | while IFS= read -r line; do
        # 分步处理每行依赖项
        processed=$(echo "$line" | sed -E '
            s/#.*$//;                  # 移除行内注释
            /^$/d;                     # 删除空行
            s/[[:space:]]//g;          # 删除所有空格
            s/;.*$//;                  # 关键！移除所有环境条件（分号后的内容）
            s/[<>=~!]=.*$//;           # 移除版本号（如 >=1.0, ==2.3）
            s/[<>].*$//;               # 处理单独 < 或 >（如 numpy<2）
        ' | tr '_' '-' | tr '[:upper:]' '[:lower:]')  # 统一为小写+连字符格式

        # 仅保留非空行
        [[ -n "$processed" ]] && echo "$processed"
    done
done | sort -u >> "$temp_file"  # 直接去重

# 排除pak4.txt中的内容
if [[ -f "pak4.txt" ]]; then
    grep -Fivx -f pak4.txt "$temp_file" > pak5.txt
else
    mv "$temp_file" pak5.txt
fi

rm -f "$temp_file"

echo "生成完成，唯一依赖项数量: $(wc -l < pak5.txt)"