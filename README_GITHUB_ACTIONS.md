# GitHub Actions 编译 APK（Release）

1. 把整个项目上传到 GitHub（建议仓库根目录就是本项目根，能看到 `pubspec.yaml`）。
2. 确认仓库里存在：`.github/workflows/build-android-apk.yml`
3. 打开 GitHub 仓库 → **Actions** → 选择 **Build Android APK (Release)** → **Run workflow**。
4. 等待完成后，在该次运行的页面底部 **Artifacts** 下载 `app-release-apk`。

> 说明：workflow 使用 **Ubuntu + Java 17 + Gradle 8.7**，并直接调用系统 Gradle 构建 `:app:assembleRelease`，避免依赖本地/Windows 的 Gradle Wrapper 下载问题。
