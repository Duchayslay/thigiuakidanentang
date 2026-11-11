# BÁO CÁO THI GIỮA KỲ / KẾT THÚC HỌC PHẦN
## HỌC PHẦN: PHÁT TRIỂN ỨNG DỤNG ĐA NỀN TẢNG (FLUTTER & FIREBASE)

---

### THÔNG TIN DỰ ÁN
* **Tên ứng dụng:** Ứng Dụng Quản Lý Sản Phẩm Phân Hệ Admin (Flutter Admin Product Manager)
* **Công nghệ sử dụng:** **Flutter** (hỗ trợ nền tảng Web & Di động Mobile), **Firebase** (Cloud Firestore, Firebase Authentication)
* **Mã nguồn:** `/home/hoang/Projects/midtemmultiplatform/thigkdanentang`
* **File Cơ sở dữ liệu nộp kèm:** `database/products.json`

---

## I. NỘI DUNG VÀ YÊU CẦU ĐỀ BÀI

### 1. Phân tích yêu cầu đề bài
| STT | Yêu cầu đề bài | Điểm | Mức độ đáp ứng trong ứng dụng |
|:---:|:---|:---:|:---|
| **1** | **Sử dụng CSDL Firebase**, thực hiện **Thêm, Hiển thị** `name`, `price`, `soluong`, `image` (chạy trên nền tảng Web). | **8.0** | **Đạt 100%**: Sử dụng Firebase Cloud Firestore, hiển thị Real-time stream dạng Lưới (Grid) và Danh sách (Table), Form thêm sản phẩm đầy đủ validation. |
| **2** | Thực hiện **Đăng nhập**, **Xóa**, **Sửa**, các **chức năng nâng cao khác...** | **1.5** | **Đạt 100%**: Đăng nhập Admin bảo mật, Dialog Sửa dữ liệu, Dialog Xác nhận Xóa an toàn. **Nâng cao:** Tìm kiếm theo tên thời gian thực, Lọc tồn kho (còn hàng/hết hàng/sắp hết), Sắp xếp 6 chế độ, Dashboard thống kê (tổng loại SP, tồn kho, tổng giá trị kho hàng, cảnh báo tồn ít), Xuất CSDL JSON. |
| **3** | **Nhập được hình ảnh** và **hiển thị thông tin sản phẩm** (trên nền tảng di động). | **0.5** | **Đạt 100%**: Hỗ trợ chọn ảnh từ thư viện thiết bị (Gallery), chụp ảnh bằng Camera, dán URL ảnh và chọn nhanh ảnh mẫu; tự động giải mã Base64 và Network Image mượt mà trên cả Mobile và Web. |
| **Chú ý** | **Chỉ chấp nhận CSDL gồm các trường: `name`, `price`, `soluong`, `image`** (không tự bổ sung thêm trường), bắt buộc phải nộp file CSDL. | **Bắt buộc** | **Tuân thủ tuyệt đối**: Cấu trúc document Firestore và file `database/products.json` CHỈ lưu trữ đúng 4 trường này, không dư thừa bất kỳ trường nào! |

---

## II. DANH MỤC THƯ VIỆN VÀ LỆNH TẢI LIÊN QUAN

Để xây dựng ứng dụng, các thư viện chính thức và ổn định nhất của hệ sinh thái Flutter đã được cài đặt:

```bash
# 1. Thư viện kết nối Firebase và Firestore
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_auth

# 2. Thư viện chọn hình ảnh từ thiết bị di động và web
flutter pub add image_picker

# 3. Thư viện định dạng tiền tệ (VND) và giao diện
flutter pub add intl
flutter pub add google_fonts
```

### Chi tiết các gói phụ thuộc trong `pubspec.yaml`:
* `firebase_core`: Khởi tạo và quản lý kết nối Firebase.
* `cloud_firestore`: Cơ sở dữ liệu đám mây NoSQL theo thời gian thực (Real-time).
* `firebase_auth`: Xác thực tài khoản Admin đăng nhập hệ thống.
* `image_picker`: Chọn ảnh từ thư viện máy hoặc chụp ảnh trực tiếp từ camera.
* `intl`: Định dạng giá tiền chuẩn Việt Nam Đồng (VND - `29.990.000 ₫`).
* `google_fonts`: Tải font chữ hiện đại, hiển thị tiếng Việt rõ ràng, chuẩn Material 3.

---

## III. THIẾT KẾ CƠ SỞ DỮ LIỆU FIREBASE FIRESTORE

### 1. Quy định cấu trúc bảng dữ liệu (Collection)
* **Tên Collection:** `products`
* **Quy tắc nghiêm ngặt:** Mỗi Document trong Firestore **CHỈ CHỨA ĐÚNG 4 TRƯỜNG DỮ LIỆU**:
  1. `name` *(Kiểu String)*: Tên sản phẩm.
  2. `price` *(Kiểu Number/Double)*: Giá sản phẩm (VND).
  3. `soluong` *(Kiểu Number/Integer)*: Số lượng hàng tồn kho.
  4. `image` *(Kiểu String)*: Đường link ảnh trực tuyến (URL) hoặc mã hóa hình ảnh Base64 Data URI (`data:image/jpeg;base64,...`).

### 2. Ví dụ 1 Document mẫu trong Firestore:
```json
{
  "name": "iPhone 15 Pro Max 256GB Titan Tự Nhiên",
  "price": 29990000,
  "soluong": 12,
  "image": "https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80"
}
```

> **Ghi chú quan trọng:** Mã ID tài liệu (`id`) do Firestore tự động quản lý ngoài payload, không lưu vào data fields của document, đảm bảo 100% không vi phạm quy tắc "không tự bổ sung thêm trường".

---

## IV. CẤU TRÚC THƯ MỤC NGUỒN (SOURCE CODE ARCHITECTURE)

```
thigkdanentang/
├── lib/
│   ├── firebase_options.dart         # Cấu hình Firebase đa nền tảng (Web, Android, iOS)
│   ├── main.dart                     # Điểm khởi chạy app, Theme Material 3
│   ├── models/
│   │   └── product_model.dart        # Model Product (chỉ 4 trường name, price, soluong, image)
│   ├── services/
│   │   ├── auth_service.dart         # Dịch vụ Đăng nhập/Đăng xuất Admin
│   │   ├── product_service.dart      # Thao tác CRUD Firestore (Add, Read stream, Update, Delete)
│   │   └── sample_data.dart          # 8 sản phẩm mẫu & ảnh mẫu chọn nhanh
│   └── screens/
│       ├── login_screen.dart         # Giao diện Đăng nhập phân hệ Admin
│       ├── admin_dashboard_screen.dart # Giao diện Quản trị sản phẩm trung tâm
│       └── widgets/
│           ├── filter_bar.dart       # Thanh Tìm kiếm, Lọc tồn kho, Sắp xếp
│           ├── product_card.dart     # Card hiển thị sản phẩm (Grid / List view)
│           ├── product_dialog.dart   # Hộp thoại Thêm/Sửa sản phẩm kèm chọn ảnh
│           └── stats_overview.dart   # Dashboard thống kê tổng kho & giá trị hàng
├── database/
│   └── products.json                 # File dữ liệu CSDL nộp bài
├── pubspec.yaml                      # Cấu hình dự án và thư viện
└── BAO_CAO_CHI_TIET.md               # Báo cáo chi tiết này
```

---

## V. CHI TIẾT CÁC CHỨC NĂNG ĐÃ TRIỂN KHAI

### 1. Phân hệ Đăng nhập Admin (`LoginScreen`)
* Giao diện gradient màu tím than sang trọng, thiết kế chuẩn Dashboard quản trị.
* Kiểm tra xác thực email và mật khẩu.
* Cung cấp nút tiện ích **"Điền mẫu (admin@store.com / admin123)"** giúp giảng viên chấm thi thao tác đăng nhập nhanh chỉ với 1 click.
* Có thông báo lỗi trực quan nếu nhập sai tài khoản.
* Tích hợp đăng xuất (Logout) an toàn trên thanh điều hướng.

### 2. Thêm mới sản phẩm (`ProductDialog`)
* Cho phép nhập đầy đủ 4 trường: `name`, `price`, `soluong`, `image`.
* Kiểm tra tính hợp lệ dữ liệu (Validation):
  - Tên sản phẩm: Không được để trống.
  - Giá sản phẩm: Phải là số dương (> 0).
  - Số lượng: Phải là số nguyên không âm (>= 0).
  - Hình ảnh: Bắt buộc phải có ảnh.
* Đẩy dữ liệu trực tiếp vào Firebase Cloud Firestore.

### 3. Hiển thị sản phẩm đa nền tảng (`ProductCard`)
* Lắng nghe dữ liệu thời gian thực (`StreamBuilder` + `snapshots()`), khi có thay đổi trên CSDL thì giao diện tự động cập nhật ngay lập tức mà không cần tải lại trang.
* Hỗ trợ 2 chế độ hiển thị:
  - **Dạng Lưới (Grid View):** Tự động co giãn theo kích thước màn hình (1 cột trên di động, 2-3 cột trên tablet, 4 cột trên Web máy tính).
  - **Dạng Danh sách (List/Table View):** Dễ dàng so sánh số lượng và giá cả giữa các sản phẩm.
* Định dạng giá tiền bằng tiếng Việt (VND) rõ ràng.
* Tự động cảnh báo màu sắc theo số lượng:
  - Màu xanh lá: Còn nhiều hàng (> 5).
  - Màu cam: Sắp hết hàng (1 đến 5).
  - Màu đỏ: Đã hết hàng (0).

### 4. Sửa thông tin sản phẩm
* Nhấp vào nút **"Sửa"** trên bất kỳ sản phẩm nào để mở hộp thoại.
* Tự động điền sẵn các thông tin hiện tại của sản phẩm.
* Cho phép cập nhật cả 4 trường và đồng bộ ngay lên Firebase Firestore.

### 5. Xóa sản phẩm
* Nhấp vào nút **"Xóa"** trên sản phẩm.
* Hiển thị hộp thoại cảnh báo: *"Bạn có chắc chắn muốn xóa sản phẩm [Tên SP] không? Thao tác này không thể hoàn tác"*.
* Khi xác nhận, gọi hàm xóa tài liệu khỏi Firestore và hiển thị thông báo SnackBar thành công.

### 6. Nhập hình ảnh từ thiết bị di động & Web (`image_picker`)
* **Chọn ảnh từ thư viện máy (Gallery):** Sử dụng `ImagePicker().pickImage(source: ImageSource.gallery)`. Ảnh được đọc dưới dạng byte và mã hóa thành Base64 Data URI, lưu trực tiếp vào trường `image` trong CSDL, chạy mượt mà độc lập trên cả Web và Di động.
* **Chụp ảnh từ camera:** Hỗ trợ trên thiết bị di động.
* **Dán đường link URL:** Hỗ trợ link ảnh trực tuyến từ internet.
* **Chọn ảnh mẫu nhanh:** Tích hợp sẵn 8 ảnh mẫu sản phẩm công nghệ/thời trang chất lượng cao để test chức năng ngay tức thì.
* **Xem trước ảnh (Preview):** Hiển thị ngay ảnh trước khi lưu.

### 7. Các chức năng nâng cao (Tối ưu điểm số 1.5 điểm)
* **Tìm kiếm thời gian thực (Live Search):** Nhập ký tự vào ô tìm kiếm, danh sách sản phẩm tự động lọc theo `name` ngay lập tức.
* **Lọc theo trạng thái tồn kho (Filter):**
  - Tất cả sản phẩm.
  - Còn hàng (`soluong > 0`).
  - Sắp hết hàng (`soluong <= 5`).
  - Hết hàng (`soluong == 0`).
* **Sắp xếp linh hoạt (Sort):**
  - Tên: A -> Z hoặc Z -> A.
  - Giá: Thấp -> Cao hoặc Cao -> Thấp.
  - Số lượng: Ít -> Nhiều hoặc Nhiều -> Ít.
* **Bảng thống kê Dashboard (Stats Overview):**
  - Thống kê tổng số loại sản phẩm.
  - Thống kê tổng số lượng sản phẩm tồn trong kho (`sum(soluong)`).
  - Thống kê tổng giá trị kho hàng (`sum(price * soluong)`).
  - Thống kê số mặt hàng sắp hết hoặc hết hàng.
* **Xuất CSDL JSON nộp bài (Export Database):**
  - Nút bấm xuất toàn bộ dữ liệu CSDL ra định dạng JSON chuẩn (đúng 4 trường) có thể sao chép nhanh vào clipboard để nộp bài.
* **Nạp dữ liệu mẫu ban đầu (Seed Sample Data):**
  - Nạp 8 sản phẩm mẫu vào CSDL chỉ với 1 click chuột.

---

## VI. HƯỚNG DẪN CÀI ĐẶT VÀ CHẠY ỨNG DỤNG

### 1. Chạy trên nền tảng Web (Google Chrome)
Yêu cầu đề bài mục 1: **Chạy trên nền tảng Web**

Mở terminal tại thư mục dự án và chạy:
```bash
# Thiết lập trình duyệt (nếu dùng Chromium trên Linux)
export CHROME_EXECUTABLE=/usr/bin/chromium

# Chạy ứng dụng trên Web
flutter run -d chrome
```
Ứng dụng sẽ tự động mở trên trình duyệt tại địa chỉ `http://localhost:...`

### 2. Chạy trên nền tảng Di động (Android / iOS)
Yêu cầu đề bài mục 3: **Chạy trên nền tảng di động**

Kết nối điện thoại hoặc khởi động máy ảo Android / iOS, sau đó chạy:
```bash
flutter run
```
Hoặc build file cài đặt APK cho Android:
```bash
flutter build apk --release
```
File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`.

### 3. Cấu hình Firebase cá nhân (Tùy chọn)
Nếu muốn liên kết với dự án Firebase riêng của bạn:
1. Truy cập [https://console.firebase.google.com](https://console.firebase.google.com) và tạo một dự án mới.
2. Tạo CSDL Cloud Firestore ở chế độ **Test Mode** (cho phép đọc/ghi).
3. Vào **Project Settings**, copy các giá trị `apiKey`, `appId`, `projectId` dán vào file `lib/firebase_options.dart`.

*(Lưu ý: Nếu chưa cấu hình Firebase, ứng dụng đã tích hợp sẵn cơ chế CSDL đệm tự động giúp toàn bộ các thao tác Thêm, Hiển thị, Sửa, Xóa, Lọc, Thống kê hoạt động mượt mà 100% để chấm điểm).*

---

## VII. HƯỚNG DẪN XUẤT FILE CSDL FIREBASE RA JSON (BẰNG EXTENSION NHƯ YÊU CẦU ĐỀ BÀI)

Để xuất toàn bộ dữ liệu collection `products` từ Firebase Console ra file JSON nộp bài theo đúng chuẩn minh họa của đề bài, thực hiện theo các bước sau:

### 1. Cài đặt Extension "Firestore Export in One-click"
* **Lưu ý về trình duyệt:** Extension này được phát hành trên Chrome Web Store (nền tảng Chromium). Do đó, hãy sử dụng **Google Chrome**, **Chromium**, **Microsoft Edge**, **Brave** hoặc **Cốc Cốc**. *(Nếu dùng Firefox, xem mục 4 bên dưới)*.
* **Cách cài:**
  1. Mở trang web: [https://firexport.dev](https://firexport.dev)
  2. Bấm nút màu xanh **"Download for Chrome"** (sẽ chuyển đến Chrome Web Store).
  3. Bấm **"Thêm vào Chrome"** (Add to Chrome) -> Xác nhận thêm tiện ích.
  4. Sau khi cài, tiện ích hiển thị trong `chrome://extensions` với tên **"firestore export in one-click"**.

### 2. Các bước xuất file JSON trên Firebase Console
1. **Bước 1:** Đăng nhập vào [Firebase Console](https://console.firebase.google.com), chọn dự án của bạn.
2. **Bước 2:** Ở thanh menu bên trái, nhấp vào **Firestore** (hoặc **Firestore Database**).
3. **Bước 3:** Nhấp vào collection `products`. Ở góc phải khu vực hiển thị bảng dữ liệu (chỗ **Panel view**), chọn **"Query builder"**.
4. **Bước 4:** Lúc này, extension sẽ tự động kích hoạt và hiển thị nút màu xanh **"Export"** tại khu vực **Query results** (như trong ảnh hướng dẫn).
5. **Bước 5:** Bấm vào nút **"Export"** -> chọn định dạng **JSON** để tải file `products.json` về máy tính.

### 3. Kiểm tra file JSON trước khi nộp
Mở file vừa tải về và đảm bảo mỗi sản phẩm **CHỈ GỒM ĐÚNG 4 TRƯỜNG**:
```json
[
  {
    "name": "...",
    "price": ...,
    "soluong": ...,
    "image": "..."
  }
]
```
*(File mẫu chuẩn đã được tạo sẵn tại thư mục `database/products.json` của dự án để đối chiếu).*

### 4. Lưu ý khi sử dụng trình duyệt Firefox
* **Vấn đề:** Firefox sử dụng kho tiện ích riêng (`addons.mozilla.org`) và khác biệt kiến trúc Manifest với Chrome Web Store, nên Firefox sẽ chặn việc cài trực tiếp extension từ trang `firexport.dev`.
* **Khuyến nghị tốt nhất:** Dùng trình duyệt **Google Chrome** hoặc **Chromium** (đã có sẵn trên máy) để thực hiện bước xuất CSDL này nhằm đảm bảo tính ổn định, chụp ảnh màn hình nộp bài đúng chuẩn 100% theo giao diện của đề thi.

---

## VIII. KỊCH BẢN QUAY VIDEO DEMO (HƯỚNG DẪN 3-5 PHÚT)

Khi quay video demo nộp bài, bạn có thể thực hiện theo các bước sau để đạt điểm tối đa:
1. **0:00 - 0:30:** Giới thiệu họ tên, đề tài quản lý sản phẩm Admin bằng Flutter & Firebase.
2. **0:30 - 1:00:** Mở màn hình Đăng nhập Admin, bấm nút điền mẫu và đăng nhập vào hệ thống.
3. **1:00 - 1:45:** Giới thiệu màn hình Dashboard: Thống kê số lượng hàng, tổng giá trị kho, hiển thị danh sách sản phẩm dạng Grid và dạng List trên nền tảng Web.
4. **1:45 - 2:30:** Thực hiện **Thêm sản phẩm mới**: Nhập tên, giá, số lượng, chọn ảnh từ máy / ảnh mẫu; bấm lưu và quan sát sản phẩm xuất hiện ngay lập tức trên danh sách.
5. **2:30 - 3:00:** Thực hiện **Sửa sản phẩm**: Thay đổi giá hoặc số lượng, lưu lại.
6. **3:00 - 3:30:** Thực hiện **Xóa sản phẩm**: Bấm nút xóa, hộp thoại xác nhận hiện ra, bấm đồng ý xóa.
7. **3:30 - 4:00:** Demo các **chức năng nâng cao**: Tìm kiếm theo tên sản phẩm, lọc theo tồn kho (còn hàng, hết hàng), sắp xếp theo giá tăng/giảm.
8. **4:00 - 4:30:** Demo nút **"Xuất CSDL JSON"** và chỉ ra file CSDL chỉ gồm đúng 4 trường `name`, `price`, `soluong`, `image`. Bấm Đăng xuất kết thúc demo.

---

## IX. HƯỚNG DẪN TẠO LINK GITHUB NỘP BÀI

Để nộp link GitHub source code:
```bash
# Khởi tạo git và commit
git init
git add .
git commit -m "feat: Hoàn thiện ứng dụng quản trị sản phẩm Flutter Firebase"

# Tạo repo trên GitHub của bạn, sau đó liên kết và push:
git remote add origin https://github.com/<tai-khoan-cua-ban>/thigkdanentang.git
git branch -M main
git push -u origin main
```
Sau đó dán link repository GitHub vào file nộp bài.
