#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# Maven本地仓库路径
M2_HOME="${HOME}/.m2"
echo -e "${GREEN}本地Maven仓库路径: ${M2_HOME}${NC}"

# 检查dependencies.txt文件是否存在
if [ ! -f "dependencies.txt" ]; then
    echo -e "${RED}错误: dependencies.txt文件不存在${NC}"
    echo -e "${YELLOW}请创建一个包含Maven依赖的文件，格式如下:${NC}"
    echo -e "${YELLOW}groupId:artifactId:version${NC}"
    echo -e "${YELLOW}例如: org.springframework:spring-core:5.3.9${NC}"
    exit 1
fi

# 创建临时pom.xml文件
echo -e "${GREEN}创建临时pom.xml文件...${NC}"
cat > temp-pom.xml << EOF
<project xmlns="http://maven.apache.org/POM/4.0.0" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.temp</groupId>
    <artifactId>dependency-downloader</artifactId>
    <version>1.0.0</version>
    <dependencies>
EOF

# 读取dependencies.txt并添加到pom.xml中
echo -e "${GREEN}正在添加依赖...${NC}"
while IFS= read -r line || [[ -n "$line" ]]; do
    # 跳过空行和注释
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi
    
    # 解析依赖坐标
    IFS=":" read -ra COORDS <<< "$line"
    if [ ${#COORDS[@]} -lt 3 ]; then
        echo -e "${RED}警告: 依赖格式不正确 - $line (跳过)${NC}"
        continue
    fi
    
    GROUP_ID=${COORDS[0]}
    ARTIFACT_ID=${COORDS[1]}
    VERSION=${COORDS[2]}
    
    echo -e "${YELLOW}添加依赖: $GROUP_ID:$ARTIFACT_ID:$VERSION${NC}"
    
    # 添加依赖到pom.xml
    cat >> temp-pom.xml << EOF
        <dependency>
            <groupId>$GROUP_ID</groupId>
            <artifactId>$ARTIFACT_ID</artifactId>
            <version>$VERSION</version>
        </dependency>
EOF
done < "dependencies.txt"

# 完成pom.xml文件
cat >> temp-pom.xml << EOF
    </dependencies>
</project>
EOF

# 使用Maven下载依赖
echo -e "${GREEN}开始下载依赖到本地Maven仓库...${NC}"
mvn -f temp-pom.xml dependency:resolve

# 检查执行结果
if [ $? -eq 0 ]; then
    echo -e "${GREEN}所有依赖都已成功下载到: ${M2_HOME}/repository${NC}"
else
    echo -e "${RED}下载依赖时出现错误，请检查日志${NC}"
fi

# 清理临时文件
echo -e "${GREEN}清理临时文件...${NC}"
rm temp-pom.xml

echo -e "${GREEN}完成!${NC}" 