CREATE DATABASE QLSV_DoAn;
GO
USE QLSV_DoAn;
GO

/* ============================================
   1) BANG TRUNG TAM: SINHVIEN
   ============================================ */
CREATE TABLE dbo.SinhVien (
    MaSV      VARCHAR(10)    NOT NULL,
    HoTen     NVARCHAR(100)  NOT NULL,
	NgaySinh  DATE           NULL,
    GioiTinh  NVARCHAR(5)    NULL,  -- Nam/Nu
    Lop       VARCHAR(10)    NULL,
    Nganh     NVARCHAR(50)   NULL,
    Khoa      NVARCHAR(50)   NULL,
    DiaChi    NVARCHAR(200)  NULL,
    SDT       VARCHAR(15)    NULL,
    CONSTRAINT PK_SinhVien PRIMARY KEY (MaSV),
    CONSTRAINT CK_SV_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nu')),
    CONSTRAINT CK_SV_SDT CHECK (SDT IS NULL OR SDT LIKE '[0-9+ -]%')
);
GO

/* ============================================
   2) HOAT DONG DOAN
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
   3) DOAN VIEN (PK = MaSV; dong thoi FK → SinhVien)
   ============================================ */
CREATE TABLE dbo.DoanVien (
    MaSV        VARCHAR(10)    NOT NULL,  -- PK + FK toi SinhVien
    NgayVaoDoan DATE           NULL,
    ChucVu      NVARCHAR(50)   NULL,  -- Bi thu/Pho bi thu/Uy vien/Doan vien
    TrangThai   NVARCHAR(20)   NULL,  -- Dang sinh hoat/Tam ngung
    DoanPhi     NVARCHAR(20)   NULL,  -- Da dong/Chua dong/No phi
    NgayDong    DATE           NULL,  -- Ngay dong doan phi
    CONSTRAINT PK_DoanVien PRIMARY KEY (MaSV),
    CONSTRAINT FK_DoanVien_SV
        FOREIGN KEY (MaSV) REFERENCES dbo.SinhVien(MaSV)
        ON DELETE CASCADE,
    CONSTRAINT CK_DV_ChucVu
        CHECK (ChucVu IS NULL OR ChucVu IN (N'Bi thu', N'Pho bi thu', N'Uy vien', N'Doan vien')),
    CONSTRAINT CK_DV_TrangThai
        CHECK (TrangThai IS NULL OR TrangThai IN (N'Dang sinh hoat', N'Tam ngung')),
    CONSTRAINT CK_DV_DoAnPhi
        CHECK (DoanPhi IS NULL OR DoanPhi IN (N'Da dong', N'Chua dong', N'No phi')),
    CONSTRAINT CK_DV_NgayDong_Logic
        CHECK (NgayDong IS NULL OR DoanPhi = N'Da dong')
);
GO

/* ============================================
   4) THAM GIA HOAT DONG
   ============================================ */
CREATE TABLE dbo.ThamGiaHD (
    MaSV    VARCHAR(10)    NOT NULL,   -- FK → SinhVien
    MaHD    VARCHAR(10)    NOT NULL,   -- FK → HoatDongDoan
    VaiTro  NVARCHAR(50)   NULL,       -- Thanh vien/BTC/Dien gia/...
    KetQua  NVARCHAR(50)   NULL,       -- Hoan thanh/Xuat sac/Khong dat
    CONSTRAINT PK_ThamGiaHD PRIMARY KEY (MaSV, MaHD),
    CONSTRAINT FK_TGHD_SV FOREIGN KEY (MaSV)
        REFERENCES dbo.SinhVien(MaSV) ON DELETE CASCADE,
    CONSTRAINT FK_TGHD_HD FOREIGN KEY (MaHD)
        REFERENCES dbo.HoatDongDoan(MaHD) ON DELETE CASCADE
);
GO

/* ============================================
   DU LIEU MAU CHO 15 SINH VIEN
   ============================================ */
INSERT INTO dbo.SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, Lop, Nganh, Khoa, DiaChi, SDT)
VALUES
('23110001', N'Nguyen Van A',  '2004-01-15', N'Nam', 'CTK45A', N'Cong nghe thong tin', N'CNTT', N'Ha Noi',     '0912345678'),
('23110002', N'Tran Thi B',    '2004-02-20', N'Nu',  'CTK45A', N'Cong nghe thong tin', N'CNTT', N'Ha Noi',     '0912345679'),

('23133001', N'Le Van C',      '2003-12-10', N'Nam', 'CTK45B', N'Ky thuat du lieu',    N'CNTT', N'Hai Phong',  '0912345680'),
('23133002', N'Pham Thi D',    '2004-03-05', N'Nu',  'CTK45B', N'Ky thuat du lieu',    N'CNTT', N'Hai Phong',  '0912345681'),

('23162001', N'Hoang Van E',   '2004-04-12', N'Nam', 'CTK45C', N'An toan thong tin',   N'CNTT', N'Ha Nam',     '0912345682'),
('23162002', N'Ngo Thi F',     '2004-05-22', N'Nu',  'CTK45C', N'An toan thong tin',   N'CNTT', N'Ha Nam',     '0912345683'),

('24162001', N'Dang Van G',    '2005-06-18', N'Nam', 'CTK46A', N'An toan thong tin',   N'CNTT', N'Ninh Binh',  '0912345684'),
('24162002', N'Vu Thi H',      '2005-07-25', N'Nu',  'CTK46A', N'An toan thong tin',   N'CNTT', N'Ninh Binh',  '0912345685'),

('24110001', N'Bui Van I',     '2005-08-30', N'Nam', 'CTK46B', N'Cong nghe thong tin', N'CNTT', N'Thai Binh',  '0912345686'),
('24110002', N'Nguyen Thi K',  '2005-09-12', N'Nu',  'CTK46B', N'Cong nghe thong tin', N'CNTT', N'Thai Binh',  '0912345687'),

('25110001', N'Luong Van L',   '2006-01-10', N'Nam', 'CTK47A', N'Cong nghe thong tin', N'CNTT', N'Ha Tinh',    '0912345688'),
('25110002', N'Phan Thi M',    '2006-02-11', N'Nu',  'CTK47A', N'Cong nghe thong tin', N'CNTT', N'Ha Tinh',    '0912345689'),

('25133001', N'Ta Van N',      '2006-03-14', N'Nam', 'CTK47B', N'Ky thuat du lieu',    N'CNTT', N'Nam Dinh',   '0912345690'),
('25133002', N'Do Thi O',      '2006-04-17', N'Nu',  'CTK47B', N'Ky thuat du lieu',    N'CNTT', N'Nam Dinh',   '0912345691'),
('25133003', N'Ha Van P',      '2006-05-20', N'Nam', 'CTK47C', N'Ky thuat du lieu',    N'CNTT', N'Thanh Hoa',  '0912345692');
GO


/* ============================================
   DU LIEU MAU CHO 15 DOAN VIEN (co 'Doan vien')
   ============================================ */
INSERT INTO dbo.DoanVien (MaSV, NgayVaoDoan, ChucVu, TrangThai, DoanPhi, NgayDong) VALUES
('23110001', '2021-03-26', N'Bi thu',      N'Dang sinh hoat', N'Da dong',  '2025-03-15'),
('23110002', '2021-04-10', N'Pho bi thu',  N'Dang sinh hoat', N'Da dong',  '2025-03-16'),
('23133001', '2020-10-20', N'Doan vien',   N'Dang sinh hoat', N'Chua dong', NULL),
('23133002', '2021-02-05', N'Doan vien',   N'Dang sinh hoat', N'Da dong',  '2025-03-20'),
('23162001', '2020-11-12', N'Doan vien',   N'Tam ngung',      N'No phi',    NULL),
('23162002', '2021-05-09', N'Doan vien',   N'Dang sinh hoat', N'Da dong',  '2025-03-22'),
('24162001', '2022-01-15', N'Doan vien',   N'Dang sinh hoat', N'Chua dong', NULL),
('24162002', '2022-02-18', N'Doan vien',   N'Dang sinh hoat', N'Da dong',  '2025-03-25'),
('24110001', '2022-09-01', N'Pho bi thu',  N'Dang sinh hoat', N'Da dong',  '2025-04-02'),
('24110002', '2022-09-01', N'Doan vien',   N'Dang sinh hoat', N'Chua dong', NULL),
('25110001', '2023-10-05', N'Doan vien',   N'Dang sinh hoat', N'Da dong',  '2025-04-05'),
('25110002', '2023-10-05', N'Doan vien',   N'Dang sinh hoat', N'Da dong',  '2025-04-08'),
('25133001', '2023-11-12', N'Doan vien',   N'Dang sinh hoat', N'No phi',    NULL),
('25133002', '2023-11-20', N'Doan vien',   N'Tam ngung',      N'Chua dong', NULL),
('25133003', '2024-01-10', N'Bi thu',      N'Dang sinh hoat', N'Da dong',  '2025-04-12');
GO

/* ============================================
   DU LIEU MAU HOAT DONG DOAN
   ============================================ */
INSERT INTO dbo.HoatDongDoan (MaHD, TenHD, NgayToChuc, DiaDiem, NoiDung) VALUES
-- Cac hoat dong da dien ra
('HD001', N'Thi tim hieu 26/3',     '2025-03-20', N'Hoi truong A', N'To chuc thi tim hieu truyen thong Doan TNCS Ho Chi Minh'),
('HD002', N'Hien mau nhan dao',     '2025-04-05', N'Nha van hoa tinh', N'Chuong trinh hien mau tinh nguyen vi cong dong'),
('HD003', N'Don ve sinh ky tuc xa','2025-04-15', N'Ky tuc xa Khoa CNTT', N'Hoat dong tinh nguyen ve sinh moi truong'),
('HD004', N'Ngay hoi the thao',     '2025-05-01', N'San van dong truong', N'Thi dau bong da, bong chuyen, keo co'),
('HD005', N'Hoi trai 26/3',         '2025-05-10', N'San truong chinh', N'Hoi trai ky niem ngay thanh lap Doan'),

-- Cac hoat dong chua dien ra
('HD006', N'Giao luu doanh nghiep CNTT', '2025-10-01', N'Hoi truong B', N'Trao doi kinh nghiem, dinh huong nghe nghiep voi doanh nghiep CNTT'),
('HD007', N'Thi Olympic Tin hoc',        '2025-11-15', N'Phong may 305', N'Thi Olympic Tin hoc cho sinh vien toan khoa'),
('HD008', N'Tinh nguyen mua dong',       '2025-12-20', N'Xa mien nui A', N'Chuong trinh tinh nguyen ho tro hoc sinh vung cao'),
('HD009', N'Ngay hoi viec lam CNTT',     '2026-01-05', N'San truong', N'Ket noi sinh vien voi cac doanh nghiep CNTT'),
('HD010', N'Hoi nghi Nghien cuu khoa hoc sinh vien', '2026-03-15', N'Hoi truong lon', N'Bao cao, trao doi de tai nghien cuu khoa hoc');
GO

/* ============================================
   DU LIEU MAU THAM GIA HOAT DONG
   ============================================ */
-- HD001
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('23110001', 'HD001', N'BTC',         N'Hoan thanh'),
('23110002', 'HD001', N'Thanh vien',  N'Xuat sac'),
('23133001', 'HD001', N'Thanh vien',  N'Hoan thanh'),
('23133002', 'HD001', N'Thanh vien',  N'Khong dat');
GO

-- HD002
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('23162001', 'HD002', N'Thanh vien',  N'Hoan thanh'),
('23162002', 'HD002', N'Thanh vien',  N'Hoan thanh'),
('24162001', 'HD002', N'BTC',         N'Hoan thanh'),
('24162002', 'HD002', N'Thanh vien',  N'Hoan thanh');
GO

-- HD003
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('24110001', 'HD003', N'Thanh vien',  N'Xuat sac'),
('24110002', 'HD003', N'Thanh vien',  N'Hoan thanh'),
('25110001', 'HD003', N'BTC',         N'Hoan thanh');
GO

-- HD004
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('25110002', 'HD004', N'Van dong vien', N'Xuat sac'),
('25133001', 'HD004', N'Van dong vien', N'Hoan thanh'),
('25133002', 'HD004', N'Co dong vien',  N'Hoan thanh');
GO

-- HD005
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('25133003', 'HD005', N'BTC',         N'Hoan thanh'),
('23110001', 'HD005', N'Thanh vien',  N'Xuat sac'),
('23110002', 'HD005', N'Thanh vien',  N'Hoan thanh'),
('23133001', 'HD005', N'Thanh vien',  N'Hoan thanh');
GO

-- HD006 (chua dien ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('23133002', 'HD006', N'Thanh vien', NULL),
('24162001', 'HD006', N'Thanh vien', NULL),
('24110002', 'HD006', N'BTC', NULL);
GO

-- HD007 (chua dien ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('23110002', 'HD007', N'Thanh vien', NULL),
('23162001', 'HD007', N'Thanh vien', NULL),
('24110001', 'HD007', N'BTC', NULL);
GO

-- HD008 (chua dien ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('23162002', 'HD008', N'Thanh vien', NULL),
('25110002', 'HD008', N'Thanh vien', NULL),
('25133003', 'HD008', N'BTC', NULL);
GO

-- HD009 (chua dien ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('23110001', 'HD009', N'Thanh vien', NULL),
('24162002', 'HD009', N'Thanh vien', NULL),
('25133001', 'HD009', N'Cong tac vien', NULL);
GO

-- HD010 (chua dien ra)
INSERT INTO dbo.ThamGiaHD (MaSV, MaHD, VaiTro, KetQua) VALUES
('23133001', 'HD010', N'Bao cao vien', NULL),
('25110001', 'HD010', N'Thanh vien', NULL),
('25133002', 'HD010', N'Thanh vien', NULL);
GO
