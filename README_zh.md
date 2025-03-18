# 哔哩哔哩API播放器项目文档

## 项目概述
基于HarmonyOS原子化服务架构开发的哔哩哔哩第三方客户端，整合B站开放API实现以下核心功能：
- 首页视频流展示与播放
- 用户动态信息获取
- 多语言界面支持
- 响应式数据管理

## 核心架构
### 1. 入口能力(EntryAbility)
```typescript
// EntryAbility.ets 核心功能
class EntryAbility {
  // 应用生命周期管理
  onCreate() {
    this.initRouter()
    this.requestPermissions()
  }
  
  // 动态权限申请
  private requestPermissions() {
    await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(
      context, 
      [ohosPermission.INTERNET]
    )
  }
}
```

### 2. 导航架构
**底部导航组件(BottomTabsModel)**
```typescript
// BottomTabsModel.ets 实现
@Observe
class BottomTabsModel {
  tabs: Array<BottomTab> = [
    { name: 'Home', icon: 'home.svg', component: HomePage },
    { name: 'Dynamic', icon: 'dynamic.svg', component: DynamicPage },
    // ...其他导航项
  ]
}
```

### 3. 视频模块
**三层架构设计**：
1. **数据层(MyDataSource)**：封装B站API请求
2. **业务层(VideoData)**：视频元数据模型
3. **表现层(VideoPlayer)**：基于<Video>组件封装

### 4. API对接层
**双通道设计**：
```typescript
// blibliapi.ets 主接口
interface BilibiliAPI {
  @GET("/x/web-interface/index")
  getHomeFeed(): Promise<VideoData[]>;

  @GET("/x/player/v2")
  getVideoDetail(@Query("aid") id: string): Promise<VideoMetadata>;
}

// xmapi.ts 备用接口
const fallbackAPI = {
  getHomeFeed: () => fetchXM('/page/webInterface/newlist')
}
```

## 技术特性
### 1. HarmonyOS适配
- 原子化服务声明：module.json5
- 权限动态申请机制
- 资源分级管理（base/zh_CN/en_US）

### 2. 状态管理
**响应式数据流**：
```typescript
// DataModel.ets 实现
@Provide('videoData') class VideoDataModel {
  @State currentVideo: Video | null = null
  @Watch('videoList') listObserver = new WatchObserver()
}
```

### 3. 性能优化
- 视频预加载机制
- 列表虚拟滚动（LazyForEach）
- 内存缓存管理（LRU策略）

## 详细组件说明
### 核心组件
| 组件 | 路径 | 功能 |
|------|------|------|
| EntryAbility | entryability/ | 应用入口与权限管理 |
| VideoPlayer | pages/VideoPlayer | 支持弹幕/倍速的播放器 |
| BasicDataSource | Model/ | 数据源基类封装 |

### 页面组件
```typescript
// Home.ets 首页实现
@Component
struct HomePage {
  @State videoList: VideoData[] = []

  build() {
    List({ space: 12 }) {
      LazyForEach(this.videoList, (item) => {
        ListItem() {
          VideoCard({ data: item })
        }
      })
    }
  }
}
```

## 接口文档
### 首页feed流接口
**请求示例**：
```typescript
// bliblihome.ts
const getHomeFeed = async (): Promise<VideoData[]> => {
  const response = await fetchBiliAPI('/x/web-interface/index', {
    headers: {
      'User-Agent': CommonConstants.USER_AGENT
    }
  });
  return parseVideoData(response.data);
};
```

**响应结构**：
```json
{
  "code": 0,
  "data": {
    "banner": [],
    "video_list": [
      {
        "aid": "视频ID",
        "title": "视频标题",
        "duration": 360,
        "stat": {"view": 1000}
      }
    ]
  }
}
```

## 开发指南
### 环境配置
```bash
# 安装HarmonyOS SDK
npm install -g @ohos/hpm-cli
hpm install @ohos/ace-ets

# 调试命令
npm run preview -- --port 8080
```

### 代码规范
1. 组件命名采用大驼峰式（PascalCase）
2. 状态变量使用@State装饰器
3. API请求统一在Model层处理

## 贡献流程
1. 创建特性分支（feature/xxx）
2. 更新接口文档（api-docs/）
3. 提交Pull Request并关联Issue
4. 通过SonarQube代码审查
```