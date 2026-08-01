# -*- coding: UTF-8 -*-
import tkinter
from tkinter import ttk, Canvas
from tkinter.simpledialog import askinteger
from tkinter.filedialog import askopenfilename
from tkinter.messagebox import showinfo, showwarning, showerror
from PIL import Image, ImageTk
import cv2
import numpy as np
from ultralytics import YOLO
from collections import defaultdict
import threading
import time
import os

# -------------------------- 全局变量定义 --------------------------
picSize = 500                     # 图像显示尺寸
img_open = None                   # 原始图像/视频帧
img_result = None                 # 处理后的结果图像
model = None                      # YOLO模型（全局复用，只加载一次）
lane_left_roi = []                # 左侧车道多边形顶点
lane_right_roi = []               # 右侧车道多边形顶点
roi_current_image_hash = ""       # 当前ROI对应的图片标识（切换图片后自动失效）
vehicle_count_left = 0            # 左侧车道计数
vehicle_count_right = 0           # 右侧车道计数
track_history = defaultdict(lambda: [])  # 车辆轨迹
all_car_ids = set()               # 所有出现过的车辆ID
video_playing = False             # 视频播放状态
video_cap = None                  # 视频捕获对象
video_thread = None               # 视频处理线程
video_canvas = None               # 视频显示画布
video_window = None               # 视频弹窗

# -------------------------- UI 组件--------------------------
root = tkinter.Tk()
root.title("交通流量识别系统")
root.geometry("1200x800")

# 原始图像显示区域
title_original = tkinter.StringVar(value='原始图像（请先点击"1打开图片"）')
label_original = tkinter.Label(root, bg='gray86', textvariable=title_original)
label_original.place(relx=0.25, rely=0.40, width=picSize, height=picSize, anchor=tkinter.CENTER)
# 结果图像显示区域
title_result = tkinter.StringVar(value="处理结果图")
label_result = tkinter.Label(root, bg='gray86', textvariable=title_result)
label_result.place(relx=0.75, rely=0.40, width=picSize, height=picSize, anchor=tkinter.CENTER)

# -------------------------- 辅助函数 --------------------------
def cv_imread(filename, colorMode=1):
    """支持中文路径读取图像"""
    return cv2.imdecode(np.fromfile(filename, dtype=np.uint8), colorMode)

def calc_iou(box1, box2):
    """计算两个矩形框的IoU"""
    x1_1, y1_1, x2_1, y2_1 = box1
    x1_2, y1_2, x2_2, y2_2 = box2
    inter_x1 = max(x1_1, x1_2)
    inter_y1 = max(y1_1, y1_2)
    inter_x2 = min(x2_1, x2_2)
    inter_y2 = min(y2_1, y2_2)
    if inter_x2 <= inter_x1 or inter_y2 <= inter_y1:
        return 0.0
    inter_area = (inter_x2 - inter_x1) * (inter_y2 - inter_y1)
    area1 = (x2_1 - x1_1) * (y2_1 - y1_1)
    area2 = (x2_2 - x1_2) * (y2_2 - y1_2)
    union_area = area1 + area2 - inter_area
    return inter_area / union_area if union_area > 0 else 0.0

def is_box_in_roi(xyxy, roi_points, thresh=3):
    """
    判断检测框是否属于ROI区域（多关键点投票）
    xyxy: [x1,y1,x2,y2]
    thresh: 至少几个关键点在区域内
    """
    if not roi_points:
        return False
    x1, y1, x2, y2 = xyxy
    points = [
        (x1, y1), (x2, y1),
        (x1, y2), (x2, y2),
        ((x1 + x2) // 2, (y1 + y2) // 2)
    ]
    roi_np = np.array(roi_points, np.int32)
    inside_cnt = 0
    for (x, y) in points:
        if cv2.pointPolygonTest(roi_np, (x, y), False) >= 0:
            inside_cnt += 1
    return inside_cnt >= thresh

def reset_traffic_stat():
    """重置所有统计变量（每次检测前调用）"""
    global vehicle_count_left, vehicle_count_right, track_history, all_car_ids
    vehicle_count_left = 0
    vehicle_count_right = 0
    track_history.clear()
    all_car_ids.clear()

# -------------------------- YOLO 模型初始化（仅在最开始加载一次） --------------------------
def init_yolo_model():
    """启动时加载YOLO模型，全局只执行一次"""
    global model
    weight_path = askopenfilename(
        title="选择YOLO权重文件（仅需选择一次）",
        filetypes=[("YOLO权重文件", "*.pt"), ("所有文件", "*.*")]
    )
    if not weight_path:
        showwarning(title='警告', message='未选择权重文件！将尝试使用默认 yolov11n.pt')
        weight_path = "yolov11n.pt"

    try:
        model = YOLO(weight_path)
        if model.names:
            showinfo(title='提示', message=f'YOLO模型加载成功！\n支持 {len(model.names)} 类检测\n权重文件：{weight_path}')
            return True
        else:
            raise Exception("模型类别列表为空")
    except Exception as e:
        showerror(title='错误', message=f'模型加载失败：{str(e)}\n请重新启动程序！')
        model = None
        return False

# -------------------------- 鼠标标定 ROI --------------------------
class ROISelector:
    """鼠标交互式选择ROI区域"""
    def __init__(self, root, img, roi_type="左侧车道"):
        self.root = root
        self.img = img.copy()
        self.roi_type = roi_type
        self.points = []
        self.window = tkinter.Toplevel(root)
        self.window.title(f"选择{self.roi_type}区域（点击选点，按Enter确认，Esc取消）")
        self.window.update()

        h, w = self.img.shape[:2]
        self.scale = min(800 / max(h, w), 1.0)
        self.img_resized = cv2.resize(self.img, (int(w * self.scale), int(h * self.scale)))
        self.img_tk = self.cv2_to_tk(self.img_resized)

        self.canvas = Canvas(self.window, width=self.img_resized.shape[1], height=self.img_resized.shape[0])
        self.canvas.pack()
        self.canvas.create_image(0, 0, anchor=tkinter.NW, image=self.img_tk, tags="roi_bg")
        self.canvas.bg_img = self.img_tk

        self.canvas.bind("<Button-1>", self.on_click)
        self.window.bind("<Return>", self.on_confirm)
        self.window.bind("<Escape>", self.on_cancel)

        self.window.grab_set()
        self.window.wait_window()

    def cv2_to_tk(self, img):
        if len(img.shape) == 3:
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img)
        return ImageTk.PhotoImage(image=img_pil)

    def on_click(self, event):
        x = int(event.x / self.scale)
        y = int(event.y / self.scale)
        self.points.append([x, y])
        self.canvas.create_oval(event.x - 3, event.y - 3, event.x + 3, event.y + 3, fill="red", width=2, tags="roi_draw")
        if len(self.points) > 1:
            prev_x = int(self.points[-2][0] * self.scale)
            prev_y = int(self.points[-2][1] * self.scale)
            self.canvas.create_line(prev_x, prev_y, event.x, event.y, fill="red", width=2, tags="roi_draw")

    def on_confirm(self, event=None):
        if len(self.points) < 3:
            showwarning(title='警告', message='至少选择3个顶点！')
            return
        self.window.destroy()

    def on_cancel(self, event=None):
        self.points = []
        self.window.destroy()

def set_lane_roi():
    """交互式设置双向车道ROI"""
    global lane_left_roi, lane_right_roi, roi_current_image_hash, img_open
    if img_open is None:
        showwarning(title='警告', message='请先打开参考图像（视频第一帧或待检测图片）！')
        return

    selector_left = ROISelector(root, img_open, "左侧车道")
    lane_left_roi = selector_left.points
    if not lane_left_roi:
        showwarning(title='警告', message='左侧车道区域选择取消！')
        lane_right_roi = []
        roi_current_image_hash = ""
        return

    selector_right = ROISelector(root, img_open, "右侧车道")
    lane_right_roi = selector_right.points
    if not lane_right_roi:
        showwarning(title='警告', message='右侧车道区域选择取消！')
        lane_left_roi = []
        roi_current_image_hash = ""
        return

    # 记录当前ROI对应的图片标识（用图片数据hash保证唯一性）
    roi_current_image_hash = str(hash(img_open.tobytes()))
    showinfo(title='提示',
             message=f'双向车道检测区域设置完成！\n左侧车道顶点数：{len(lane_left_roi)}\n右侧车道顶点数：{len(lane_right_roi)}')

# -------------------------- 图像显示函数 --------------------------
def placePic1(img_show, text1="原始图像"):
    """在左侧标签显示图像"""
    global label_original, title_original
    if img_show is None:
        showwarning(title='警告', message='未打开图片！')
        return
    img = img_show.copy()
    if len(img.shape) > 2:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    h, w = img.shape[:2]
    scale = max(w, h) / picSize
    new_w = int(w / scale)
    new_h = int(h / scale)
    img_resized = cv2.resize(img, (new_w, new_h))
    img_pil = Image.fromarray(img_resized)
    img_tk = ImageTk.PhotoImage(image=img_pil)

    title_original.set(text1)
    label_original.config(image=img_tk)
    label_original.image = img_tk

def placePic2(img_show, text2="处理结果图", RGB=True):
    """在右侧标签显示结果图像"""
    global label_result, title_result, img_result
    if img_show is None:
        showwarning(title='警告', message='没有结果图片！')
        return
    img = img_show.copy()
    if len(img.shape) > 2 and RGB:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    h, w = img.shape[:2]
    scale = max(w, h) / picSize
    new_w = int(w / scale)
    new_h = int(h / scale)
    img_resized = cv2.resize(img, (new_w, new_h))
    img_pil = Image.fromarray(img_resized)
    img_tk = ImageTk.PhotoImage(image=img_pil)

    title_result.set(text2)
    label_result.config(image=img_tk)
    label_result.image = img_tk
    img_result = img_show

# -------------------------- 图片车流量识别 --------------------------
def traffic_flow_image():
    """单张图片车流量统计 —— 框选车辆、分配ID、标注车道归属"""
    global img_open, img_result, model
    global lane_left_roi, lane_right_roi
    global vehicle_count_left, vehicle_count_right

    try:
        reset_traffic_stat()

        # 1. 检查图片是否已打开
        if img_open is None:
            showwarning(title='警告', message='请先打开待检测图片！')
            return

        # 2. 检查模型是否已加载（启动时已加载，这里做二次确认）
        if model is None:
            showerror(title='错误', message='YOLO模型未加载！请重新启动程序。')
            return

        # 3. 检查ROI是否与当前图片匹配
        current_hash = str(hash(img_open.tobytes()))
        roi_matches = (lane_left_roi and lane_right_roi
                       and roi_current_image_hash
                       and roi_current_image_hash == current_hash)

        if not roi_matches:
            if lane_left_roi and lane_right_roi:
                # ROI存在但不匹配当前图片 -> 提示重新设置
                showwarning(title='警告', message='请重新选取图片并设置车道区域')
                return
            else:
                # 完全没有ROI -> 引导设置
                set_lane_roi()
                if not lane_left_roi or not lane_right_roi:
                    showwarning(title='警告', message='车道区域未设置，无法进行流量统计！')
                    return

        # 4. 执行YOLO检测
        vehicle_classes = [2, 3, 5, 7]   # car, motorcycle, bus, truck

        results = model.predict(
            img_open,
            device="cpu",
            conf=0.35,
            iou=0.45,
            classes=vehicle_classes,
            verbose=False
        )

        # 5. 初始化结果图像（在原图上绘制）
        img_result = img_open.copy()

        # 6. 处理检测结果 —— 分配ID、框选、标注
        car_id = 0                              # 自增车辆ID
        det_box_cache = []                       # 用于IoU去重
        vehicle_list = []                        # 存储每辆车的完整信息

        # 颜色定义
        COLOR_LEFT = (0, 255, 0)                 # 左车道：绿色
        COLOR_RIGHT = (255, 0, 0)               # 右车道：蓝色
        COLOR_NONE = (128, 128, 128)            # 无归属：灰色
        COLOR_BOX = (255, 140, 0)               # 框颜色：橙色
        COLOR_TEXT = (255, 255, 255)            # 文字颜色：白色

        for r in results:
            boxes = r.boxes
            if boxes is None:
                continue

            # 统一提取张量到numpy
            try:
                xyxy_array = boxes.xyxy.cpu().numpy() if boxes.xyxy is not None else np.array([])
                cls_array = boxes.cls.cpu().numpy() if boxes.cls is not None else np.array([])
            except Exception:
                continue

            num_boxes = len(xyxy_array)
            if num_boxes == 0:
                continue

            for i in range(num_boxes):
                try:
                    x1, y1, x2, y2 = map(int, xyxy_array[i])
                    cls_id = int(cls_array[i])
                except Exception:
                    continue

                current_box = [x1, y1, x2, y2]

                # IoU去重
                is_dup = False
                for cache_box in det_box_cache:
                    if calc_iou(current_box, cache_box) > 0.5:
                        is_dup = True
                        break
                if is_dup:
                    continue
                det_box_cache.append(current_box)

                # 分配唯一ID
                car_id += 1

                # 判断归属车道
                center_x = (x1 + x2) // 2
                center_y = (y1 + y2) // 2
                box_w = x2 - x1
                box_h = y2 - y1

                in_left = is_box_in_roi(current_box, lane_left_roi)
                in_right = is_box_in_roi(current_box, lane_right_roi)

                if in_left:
                    lane_label = "Left"
                    lane_color = COLOR_LEFT
                    vehicle_count_left += 1
                elif in_right:
                    lane_label = "Right"
                    lane_color = COLOR_RIGHT
                    vehicle_count_right += 1
                else:
                    lane_label = "None"
                    lane_color = COLOR_NONE

                class_name = model.names.get(cls_id, str(cls_id))

                # 记录车辆信息
                vehicle_list.append({
                    "id": car_id,
                    "class": class_name,
                    "lane": lane_label,
                    "box": current_box
                })

                # ===== 绘制检测框=====
                # 1) 矩形框
                cv2.rectangle(img_result, (x1, y1), (x2, y2), COLOR_BOX, 2)

                # 2) 标签背景
                label_text = f"ID:{car_id} {class_name}"
                (tw, th), _ = cv2.getTextSize(label_text, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2)
                label_y1 = max(y1 - th - 8, 0)
                label_y2 = y1
                cv2.rectangle(img_result, (x1, label_y1), (x1 + tw + 6, label_y2), COLOR_BOX, -1)
                cv2.putText(
                    img_result, label_text,
                    (x1 + 3, y1 - 6), cv2.FONT_HERSHEY_SIMPLEX, 0.6, COLOR_TEXT, 2
                )

                # 3) 中心点（区分车道颜色）
                cv2.circle(img_result, (center_x, center_y), 5, lane_color, -1)
                cv2.circle(img_result, (center_x, center_y), 7, lane_color, 2)

        # 7. 绘制ROI区域到结果图
        if lane_left_roi:
            pts_left = np.array(lane_left_roi, np.int32)
            cv2.polylines(img_result, [pts_left], True, (0, 255, 0), 2)

        if lane_right_roi:
            pts_right = np.array(lane_right_roi, np.int32)
            cv2.polylines(img_result, [pts_right], True, (255, 0, 0), 2)

        # 8. 顶部信息栏（使用英文，避免 cv2.putText 中文显示为问号）
        info_lines = [
            f"Total: {car_id} vehicles",
            f"Left: {vehicle_count_left} | Right: {vehicle_count_right}",
            f"conf=0.35 | iou=0.45"
        ]
        y_offset = 30
        for line in info_lines:
            cv2.putText(img_result, line, (10, y_offset),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 0), 2)
            y_offset += 28

        # 9. 显示结果图像到右侧面板
        placePic2(img_result, "Traffic Flow Result")

        # 10. 弹窗显示统计结果
        total_all_car = len(det_box_cache)
        result_text = (
            f"图片车流量统计结果：\n\n"
            f"左侧车道机动车数量：{vehicle_count_left} 辆\n"
            f"右侧车道机动车数量：{vehicle_count_right} 辆\n"
            f"图片内全部机动车总数：{total_all_car} 辆\n\n"
            f"识别类别：小汽车/摩托车/客车/货车\n"
            f"检测参数：置信度0.35  IOU0.45"
        )
        showinfo(title='交通流量统计', message=result_text)

    except Exception as e:
        import traceback
        traceback.print_exc()
        showerror(title='错误', message=f'图片识别过程发生异常：{str(e)}')

# -------------------------- 视频处理相关函数 --------------------------
def create_video_window():
    global video_window, video_canvas
    video_window = tkinter.Toplevel(root)
    video_window.title("视频车流量检测")
    video_window.geometry("800x600")

    video_canvas = Canvas(video_window, bg="black")
    video_canvas.pack(fill=tkinter.BOTH, expand=True)

    btn_stop = ttk.Button(video_window, text="停止检测", command=stop_video_process)
    btn_stop.pack(side=tkinter.BOTTOM, pady=10)
    video_window.protocol("WM_DELETE_WINDOW", stop_video_process)

def update_video_frame(frame):
    global video_canvas
    if video_canvas is None or frame is None:
        return
    h, w = frame.shape[:2]
    canvas_w = video_canvas.winfo_width()
    canvas_h = video_canvas.winfo_height()
    if canvas_w < 10 or canvas_h < 10:
        return
    scale = min(canvas_w / w, canvas_h / h)
    new_w = int(w * scale)
    new_h = int(h * scale)
    frame_resized = cv2.resize(frame, (new_w, new_h))
    frame_rgb = cv2.cvtColor(frame_resized, cv2.COLOR_BGR2RGB)
    img_pil = Image.fromarray(frame_rgb)
    img_tk = ImageTk.PhotoImage(image=img_pil)
    video_canvas.tk_img_cache = img_tk
    video_canvas.delete("video_img")
    video_canvas.create_image((canvas_w - new_w) // 2, (canvas_h - new_h) // 2,
                              anchor=tkinter.NW, image=img_tk, tags="video_img")

def process_video_frames(video_path, skip_frame):
    global video_playing, vehicle_count_left, vehicle_count_right, track_history, video_cap, all_car_ids, model
    vehicle_classes = [2, 3, 5, 7]
    car_status = dict()
    vehicle_count_left = 0
    vehicle_count_right = 0
    frame_count = 0

    video_cap = cv2.VideoCapture(video_path)
    if not video_cap.isOpened():
        showerror(title='错误', message='视频文件无法打开！')
        return

    video_playing = True
    while video_playing and video_cap.isOpened():
        ret, frame = video_cap.read()
        if not ret:
            break
        frame_count += 1
        frame_draw = frame.copy()

        results = model.track(
            frame, persist=False, conf=0.35, iou=0.45,
            classes=vehicle_classes, device="cpu", imgsz=960,
            verbose=False
        )

        draw_flag = (frame_count % skip_frame == 0)

        if results[0].boxes is not None and results[0].boxes.id is not None:
            boxes = results[0].boxes
            track_ids = boxes.id.cpu().numpy().astype(int)
            xyxy_array = boxes.xyxy.cpu().numpy()
            cls_array = boxes.cls.cpu().numpy().astype(int)

            for i in range(len(track_ids)):
                track_id = track_ids[i]
                all_car_ids.add(track_id)

                cls = int(cls_array[i])
                x1, y1, x2, y2 = map(int, xyxy_array[i])
                center_x = (x1 + x2) // 2
                center_y = (y1 + y2) // 2
                box_xyxy = [x1, y1, x2, y2]

                if track_id not in car_status:
                    car_status[track_id] = {"lane": None, "counted_left": False, "counted_right": False}

                in_left = is_box_in_roi(box_xyxy, lane_left_roi)
                in_right = is_box_in_roi(box_xyxy, lane_right_roi)
                current_lane = "left" if in_left else ("right" if in_right else None)
                car_status[track_id]["lane"] = current_lane

                if current_lane == "left" and not car_status[track_id]["counted_left"]:
                    vehicle_count_left += 1
                    car_status[track_id]["counted_left"] = True
                if current_lane == "right" and not car_status[track_id]["counted_right"]:
                    vehicle_count_right += 1
                    car_status[track_id]["counted_right"] = True

                track_history[track_id].append((center_x, center_y))
                if len(track_history[track_id]) > 60:
                    track_history[track_id].pop(0)

                if draw_flag:
                    cv2.rectangle(frame_draw, (x1, y1), (x2, y2), (255, 0, 0), 2)
                    class_name = model.names.get(cls, str(cls))
                    cv2.putText(
                        frame_draw, f"{class_name}_ID:{track_id}",
                        (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 0, 0), 2
                    )
                    if current_lane == "left":
                        cv2.circle(frame_draw, (center_x, center_y), 5, (0, 255, 0), -1)
                    elif current_lane == "right":
                        cv2.circle(frame_draw, (center_x, center_y), 5, (255, 0, 0), -1)

        del_ids = [tid for tid in list(track_history.keys()) if len(track_history[tid]) == 0]
        for tid in del_ids:
            del track_history[tid]
            if tid in car_status:
                del car_status[tid]

        root.after(1, lambda f=frame_draw: update_video_frame(f))
        time.sleep(0.005)

    video_playing = False
    if video_cap:
        video_cap.release()

    total_all_vehicle = len(all_car_ids)
    result_text = (
        f"视频全程完整车流量统计：\n"
        f"左侧车道首次驶入车辆：{vehicle_count_left} 辆\n"
        f"右侧车道首次驶入车辆：{vehicle_count_right} 辆\n"
        f"视频从头到尾所有出现过的机动车总数量：{total_all_vehicle} 辆\n\n"
        f"说明：\n"
        f"1. 总数量 = 视频全程出现过的所有不同车辆，往返车辆只统计1次；\n"
        f"2. 左/右车道计数：车辆第一次驶入该车道时统计；\n"
        f"3. 跳帧间隔：{skip_frame}，置信度0.35，输入分辨率960"
    )
    showinfo(title='视频完整车流统计结果', message=result_text)

    if video_window:
        video_window.destroy()

def stop_video_process():
    global video_playing, video_cap, video_thread
    video_playing = False
    if video_cap:
        video_cap.release()
    if video_thread and video_thread.is_alive():
        video_thread.join(timeout=2)
    if video_window:
        try:
            video_window.destroy()
        except Exception:
            pass
    reset_traffic_stat()

def traffic_flow_video():
    global video_thread, img_open, model

    reset_traffic_stat()

    if model is None:
        showerror(title='错误', message='YOLO模型未加载！请重新启动程序。')
        return

    video_path = askopenfilename(
        title="选择待检测视频",
        filetypes=[("视频文件", "*.mp4 *.avi *.mov"), ("所有文件", "*.*")]
    )
    if not video_path:
        showwarning(title='警告', message='未选择视频文件！')
        return

    skip_frame = askinteger(
        title="视频处理参数",
        prompt="跳帧间隔(1=最高精度，推荐1-5)",
        initialvalue=1, minvalue=1
    )
    if skip_frame is None:
        skip_frame = 1

    cap_temp = cv2.VideoCapture(video_path)
    ret, first_frame = cap_temp.read()
    cap_temp.release()
    if not ret:
        showerror(title='错误', message='视频无有效帧！')
        return
    img_open = first_frame

    if not lane_left_roi or not lane_right_roi:
        set_lane_roi()
        if not lane_left_roi or not lane_right_roi:
            showwarning(title='警告', message='车道区域未设置，无法进行视频统计！')
            return

    create_video_window()
    video_thread = threading.Thread(target=process_video_frames, args=(video_path, skip_frame))
    video_thread.daemon = True
    video_thread.start()

# -------------------------- 按钮及主界面 --------------------------
def test_open_pic():
    global img_open, roi_current_image_hash
    path = askopenfilename(title="打开图片")
    if path:
        img_open = cv_imread(path)
        placePic1(img_open, "原始图像")
        # 更换图片后清空ROI，强制用户重新设置车道区域
        global lane_left_roi, lane_right_roi
        lane_left_roi = []
        lane_right_roi = []
        roi_current_image_hash = ""

# 按钮
btn_open = tkinter.Button(root, text="1打开图片", command=test_open_pic)
btn_open.place(relx=0.1, rely=0.8, width=120, height=40)

btn_set_roi = tkinter.Button(root, text="2设置车道区域", command=set_lane_roi)
btn_set_roi.place(relx=0.25, rely=0.8, width=120, height=40)

btn_image = tkinter.Button(root, text="3图片车流量识别", command=traffic_flow_image)
btn_image.place(relx=0.4, rely=0.8, width=120, height=40)

btn_video = tkinter.Button(root, text="4视频完整车流统计", command=traffic_flow_video)
btn_video.place(relx=0.55, rely=0.8, width=120, height=40)

# ==================== 启动时加载YOLO模型（仅此一次） ====================
if not init_yolo_model():
    showwarning(title='警告', message='模型加载失败，部分功能不可用。请重新启动程序。')

root.mainloop()
