# AI-ClassWise · 智能教务助手

> 一个面向中小学老师的**单文件、本地离线、AI 增强**的教务管理系统。  
> 零安装、零云端、数据全部留在自己电脑上。

## ✨ 特性

- **单文件部署** —— 主程序就是一个 HTML，配合本地小型 HTTP 服务器（`start.bat` 一键启动）
- **完整教务流** —— 学生管理、成绩录入与排名、考勤、Excel 报表导出
- **本地 AI** —— 接入本机 Ollama，自动生成评语 / 成绩分析 / 班级总结 / 中文问答
- **OCR 拍照录入** —— 内置 PaddleOCR，照片直接识别名单/成绩单/考勤表
- **AI 双通道**：
  - 选 Gemma 4 多模态 → AI 直接看图
  - 选 Qwen 2.5 → PaddleOCR 转文字后交给 AI
- **数据完全本地** —— localStorage 存储 + 一键 JSON 导出/导入备份
- **零联网** —— 全部库、字体、模型都打包在本地，断网照常用

## 🚀 快速开始

1. 克隆或下载本仓库
2. 双击 `start.bat`（首次会弹出 PowerShell 黑窗口，**不要关**）
3. 浏览器自动打开 `http://localhost:8765/ClassWise.html`
4. 想用 AI / OCR 功能 → 参考 [`使用说明.md`](使用说明.md) 第五、六节装 Ollama

> ⚠️ 不能直接双击 `ClassWise.html`：OCR 需要 `SharedArrayBuffer`，浏览器只允许从 `http://localhost` 来源使用。

## 📁 目录结构

```
AI-ClassWise/
├── ClassWise.html          # 主程序（v2.8）
├── 教务系统.html            # 旧版（v1.0，留作参考，可双击直开）
├── start.bat               # 启动入口
├── server.ps1              # 本地 HTTP 服务器
├── 使用说明.md             # 详细用户手册
├── README.md               # 本文件
├── libs/                   # 前端依赖（已本地化）
│   ├── bootstrap.min.css
│   ├── bootstrap.bundle.min.js
│   └── xlsx.full.min.js
├── ocr/                    # PaddleOCR 模型与运行时（约 22MB）
│   ├── ch_PP-OCRv4_det_infer.onnx
│   ├── ch_PP-OCRv4_rec_infer.onnx
│   ├── ort-wasm-simd-threaded.*
│   └── ppocr_keys_v1.txt
└── 版本备份/                # 历史 zip 备份（v1.0 → v2.8，约 180MB，不入库）
```

## 🛠️ 技术栈

| 层 | 选型 |
|----|------|
| UI | Bootstrap 5（本地化） |
| 表格导出 | SheetJS / xlsx.full.min.js |
| OCR | PaddleOCR PP-OCRv4 + ONNX Runtime Web (WASM) |
| AI | 本机 Ollama HTTP API（`http://localhost:11434`） |
| 存储 | 浏览器 localStorage + JSON 导入导出 |
| 服务器 | PowerShell HttpListener（约 100 行） |

## 🤖 推荐 AI 模型

| 电脑配置 | 模型 | 命令 |
|---------|------|------|
| 4GB 内存（旧电脑） | Qwen 2.5 0.5B | `ollama pull qwen2.5:0.5b` |
| 8GB 内存 | Qwen 2.5 7B | `ollama pull qwen2.5:7b` |
| 8GB+ 想用视觉 OCR | Gemma 4 E4B | `ollama pull gemma4:e4b` |
| 16GB+ | Gemma 4 旗舰 | `ollama pull gemma4` |

启动 Ollama 前请设置环境变量 `OLLAMA_ORIGINS=*`，否则浏览器跨域会被拒。

## 📦 版本说明

主程序 **v2.8**，相较 v1.0 主要变化：

- 增加 OCR 拍照录入
- 增加 AI 助手（Ollama 集成）
- 改为本地 HTTP 启动方式（替换原单 HTML 双击模式）
- UI 改版 + 数据导出导入完善

> 历史 zip 备份没有入库（共 180MB），如有需要请向项目维护者索取。

## 📝 License

仅供教学和个人使用。

## 🙏 致谢

- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) — 中文 OCR 模型
- [ONNX Runtime Web](https://onnxruntime.ai/) — 浏览器推理引擎
- [Ollama](https://ollama.com/) — 本地大模型运行时
- [Bootstrap](https://getbootstrap.com/) · [SheetJS](https://sheetjs.com/)
