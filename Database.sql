CREATE DATABASE QLSV_DoAn;
GO
USE QLSV_DoAn;
GO

/* ============================================
   1) BẢNG TRUNG TÂM: SINHVIEN
   ============================================ */
CREATE TABLE dbo.SinhVien (
    MaSV      VARCHAR(10)    NOT NULL,
    HoTen     NVARCHAR(100)  NOT NULL,
    Lop       VARCHAR(10)    NULL,
    Nganh     NVARCHAR(50)   NULL,
    Khoa      NVARCHAR(50)   NULL,
    NgaySinh  DATE           NULL,
    GioiTinh  NVARCHAR(5)    NULL,  -- Nam/Nữ
    DiaChi    NVARCHAR(200)  NULL,
    SDT       VARCHAR(15)    NULL,
    CONSTRAINT PK_SinhVien PRIMARY KEY (MaSV),
    CONSTRAINT CK_SV_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    CONSTRAINT CK_SV_SDT CHECK (SDT IS NULL OR SDT LIKE '[0-9+ -]%')
);
GO

/* ============================================
   2) HOẠT ĐỘNG ĐOÀN
   ============================================ */
CREATE TABLE dbo.HoatDongDoan (
    MaHD       VARCHAR(10)     NOT NULL,
    TenHD      NVARCHAR(100)   NOT NULL,
    NgayToChuc DATE            NULL,
    DiaDiem    NVARCHAR(100)   NULL,
    NoiDung    NVARCHAR(500)   NULL,
    CONSTRAINT PK_HoatDong PRIMARY KEY (MaHD)
);
GO

/* ============================================
   3) ĐOÀN VIÊN (PK = MaSV; đồng thời FK → SinhVien)
   ============================================ */
CREATE TABLE dbo.DoanVien (
    MaSV        VARCHAR(10)    NOT NULL,  -- PK + FK tới SinhVien
    NgayVaoDoan DATE           NULL,
    ChucVu      NVARCHAR(50)   NULL,  -- Bí thư/Phó bí thư/Ủy viên
    TrangThai   NVARCHAR(20)   NULL,  -- Đang sinh hoạt/Tạm ngưng/...
    DoanPhi     NVARCHAR(20)   NULL,  -- Đã đóng/Chưa đóng/Nợ phí/...
    NgayDong    DATE           NULL,  -- Ngày đóng đoàn phí
    CONSTRAINT PK_DoanVien PRIMARY KEY (MaSV),
    CONSTRAINT FK_DoanVien_SV
        FOREIGN KEY (MaSV) REFERENCES dbo.SinhVien(MaSV)
        ON DELETE CASCADE,
    CONSTRAINT CK_DV_ChucVu
        CHECK (ChucVu IS NULL OR ChucVu IN (N'Bí thư', N'Phó bí thư', N'Ủy viên', N'Đoàn viên')),
    CONSTRAINT CK_DV_TrangThai
        CHECK (TrangThai IS NULL OR TrangThai IN (N'Đang sinh hoạt', N'Tạm ngưng')),
    CONSTRAINT CK_DV_DoAnPhi
        CHECK (DoanPhi IS NULL OR DoanPhi IN (N'Đã đóng', N'Chưa đóng', N'Nợ phí')),
    CONSTRAINT CK_DV_NgayDong_Logic
        CHECK (NgayDong IS NULL OR DoanPhi = N'Đã đóng')
);
GO

/* ============================================
   4) THAM GIA HOẠT ĐỘNG
   ============================================ */
CREATE TABLE dbo.ThamGiaHD (
    MaSV    VARCHAR(10)    NOT NULL,   -- FK → SinhVien
    MaHD    VARCHAR(10)    NOT NULL,   -- FK → HoatDongDoan
    VaiTro  NVARCHAR(50)   NULL,       -- Thành viên/BTC/Diễn giả...
    KetQua  NVARCHAR(50)   NULL,       -- Hoàn thành/Xuất sắc/Không đạt
    CONSTRAINT PK_ThamGiaHD PRIMARY KEY (MaSV, MaHD),
    CONSTRAINT FK_TGHD_SV FOREIGN KEY (MaSV)
        REFERENCES dbo.SinhVien(MaSV) ON DELETE CASCADE,
    CONSTRAINT FK_TGHD_HD FOREIGN KEY (MaHD)
        REFERENCES dbo.HoatDongDoan(MaHD) ON DELETE CASCADE
);
GO

/* ============================================
   DỮ LIỆU MẪU CHO 15 SINH VIÊN
   ============================================ */
INSERT INTO dbo.SinhVien (MaSV, HoTen, Lop, Nganh, Khoa, NgaySinh, GioiTinh, DiaChi, SDT)
VALUES
('SV001', N'Nguyễn Văn A',  'CTK45A', N'Công nghệ thông tin', N'CNTT', '2004-01-15', N'Nam', N'Hà Nội', '0912345678'),
('SV002', N'Trần Thị B',    'CTK45A', N'Công nghệ thông tin', N'CNTT', '2004-02-20', N'Nữ',  N'Hà Nội', '0912345679'),
('SV003', N'Lê Văn C',      'CTK45B', N'Kỹ thuật dữ liệu',   N'CNTT', '2003-12-10', N'Nam', N'Hải Phòng', '0912345680'),
('SV004', N'Phạm Thị D',    'CTK45B', N'Kỹ thuật dữ Liệu',   N'CNTT', '2004-03-05', N'Nữ',  N'Hải Phòng', '0912345681'),
('SV005', N'Hoàng Văn E',   'CTK45C', N'An toàn thông tin',  N'CNTT', '2004-04-12', N'Nam', N'Hà Nam', '0912345682'),
('SV006', N'Ngô Thị F',     'CTK45C', N'An toàn thông tin',  N'CNTT', '2004-05-22', N'Nữ',  N'Hà Nam', '0912345683'),
('SV007', N'Đặng Văn G',    'CTK46A', N'An toàn thông tin',       N'CNTT', '2005-06-18', N'Nam', N'Ninh Bình', '0912345684'),
('SV008', N'Vũ Thị H',      'CTK46A', N'An toàn thông tin',       N'CNTT', '2005-07-25', N'Nữ',  N'Ninh Bình', '0912345685'),
('SV009', N'Bùi Văn I',     'CTK46B', N'Công nghệ thông tin',    N'CNTT', '2005-08-30', N'Nam', N'Thái Bình', '0912345686'),
('SV010', N'Nguyễn Thị K',  'CTK46B', N'Công nghệ thông tin',    N'CNTT', '2005-09-12', N'Nữ',  N'Thái Bình', '0912345687'),
('SV011', N'Lương Văn L',   'CTK47A', N'Công nghệ thông tin', N'CNTT', '2006-01-10', N'Nam', N'Hà Tĩnh', '0912345688'),
('SV012', N'Phan Thị M',    'CTK47A', N'Công nghệ thông tin', N'CNTT', '2006-02-11', N'Nữ',  N'Hà Tĩnh', '0912345689'),
('SV013', N'Tạ Văn N',      'CTK47B', N'Kỹ thuật dữ Liệu',   N'CNTT', '2006-03-14', N'Nam', N'Nam Định', '0912345690'),
('SV014', N'Đỗ Thị O',      'CTK47B', N'Kỹ thuật dữ Liệu',   N'CNTT', '2006-04-17', N'Nữ',  N'Nam Định', '0912345691'),
('SV015', N'Hà Văn P',      'CTK47C', N'Kỹ thuật dữ Liệu',  N'CNTT', '2006-05-20', N'Nam', N'Thanh Hóa', '0912345692');
GO

/* ============================================
   DỮ LIỆU MẪU CHO 15 ĐOÀN VIÊN (có 'Đoàn viên')
   ============================================ */
INSERT INTO dbo.DoanVien (MaSV, NgayVaoDoan, ChucVu, TrangThai, DoanPhi, NgayDong) VALUES
('SV001', '2021-03-26', N'Bí thư',      N'Đang sinh hoạt', N'Đã đóng',  '2025-03-15'),
('SV002', '2021-04-10', N'Phó bí thư',  N'Đang sinh hoạt', N'Đã đóng',  '2025-03-16'),
('SV003', '2020-10-20', N'Đoàn viên',   N'Đang sinh hoạt', N'Chưa đóng', NULL),
('SV004', '2021-02-05', N'Đoàn viên',   N'Đang sinh hoạt', N'Đã đóng',  '2025-03-20'),
('SV005', '2020-11-12', N'Đoàn viên',   N'Tạm ngưng',      N'Nợ phí',    NULL),
('SV006', '2021-05-09', N'Đoàn viên',   N'Đang sinh hoạt', N'Đã đóng',  '2025-03-22'),
('SV007', '2022-01-15', N'Đoàn viên',   N'Đang sinh hoạt', N'Chưa đóng', NULL),
('SV008', '2022-02-18', N'Đoàn viên',   N'Đang sinh hoạt', N'Đã đóng',  '2025-03-25'),
('SV009', '2022-09-01', N'Phó bí thư',  N'Đang sinh hoạt', N'Đã đóng',  '2025-04-02'),
('SV010', '2022-09-01', N'Đoàn viên',   N'Đang sinh hoạt', N'Chưa đóng', NULL),
('SV011', '2023-10-05', N'Đoàn viên',   N'Đang sinh hoạt', N'Đã đóng',  '2025-04-05'),
('SV012', '2023-10-05', N'Đoàn viên',   N'Đang sinh hoạt', N'Đã đóng',  '2025-04-08'),
('SV013', '2023-11-12', N'Đoàn viên',   N'Đang sinh hoạt', N'Nợ phí',    NULL),
('SV014', '2023-11-20', N'Đoàn viên',   N'Tạm ngưng',      N'Chưa đóng', NULL),
('SV015', '2024-01-10', N'Bí thư',      N'Đang sinh hoạt', N'Đã đóng',  '2025-04-12');
GO

/* ============================================
   DỮ LIỆU MẪU HOẠT ĐỘNG ĐOÀN
   ============================================ */

INSERT INTO dbo.HoatDongDoan (MaHD, TenHD, NgayToChuc, DiaDiem, NoiDung) VALUES
-- Các hoạt động đã diễn ra
('HD001', N'Thi tìm hiểu 26/3',     '2025-03-20', N'Hội trường A', N'Tổ chức thi tìm hiểu truyền thống Đoàn TNCS Hồ Chí Minh'),
('HD002', N'Hiến máu nhân đạo',    '2025-04-05', N'Nhà văn hóa tỉnh', N'Chương trình hiến máu tình nguyện vì cộng đồng'),
('HD003', N'Dọn vệ sinh ký túc xá','2025-04-15', N'Ký túc xá Khoa CNTT', N'Hoạt động tình nguyện vệ sinh môi trường'),
('HD004', N'Ngày hội thể thao',    '2025-05-01', N'Sân vận động trường', N'Thi đấu bóng đá, bóng chuyền, kéo co'),
('HD005', N'Hội trại 26/3',        '2025-05-10', N'Sân trường chính', N'Hội trại kỷ niệm ngày thành lập Đoàn'),

-- Các hoạt động chưa diễn ra
('HD006', N'Giao lưu doanh nghiệp CNTT', '2025-10-01', N'Hội trường B', N'Trao đổi kinh nghiệm, định hướng nghề nghiệp với doanh nghiệp CNTT'),
('HD007', N'Thi Olympic Tin học',        '2025-11-15', N'Phòng máy 305', N'Thi Olympic Tin học cho sinh viên toàn khoa'),
('HD008', N'Tình nguyện mùa đông',       '2025-12-20', N'Xã miền núi A', N'Chương trình tình nguyện hỗ trợ học sinh vùng cao'),
('HD009', N'Ngày hội việc làm CNTT',     '2026-01-05', N'Sân trường', N'Kết nối sinh viên với các doanh nghiệp CNTT'),
('HD010', N'Hội nghị Nghiên cứu khoa học sinh viên', '2026-03-15', N'Hội trường lớn', N'Báo cáo, trao đổi đề tài nghiên cứu khoa học');
GO

/* ============================================
   DỮ LIỆU MẪU THAM GIA HOẠT ĐỘNG
   ============================================ */
-- HD001: Thi tìm hiểu 26/3
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV001', 'HD001', N'BTC',         N'Hoàn thành'),
('SV002', 'HD001', N'Thành viên',  N'Xuất sắc'),
('SV003', 'HD001', N'Thành viên',  N'Hoàn thành'),
('SV004', 'HD001', N'Thành viên',  N'Không đạt');

-- HD002: Hiến máu nhân đạo
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV005', 'HD002', N'Thành viên',  N'Hoàn thành'),
('SV006', 'HD002', N'Thành viên',  N'Hoàn thành'),
('SV007', 'HD002', N'BTC',         N'Hoàn thành'),
('SV008', 'HD002', N'Thành viên',  N'Hoàn thành');

-- HD003: Dọn vệ sinh ký túc xá
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV009', 'HD003', N'Thành viên',  N'Xuất sắc'),
('SV010', 'HD003', N'Thành viên',  N'Hoàn thành'),
('SV011', 'HD003', N'BTC',         N'Hoàn thành');

-- HD004: Ngày hội thể thao
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV012', 'HD004', N'Vận động viên', N'Xuất sắc'),
('SV013', 'HD004', N'Vận động viên', N'Hoàn thành'),
('SV014', 'HD004', N'Cổ động viên',  N'Hoàn thành');

-- HD005: Hội trại 26/3
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV015', 'HD005', N'BTC',         N'Hoàn thành'),
('SV001', 'HD005', N'Thành viên',  N'Xuất sắc'),
('SV002', 'HD005', N'Thành viên',  N'Hoàn thành'),
('SV003', 'HD005', N'Thành viên',  N'Hoàn thành');

-- HD006: Giao lưu doanh nghiệp CNTT (chưa diễn ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV004', 'HD006', N'Thành viên', NULL),
('SV007', 'HD006', N'Thành viên', NULL),
('SV010', 'HD006', N'BTC', NULL);

-- HD007: Thi Olympic Tin học (chưa diễn ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV002', 'HD007', N'Thành viên', NULL),
('SV005', 'HD007', N'Thành viên', NULL),
('SV009', 'HD007', N'BTC', NULL);

-- HD008: Tình nguyện mùa đông (chưa diễn ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV006', 'HD008', N'Thành viên', NULL),
('SV012', 'HD008', N'Thành viên', NULL),
('SV015', 'HD008', N'BTC', NULL);

-- HD009: Ngày hội việc làm CNTT (chưa diễn ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV001', 'HD009', N'Thành viên', NULL),
('SV008', 'HD009', N'Thành viên', NULL),
('SV013', 'HD009', N'Cộng tác viên', NULL);

-- HD010: Hội nghị NCKH sinh viên (chưa diễn ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('SV003', 'HD010', N'Báo cáo viên', NULL),
('SV011', 'HD010', N'Thành viên', NULL),
('SV014', 'HD010', N'Thành viên', NULL);
GO
