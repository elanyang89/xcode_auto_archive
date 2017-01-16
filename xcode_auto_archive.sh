#!/bin/sh

# 1.Configuration Info
# 
# 本地项目路径
projectDir="/Users/elan/Desktop/yourProjDir"
# 
# Provisioning Profile 需修改 查看本地配置文件 
# 公司发布证书provisioning profile UUID 
# 一个是App的 一个是Extension Today 的
# 
APP_PROVISIONING_PROFILE="your_provisioning_profile_number"
EXTENSION_PROVISIONING_PROFILE="your_extension_provisioning_profile_number"

# schemes Name
schemeName="yourScheme"

# Code Sign ID
CODE_SIGN_IDENTITY="your_code_sign_id"

#############
## 2.修改 plist 文件
## 可以修改 plist 内容如：版本号等 也可以不做任何修改
# 
bundleVersion="6.9.x.1"
infoPlistPath="${projectDir}/${schemeName}/${schemeName}/Info.plist"
defaults write $infoPlistPath CFBundleVersion $bundleVersion
defaults write $infoPlistPath CFBundleShortVersionString $bundleVersion

if [[ $? = 0 ]]; then
  echo "\033[31m 修改 Plist 成功\033[0m"
else
  echo "\033[31m 修改 Plist 失败\033[0m"
fi

# 3.生成 .xcarchive 路径
# 这里可以根据不同的命令生成自己需要的格式的文件 .xcarchive 或者.ipa
# 默认在项目文件根目录下创建build目录
# 
buildDir="build"

# 开始时间
beginTime=`date +%s`

# 清除缓存
rm -rf $projectDir/$buildDir

# 生成 xcarchive
xcodebuild -workspace ${projectDir}/yourProj.xcworkspace -scheme ${schemeName} -configuration Release -archivePath "${projectDir}/build/${schemeName}.xcarchive" archive

# 生成 .xcarchive & Release-iphoneos等文件夹
# xcodebuild -project ${projectDir}/yourProj.xcodeproj -target ${schemeName} -configuration release
# xcodebuild -workspace ${projectDir}/yourProj.xcworkspace -scheme ${schemeName} -configuration Release -archivePath "${projectDir}/build/${schemeName}.xcarchive" archive clean -sdk iphoneos build CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" APP_PROVISIONING_PROFILE="${APP_PROVISIONING_PROFILE}" SYMROOT="${projectDir}/build"
#
#项目里面有Extension
# xcodebuild -workspace ${projectDir}/yourProj.xcworkspace -scheme ${schemeName} -configuration Release -archivePath "${projectDir}/build/${schemeName}.xcarchive" archive clean -sdk iphoneos build CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" APP_PROVISIONING_PROFILE="${APP_PROVISIONING_PROFILE}" EXTENSION_RPOVISIONING_PROFILE="${EXTENSION_PROVISIONING_PROFILE}" SYMROOT="${projectDir}/build"


if [[ $? = 0 ]]; then
  echo "\033[31m 编译成功\n \033[0m"
else
  echo "\033[31m 编译失败\n \033[0m"
fi

# 4.生成 ipa
# 由第三步骤得到的.xcarchive 转化为 .ipa 文件
xcodebuild -exportArchive -archivePath "${projectDir}/build/${schemeName}.xcarchive" -exportPath "${projectDir}/build/${schemeName}.ipa"

if [[ $? = 0 ]]; then
  echo "\033[31m \n 生成 IPA 成功 \n\n\n\n\n\033[0m"
else
  echo "\033[31m \n 生成 IPA 失败 \n\n\n\n\n\033[0m"
fi

# 5. 将生成dSYMs 文件拷贝到同一文件目录/build
# 最后/build 目录下面有.xcarchive&.ipa&dSYM 三类文件
cp -Rf ${projectDir}/build/${schemeName}.xcarchive/dSYMs/* ${projectDir}/build


# 结束时间
endTime=`date +%s`
echo -e "打包时间$[ endTime - beginTime ]秒"