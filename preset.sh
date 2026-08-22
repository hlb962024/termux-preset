#!/data/data/com.termux/files/usr/bin/bash

# Termux 自动化初始化脚本（顺序调整版）
# 使用方法：保存为 init_termux.sh，执行 bash init_termux.sh

set -e  # 遇错即停

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查 Termux 环境
if [ -z "$PREFIX" ]; then
    echo -e "${RED}错误：该脚本只能在 Termux 中运行！${NC}"
    exit 1
fi

echo -e "${GREEN}>>> 开始 Termux 自动化初始化 <<<${NC}"

cd ~

# ------------------------------------------------------------
# 步骤 1：换清华源并全面更新
# ------------------------------------------------------------
echo -e "${YELLOW}[1/9] 更换清华源并更新系统...${NC}"
cp $PREFIX/etc/apt/sources.list $PREFIX/etc/apt/sources.list.bak.$(date +%Y%m%d)
echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main" > $PREFIX/etc/apt/sources.list
apt update
pkg update
apt upgrade -y
pkg update 
pkg upgrade -y
echo -e "${GREEN}源更换及系统更新完成。${NC}"

# ------------------------------------------------------------
# 步骤 2：安装 git（clone 所需）
# ------------------------------------------------------------
echo -e "${YELLOW}[2/9] 安装 git...${NC}"
pkg install -y git
echo -e "${GREEN}git 安装完成。${NC}"

# ------------------------------------------------------------
# 步骤 3：克隆预设仓库（如已存在则跳过）
# ------------------------------------------------------------
echo -e "${YELLOW}[3/9] 克隆预设仓库...${NC}"
if [ -d "termux-preset" ]; then
    echo -e "${GREEN}目录 termux-preset 已存在，跳过克隆。${NC}"
else
    git clone https://gh-proxy.org/https://github.com/hlb962024/termux-preset.git
    echo -e "${GREEN}仓库克隆完成。${NC}"
fi

# ------------------------------------------------------------
# 步骤 4：更换字体
# ------------------------------------------------------------
echo -e "${YELLOW}[4/9] 更换字体...${NC}"
if [ -f "termux-preset/font.ttf" ]; then
    mkdir -p ~/.termux
    cp termux-preset/font.ttf ~/.termux/font.ttf
    termux-reload-settings
    echo -e "${GREEN}字体更换成功（重启会话后生效）。${NC}"
else
    echo -e "${YELLOW}警告：termux-preset/font.ttf 不存在，跳过字体更换。${NC}"
fi

# ------------------------------------------------------------
# 步骤 5：安装其余软件包（git 已装，可重复安装无妨）
# ------------------------------------------------------------
echo -e "${YELLOW}[5/9] 安装其余软件包...${NC}"
pkg install -y openssh termux-services fish starship busybox python python-pip android-tools traceroute wget fastfetch
# git 已装，此处不再重复，若想确保可加 git
echo -e "${GREEN}软件包安装完成。${NC}"

# ------------------------------------------------------------
# 步骤 6：pip 换清华源
# ------------------------------------------------------------
echo -e "${YELLOW}[6/9] pip 更换清华源...${NC}"
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
echo -e "${GREEN}pip 源更换完成。${NC}"

# ------------------------------------------------------------
# 步骤 7：设置 fish 主题并设为默认 Shell
# ------------------------------------------------------------
echo -e "${YELLOW}[7/9] 配置 fish 主题及默认 Shell...${NC}"
if [ -f "termux-preset/starship.toml" ]; then
    mkdir -p ~/.config
    cp termux-preset/starship.toml ~/.config/starship.toml
    mkdir -p ~/.config/fish/conf.d
    echo "starship init fish | source" > ~/.config/fish/conf.d/starship.fish
    echo -e "${GREEN}starship 主题已配置。${NC}"
else
    echo -e "${YELLOW}警告：termux-preset/starship.toml 不存在，跳过主题配置。${NC}"
fi

chsh -s fish
echo -e "${GREEN}默认 Shell 已设置为 fish（新会话生效）。${NC}"

# ------------------------------------------------------------
# 步骤 8：添加 X11 源
# ------------------------------------------------------------
echo -e "${YELLOW}[8/9] 添加 X11 源...${NC}"
pkg install -y x11-repo
sed -i 's@^\(deb.*x11 main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-x11 x11 main @' $PREFIX/etc/apt/sources.list.d/x11.list && apt update
echo -e "${GREEN}X11 源添加完成。${NC}"

# ------------------------------------------------------------
# 步骤 9：提示用户重启后启用 SSH
# ------------------------------------------------------------
echo -e "${YELLOW}[9/9] 所有步骤执行完毕！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "初始化已完成。请执行以下操作："
echo -e "  1. ${RED}重启 Termux${NC}（完全退出并重新打开）"
echo -e "  2. 重启后运行命令：${YELLOW}sv-enable sshd${NC} 或 ${YELLOW}sv up sshd${NC}"
echo -e "     （启动 SSH 服务，之后可通过 ssh 连接）"
echo -e "${GREEN}========================================${NC}"
