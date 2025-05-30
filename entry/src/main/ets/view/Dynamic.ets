import { MyDataSource } from '../Model/MyDataSource';
import { VideoData } from '../Model/VideoData';
import { requestSelf } from '../api/bliblihome'; // 确保路径正确
import { xmapis } from '../api/xmapis'; // 确保路径正确
import http from '@ohos.net.http';
import { promptAction, router } from '@kit.ArkUI';



/*
 *
 * 1. top: { anchor: "row3", align: VerticalAlign.Bottom }
anchor: "row3"：这个参数指明了当前组件的上边缘将与名为 row3 的组件对齐。
align: VerticalAlign.Bottom：当前组件的上边缘将对齐到 row3 的底部。也就是说，当前组件的顶部将位于 row3 的底部位置。
2. bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
anchor: "__container__"：这里使用了 __container__ 作为锚点，表示当前组件的底部将与其父容器的底部对齐。
align: VerticalAlign.Bottom：当前组件的底部将对齐到容器的底部边缘。
3. left: { anchor: "__container__", align: HorizontalAlign.Start }
anchor: "__container__"：当前组件的左边缘将与父容器的左边缘对齐。
align: HorizontalAlign.Start：这表示当前组件的左边缘将对齐到容器的左侧开始位置。
4. right: { anchor: "row1", align: HorizontalAlign.End }
anchor: "row1"：当前组件的右边缘将与名为 row1 的组件对齐。
align: HorizontalAlign.End：这表示当前组件的右边缘将对齐到 row1 的右边缘。
* */
@Entry
@Component
export struct Dynamic {
  private myController: VideoController = new VideoController();
  private datas: MyDataSource = new MyDataSource();
  @State index: number = 0;
  @State apiResponse: object = []; // 存储原始 API 响应
  @State loadingMore: boolean = false; // 用于指示是否正在加载更多数据
  @State bottomTabIndex: number = 1;
  @Styles
  listCard() {
    .backgroundColor(Color.White)
    .height(72)
    .width("100%")
    .borderRadius(12)
  }

  async aboutToAppear() {
    await this.loadData(); // 加载初始数据
  }

  // 加载数据的公共方法
  private async loadData() {
    const response = await xmapis();
    if (response) {
      this.apiResponse = response; // 存储原始响应结果
      this.parseApiResponse(response); // 解析响应并存储视频数据
    } else {
      console.error('请求失败');
    }
  }

  private parseApiResponse(response: object) {
    console.info(JSON.stringify(response));
    if ((response["message"] === "成功获取视频列表" || response["message"] ==='成功获取视频列表') && response["data"]) {
      const items:Array<string> = response["data"];

      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        this.datas.pushData({
          description: item["title"], // 标题
          head: item["pic"], // 封面URL
          video: item["download_link"], // 视频链接
          bvid:item["bvid"],//地址
          name: item['name'], // UP主
          face:item['face'],//头像
          view: item["view"], // 播放量
          total:item["current_viewers"]?? 5,//当前观看人数
          like:item["like"],//点赞
          barrage: item["danmaku"], // 弹幕数
          time: item["duration"], // 时长
          pubdate:item["pubdate"],//发布时间
          coins: item["coin"],//投币
          favorites: item["favorite"],//收藏
          shares: item["share"],//转发
          controller: this.myController,
          auto:true,
          play:true,
          index:i,
        });

        const updatedData: VideoData={
          description: item["title"], // 标题
          head: item["pic"], // 封面URL
          video: item["download_link"], // 视频链接
          bvid:item["bvid"],//地址
          name: item['name'], // UP主
          face:item['face'],//头像
          view: item["view"], // 播放量
          total:item["current_viewers"]?? 5,//当前观看人数
          like:item["like"],//点赞
          barrage: item["danmaku"], // 弹幕数
          time: item["duration"], // 时长
          pubdate:item["pubdate"],//发布时间
          coins: item["coin"],//投币
          favorites: item["favorite"],//收藏
          shares: item["share"],//转发
          controller: this.myController,
          auto:true,
          play:true,
          index:i,
        }
        this.datas.updateDataAtIndex(i, updatedData);

      }
    } else {
      console.error('API 响应错误或数据缺失');
    }
  }

  // 列表到底部时触发
  private async onReachEnd() {
    if (this.loadingMore) return; // 避免重复加载
    this.loadingMore = true; // 设置为加载中

    await this.loadData(); // 重新加载数据

    this.loadingMore = false; // 重置加载状态
  }

  onPageShow(): void {
    this.datas.getData(this.index).controller.start();
  }

  onPageHide(): void {
    this.datas.getData(this.index).controller.pause();
  }

  build() {
    Scroll() {
      Column() {
        Text("数据库缓存视频")
          .width("100%")
          .height("10%")
          .backgroundColor('#0080DC')
          .textAlign(TextAlign.Center);
        Tabs({ barPosition: BarPosition.Start ,index: this.bottomTabIndex}) {

          TabContent() {
          }.tabBar("直播");
          TabContent() {
            List({ space: 5 }) {
              LazyForEach(this.datas, (item: VideoData, index: number) => {
                ListItem() {
                  RelativeContainer() {
                    Image(item.head)
                      .width('100%')
                      .height(130)   // 设置固定高度
                      .aspectRatio(0)
                      .objectFit(ImageFit.Cover)
                      .alignRules({
                        top: { anchor: "__container__", align: VerticalAlign.Top },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      })
                      .id("image1")


                    Text(item.description)
                      .fontSize(14)
                      .padding({ top: 10, left: 10, bottom: 10 })
                      .fontWeight(FontWeight.Normal)
                      .letterSpacing(2)
                      .lineHeight(20)
                      .maxLines(2)  // 设置最多两行
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .alignRules({
                        top: { anchor: "image1", align: VerticalAlign.Bottom },
                        left: { anchor: "image1", align: HorizontalAlign.Start }
                      });

                    Text(item.name)
                      .fontSize(12)
                      .letterSpacing(2)
                      .fontColor(Color.Gray)
                      .fontWeight(FontWeight.Normal)
                      .padding({ left: 10, bottom: 10, top: 10 })
                      .alignRules({
                        bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                        left: { anchor: "__container__", align: HorizontalAlign.Start }
                      });
                  }
                  .onClick(() => {
                    this.loadData();
                    //点击之后跳转到Videoplay
                    console.log(`视频名称: ${item.description}`);
                    console.log(`地址: ${item.head}`);
                    router.pushUrl({ url: "pages/VideoPlayer", params: { videoDatas:this.datas.getAllData(),bvidflag:item.bvid  } });
                  })
                  .borderRadius(5)
                  .width('100%')
                  .height(225)
                  .backgroundColor('#ffffff');
                }
                .borderRadius(5)
                .height(225);
              });
            }
            .onReachEnd(() => {
              this.onReachEnd()
              console.log('触底')
            })
            .cachedCount(6)
            .lanes(2, 5)
            .width("100%")
            .edgeEffect(EdgeEffect.Spring)
            // .edgeEffect(EdgeEffect.None)//听说可以防止反弹二次触发
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            });
          }.tabBar("推荐");

          TabContent() {
          }.tabBar("热门");
          TabContent() {
          }.tabBar("动画");
          TabContent() {
          }.tabBar("影视");
          TabContent() {
          }.tabBar("新征程");
          TabContent() {
          }.tabBar("#");
        }
        .padding({ left: 5, right: 5 })
        .vertical(false)
        .height("100%");
      }.width("100%");
    }
    .edgeEffect(EdgeEffect.Spring)
    .friction(0.6)
    .backgroundColor('#DCDCDC')
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%');
  }
}
