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
    Lop       VARCHAR(10)    NULL,
    Nganh     NVARCHAR(50)   NULL,
    Khoa      NVARCHAR(50)   NULL,
    NgaySinh  DATE           NULL,
    GioiTinh  NVARCHAR(5)    NULL,  -- Nam/Nu
    DiaChi    NVARCHAR(200)  NULL,
    SDT       VARCHAR(15)    NULL,
    CONSTRAINT PK_SinhVien PRIMARY KEY (MaSV),
    CONSTRAINT CK_SV_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nu')),
    CONSTRAINT CK_SV_SDT CHECK (SDT IS NULL OR SDT LIKE '[0-9+ -]%')
);
GO

/* ============================================
   DU LIEU MAU CHO 15 SINH VIEN
   ============================================ */
INSERT INTO dbo.SinhVien (MaSV, HoTen, Lop, Nganh, Khoa, NgaySinh, GioiTinh, DiaChi, SDT)
VALUES
('SV001', N'Nguyen Van A',  'CTK45A', N'Cong nghe thong tin', N'CNTT', '2004-01-15', N'Nam', N'Ha Noi', '0912345678'),
('SV002', N'Tran Thi B',    'CTK45A', N'Cong nghe thong tin', N'CNTT', '2004-02-20', N'Nu',  N'Ha Noi', '0912345679'),
('SV003', N'Le Van C',      'CTK45B', N'Ky thuat du lieu',    N'CNTT', '2003-12-10', N'Nam', N'Hai Phong', '0912345680'),
('SV004', N'Pham Thi D',    'CTK45B', N'Ky thuat du lieu',    N'CNTT', '2004-03-05', N'Nu',  N'Hai Phong', '0912345681'),
('SV005', N'Hoang Van E',   'CTK45C', N'An toan thong tin',   N'CNTT', '2004-04-12', N'Nam', N'Ha Nam', '0912345682'),
('SV006', N'Ngo Thi F',     'CTK45C', N'An toan thong tin',   N'CNTT', '2004-05-22', N'Nu',  N'Ha Nam', '0912345683'),
('SV007', N'Dang Van G',    'CTK46A', N'An toan thong tin',   N'CNTT', '2005-06-18', N'Nam', N'Ninh Binh', '0912345684'),
('SV008', N'Vu Thi H',      'CTK46A', N'An toan thong tin',   N'CNTT', '2005-07-25', N'Nu',  N'Ninh Binh', '0912345685'),
('SV009', N'Bui Van I',     'CTK46B', N'Cong nghe thong tin', N'CNTT', '2005-08-30', N'Nam', N'Thai Binh', '0912345686'),
('SV010', N'Nguyen Thi K',  'CTK46B', N'Cong nghe thong tin', N'CNTT', '2005-09-12', N'Nu',  N'Thai Binh', '0912345687'),
('SV011', N'Luong Van L',   'CTK47A', N'Cong nghe thong tin', N'CNTT', '2006-01-10', N'Nam', N'Ha Tinh', '0912345688'),
('SV012', N'Phan Thi M',    'CTK47A', N'Cong nghe thong tin', N'CNTT', '2006-02-11', N'Nu',  N'Ha Tinh', '0912345689'),
('SV013', N'Ta Van N',      'CTK47B', N'Ky thuat du lieu',    N'CNTT', '2006-03-14', N'Nam', N'Nam Dinh', '0912345690'),
('SV014', N'Do Thi O',      'CTK47B', N'Ky thuat du lieu',    N'CNTT', '2006-04-17', N'Nu',  N'Nam Dinh', '0912345691'),
('SV015', N'Ha Van P',      'CTK47C', N'Ky thuat du lieu',    N'CNTT', '2006-05-20', N'Nam', N'Thanh Hoa', '0912345692');
GO