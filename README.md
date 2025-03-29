# Maven依赖下载工具

这个工具集提供了两个脚本，用于将Maven依赖下载到本地的`.m2`仓库中。

## 脚本说明

### 1. 从依赖列表下载 (download-dependencies.sh)

这个脚本从一个依赖列表文件中读取Maven依赖坐标，并将它们下载到本地Maven仓库。

**使用方法:**

1. 创建一个名为`dependencies.txt`的文件，包含Maven依赖坐标，格式为`groupId:artifactId:version`
2. 运行脚本:
   ```
   ./download-dependencies.sh
   ```

**依赖列表文件格式:**
```
# 注释行以#开头
org.springframework:spring-core:5.3.30
org.springframework:spring-context:5.3.30
```

### 2. 从现有项目下载 (download-project-dependencies.sh)

这个脚本从现有Maven项目中提取并下载所有依赖（包括传递依赖）。

**使用方法:**

```bash
./download-project-dependencies.sh <pom.xml路径或项目目录> [额外的Maven选项]
```

**示例:**
```bash
# 从当前目录下的pom.xml下载依赖
./download-project-dependencies.sh ./pom.xml

# 从指定项目目录下载依赖
./download-project-dependencies.sh /path/to/my-project

# 下载依赖并强制更新（忽略本地缓存）
./download-project-dependencies.sh /path/to/my-project -U
```

## 默认依赖

我们提供了一个示例`dependencies.txt`文件，包含常用的Java库依赖，包括:

- Spring框架
- Hibernate
- Apache Commons
- MySQL驱动
- 日志框架
- 测试框架

您可以根据需要修改此文件，添加或删除依赖。

## 注意事项

1. 这些脚本默认将依赖下载到用户目录下的`.m2/repository`文件夹中
2. 您需要有互联网连接才能下载依赖
3. 如果下载依赖时出现错误，请确保依赖坐标正确，并且Maven可以连接到仓库