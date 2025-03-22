#!/bin/bash
set -eu

cat > pak7.txt << EOF
facexlib
fvcore
gpytoolbox
EOF

array=(
https://github.com/akatz-ai/ComfyUI-AKatz-Nodes/raw/refs/heads/main/requirements.txt
https://github.com/akatz-ai/ComfyUI-DepthCrafter-Nodes/raw/refs/heads/main/requirements.txt
https://github.com/Amorano/Jovimetrix/raw/refs/heads/main/requirements.txt
https://github.com/chflame163/ComfyUI_LayerStyle/raw/refs/heads/main/repair_dependency_list.txt
https://github.com/chflame163/ComfyUI_LayerStyle/raw/refs/heads/main/requirements.txt
https://github.com/city96/ComfyUI-GGUF/raw/refs/heads/main/requirements.txt
https://github.com/digitaljohn/comfyui-propost/raw/refs/heads/master/requirements.txt
https://github.com/Jonseed/ComfyUI-Detail-Daemon/raw/refs/heads/main/requirements.txt
https://github.com/kijai/ComfyUI-DepthAnythingV2/raw/refs/heads/main/requirements.txt
https://github.com/kijai/ComfyUI-Florence2/raw/refs/heads/main/requirements.txt
https://github.com/mirabarukaso/ComfyUI_Mira/raw/refs/heads/main/requirements.txt
https://github.com/neverbiasu/ComfyUI-SAM2/raw/refs/heads/main/requirements.txt
https://github.com/pydn/ComfyUI-to-Python-Extension/raw/refs/heads/main/requirements.txt
https://github.com/yolain/ComfyUI-Easy-Use/raw/refs/heads/main/requirements.txt
)

temp_file=$(mktemp)  # 创建临时文件
exclude_file=$(mktemp)

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

# 合并 pak4.txt 和 pak5.txt 为排除列表
cat pak4.txt pak5.txt 2>/dev/null | sed -E '
    s/#.*$//; /^$/d; s/[[:space:]]//g;  # 与依赖项相同的标准化处理
    s/;.*$//; s/[<>=~!]=.*$//; s/[<>].*$//;
' | tr '_' '-' | tr '[:upper:]' '[:lower:]' | sort -u > "$exclude_file"

# 生成最终结果（从 temp_file 中排除 exclude_file 内容）
grep -Fxv -f "$exclude_file" "$temp_file" > pak7.txt

# 清理临时文件
rm -f "$temp_file" "$exclude_file"

echo "<pak7.txt> 生成完成，新增依赖项数量: $(wc -l < pak7.txt)"
