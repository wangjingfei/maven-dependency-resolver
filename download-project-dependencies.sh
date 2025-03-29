#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# Maven本地仓库路径
M2_HOME="${HOME}/.m2"
echo -e "${GREEN}本地Maven仓库路径: ${M2_HOME}${NC}"

# 检查输入参数
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}用法: $0 <pom.xml路径或项目目录路径> [额外的Maven选项]${NC}"
    echo -e "${YELLOW}例如: $0 ./my-project${NC}"
    echo -e "${YELLOW}例如: $0 ./my-project/pom.xml -U${NC}"
    exit 1
fi

# 确定POM文件路径
POM_PATH="$1"
if [ -d "$POM_PATH" ]; then
    # 如果提供的是目录，检查其中是否有pom.xml
    if [ -f "$POM_PATH/pom.xml" ]; then
        POM_PATH="$POM_PATH/pom.xml"
    else
        echo -e "${RED}错误: 在 $POM_PATH 中找不到pom.xml文件${NC}"
        exit 1
    fi
elif [ ! -f "$POM_PATH" ]; then
    echo -e "${RED}错误: $POM_PATH 不存在或不是文件${NC}"
    exit 1
fi

# 移除第一个参数，保留其余参数作为Maven的额外选项
shift
MAVEN_OPTS="$@"

echo -e "${GREEN}使用POM文件: $POM_PATH${NC}"
if [ ! -z "$MAVEN_OPTS" ]; then
    echo -e "${GREEN}额外的Maven选项: $MAVEN_OPTS${NC}"
fi

# 开始下载依赖
echo -e "${GREEN}开始下载项目依赖到本地Maven仓库...${NC}"
echo -e "${YELLOW}这可能需要一些时间，取决于依赖的数量和大小...${NC}"

# 执行Maven命令下载依赖
# 添加 -U 参数强制更新SNAPSHOT版本
# 添加 -Dmaven.wagon.http.ssl.insecure=true 参数忽略SSL证书验证
# 添加 -Dmaven.wagon.http.ssl.allowall=true 参数允许所有SSL证书
mvn -f "$POM_PATH" dependency:go-offline -U \
    -Dmaven.wagon.http.ssl.insecure=true \
    -Dmaven.wagon.http.ssl.allowall=true \
    $MAVEN_OPTS

# 检查执行结果
if [ $? -eq 0 ]; then
    echo -e "${GREEN}所有依赖都已成功下载到: ${M2_HOME}/repository${NC}"
    echo -e "${YELLOW}提示: 如果您想查看具体下载了哪些依赖，可以使用以下命令:${NC}"
    echo -e "${YELLOW}mvn -f \"$POM_PATH\" dependency:tree${NC}"
else
    echo -e "${RED}下载依赖时出现错误，请检查日志${NC}"
    echo -e "${YELLOW}提示: 您可以尝试以下解决方案:${NC}"
    echo -e "1. 检查网络连接是否正常"
    echo -e "2. 确认Maven settings.xml配置是否正确"
    echo -e "3. 检查私有仓库的认证信息是否正确"
    echo -e "4. 尝试使用 -X 参数查看详细日志: mvn -X -f \"$POM_PATH\" dependency:go-offline"
fi

echo -e "${GREEN}完成!${NC}" 