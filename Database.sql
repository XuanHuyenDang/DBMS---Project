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
        CHECK (ChucVu IS NULL OR ChucVu IN (N'Bí thư', N'Phó bí thư', N'Ủy viên')),
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