-- ==========================================================
-- 1. Tạo Database
-- ==========================================================
CREATE DATABASE QLHocTap;
GO
USE QLHocTap;
GO

-- ==========================================================
-- 2. Bảng Tài khoản
-- ==========================================================
CREATE TABLE TaiKhoan (
    TenDN NVARCHAR(50) PRIMARY KEY,
    MatKhau NVARCHAR(100) NOT NULL,
    VaiTro NVARCHAR(20) NOT NULL CHECK (VaiTro IN ('Admin','GiangVien','SinhVien'))
);
GO

-- ==========================================================
-- 3. Bảng Sinh viên
-- ==========================================================
CREATE TABLE SinhVien (
    MaSV VARCHAR(10) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    Lop VARCHAR(10) NULL,
    Nganh NVARCHAR(50) NULL,
    Khoa NVARCHAR(50) NULL,
    NgaySinh DATE NULL,
    GioiTinh NVARCHAR(5) NULL,
    DiaChi NVARCHAR(200) NULL,
    SDT VARCHAR(15) NULL,
    CONSTRAINT PK_SinhVien PRIMARY KEY (MaSV),
    CONSTRAINT CK_SV_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nu')),
    CONSTRAINT CK_SV_SDT CHECK (SDT IS NULL OR SDT LIKE '[0-9+ -]%')
);
GO

-- ==========================================================
-- 4. Bảng Giảng viên
-- ==========================================================
CREATE TABLE GiangVien (
    MaGV VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL
);
GO

-- ==========================================================
-- 5. Bảng Môn học
-- ==========================================================
CREATE TABLE MonHoc (
    MaMH VARCHAR(10) PRIMARY KEY,
    TenMH NVARCHAR(100) NOT NULL,
    SoTinChi INT NOT NULL CHECK(SoTinChi > 0)
);
GO

-- ==========================================================
-- 6. Bảng Lớp học phần
-- ==========================================================
CREATE TABLE LopHocPhan (
    MaLop VARCHAR(10) PRIMARY KEY,
    MaMH VARCHAR(10) FOREIGN KEY REFERENCES MonHoc(MaMH),
    MaGV VARCHAR(10) FOREIGN KEY REFERENCES GiangVien(MaGV),
    NamHoc NVARCHAR(20),
    HocKy INT CHECK (HocKy IN (1,2,3))
);
GO

-- ==========================================================
-- 7. Bảng Điểm
-- ==========================================================
CREATE TABLE Diem (
    MaSV VARCHAR(10) FOREIGN KEY REFERENCES SinhVien(MaSV),
    MaLop VARCHAR(10) FOREIGN KEY REFERENCES LopHocPhan(MaLop),
    DiemGK FLOAT CHECK(DiemGK BETWEEN 0 AND 10),
    DiemCK FLOAT CHECK(DiemCK BETWEEN 0 AND 10),
    DiemTB AS (ROUND((ISNULL(DiemGK,0)*0.4 + ISNULL(DiemCK,0)*0.6),2)),
    DiemChu AS (
        CASE 
            WHEN (ISNULL(DiemGK,0)*0.4 + ISNULL(DiemCK,0)*0.6) >= 8 THEN 'A'
            WHEN (ISNULL(DiemGK,0)*0.4 + ISNULL(DiemCK,0)*0.6) >= 6.5 THEN 'B'
            WHEN (ISNULL(DiemGK,0)*0.4 + ISNULL(DiemCK,0)*0.6) >= 5 THEN 'C'
            WHEN (ISNULL(DiemGK,0)*0.4 + ISNULL(DiemCK,0)*0.6) >= 4 THEN 'D'
            ELSE 'F'
        END
    ),
    KetQua AS (
        CASE 
            WHEN (ISNULL(DiemGK,0)*0.4 + ISNULL(DiemCK,0)*0.6) >= 4 THEN N'Đậu'
            ELSE N'Rớt'
        END
    ),
    CONSTRAINT PK_Diem PRIMARY KEY (MaSV, MaLop)
);
GO

-- ==========================================================
-- 8. DỮ LIỆU MẪU
-- ==========================================================

-- Sinh viên (15 SV)
INSERT INTO SinhVien (MaSV, HoTen, Lop, Nganh, Khoa, NgaySinh, GioiTinh, DiaChi, SDT) VALUES
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

-- Giảng viên (5 GV)
INSERT INTO GiangVien (MaGV, HoTen) VALUES
('GV01', N'Nguyen Van Thay'),
('GV02', N'Tran Thi Co'),
('GV03', N'Le Van Thay'),
('GV04', N'Pham Thi Co'),
('GV05', N'Do Van Thay');
GO

-- Môn học (5 MH)
INSERT INTO MonHoc (MaMH, TenMH, SoTinChi) VALUES
('MH01', N'Cơ sở dữ liệu', 3),
('MH02', N'Cấu trúc dữ liệu', 4),
('MH03', N'Lập trình C#', 3),
('MH04', N'An toàn thông tin', 3),
('MH05', N'Trí tuệ nhân tạo', 3);
GO

-- Lớp học phần (5 LHP)
INSERT INTO LopHocPhan (MaLop, MaMH, MaGV, NamHoc, HocKy) VALUES
('LP01', 'MH01', 'GV01', N'2024-2025', 1),
('LP02', 'MH02', 'GV02', N'2024-2025', 1),
('LP03', 'MH03', 'GV03', N'2024-2025', 2),
('LP04', 'MH04', 'GV04', N'2024-2025', 2),
('LP05', 'MH05', 'GV05', N'2024-2025', 3);
GO

-- Điểm (15 SV phân bổ vào 5 lớp)
INSERT INTO Diem (MaSV, MaLop, DiemGK, DiemCK) VALUES
('SV001', 'LP01', 7.5, 8.0),
('SV002', 'LP01', 6.0, 7.0),
('SV003', 'LP01', 8.5, 9.0),
('SV004', 'LP02', 5.0, 6.0),
('SV005', 'LP02', 4.0, 5.0),
('SV006', 'LP02', 9.0, 8.5),
('SV007', 'LP03', 6.5, 7.0),
('SV008', 'LP03', 8.0, 8.5),
('SV009', 'LP03', 5.5, 6.0),
('SV010', 'LP04', 7.0, 7.5),
('SV011', 'LP04', 3.0, 4.0), -- rớt
('SV012', 'LP04', 8.0, 9.0),
('SV013', 'LP05', 6.5, 7.5),
('SV014', 'LP05', 7.5, 8.0),
('SV015', 'LP05', 5.0, 5.5);
GO

-- Tài khoản (Admin, GV, SV)
INSERT INTO TaiKhoan (TenDN, MatKhau, VaiTro) VALUES
('admin', '123', 'Admin'),
('gv01', '123', 'GiangVien'),
('gv02', '123', 'GiangVien'),
('gv03', '123', 'GiangVien'),
('gv04', '123', 'GiangVien'),
('gv05', '123', 'GiangVien'),
('sv001', '123', 'SinhVien'),
('sv002', '123', 'SinhVien'),
('sv003', '123', 'SinhVien'),
('sv004', '123', 'SinhVien'),
('sv005', '123', 'SinhVien'),
('sv006', '123', 'SinhVien'),
('sv007', '123', 'SinhVien'),
('sv008', '123', 'SinhVien'),
('sv009', '123', 'SinhVien'),
('sv010', '123', 'SinhVien'),
('sv011', '123', 'SinhVien'),
('sv012', '123', 'SinhVien'),
('sv013', '123', 'SinhVien'),
('sv014', '123', 'SinhVien'),
('sv015', '123', 'SinhVien');
GO

-- ==========================================================
-- 9. FUNCTION
-- ==========================================================
CREATE FUNCTION fn_TBTL(@MaSV VARCHAR(10))
RETURNS FLOAT
AS
BEGIN
    DECLARE @Diem FLOAT;
    SELECT @Diem = AVG(DiemTB) FROM Diem WHERE MaSV=@MaSV;
    RETURN ISNULL(@Diem,0);
END;
GO

CREATE FUNCTION fn_KetQuaSV(@MaSV VARCHAR(10))
RETURNS TABLE
AS
RETURN
(
    SELECT M.MaMH, M.TenMH, M.SoTinChi, D.DiemGK, D.DiemCK, D.DiemTB, D.DiemChu, D.KetQua
    FROM Diem D 
    JOIN LopHocPhan L ON D.MaLop=L.MaLop
    JOIN MonHoc M ON L.MaMH=M.MaMH
    WHERE D.MaSV=@MaSV
);
GO

-- ==========================================================
-- 10. VIEW
-- ==========================================================
CREATE VIEW vw_TongHopDiem
AS
SELECT SV.MaSV, SV.HoTen, SV.Lop, SV.Nganh, SV.Khoa, L.MaLop, M.TenMH, D.DiemGK, D.DiemCK, D.DiemTB, D.DiemChu, D.KetQua
FROM SinhVien SV
JOIN Diem D ON SV.MaSV=D.MaSV
JOIN LopHocPhan L ON D.MaLop=L.MaLop
JOIN MonHoc M ON L.MaMH=M.MaMH;
GO

-- ==========================================================
-- 11. TRIGGER
-- ==========================================================
CREATE TRIGGER trg_KhongXoaSV
ON SinhVien
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Diem WHERE MaSV IN (SELECT MaSV FROM deleted))
    BEGIN
        RAISERROR(N'Sinh viên còn điểm, không thể xóa!',16,1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM SinhVien WHERE MaSV IN (SELECT MaSV FROM deleted);
    END
END;
GO

-- ==========================================================
-- 12. STORED PROCEDURE
-- ==========================================================
CREATE PROCEDURE sp_NhapDiem
    @MaSV VARCHAR(10),
    @MaLop VARCHAR(10),
    @DiemGK FLOAT,
    @DiemCK FLOAT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Diem WHERE MaSV=@MaSV AND MaLop=@MaLop)
        UPDATE Diem SET DiemGK=@DiemGK, DiemCK=@DiemCK WHERE MaSV=@MaSV AND MaLop=@MaLop;
    ELSE
        INSERT INTO Diem(MaSV,MaLop,DiemGK,DiemCK) VALUES(@MaSV,@MaLop,@DiemGK,@DiemCK);
END;
GO

-- ==========================================================
-- 13. ROLE & PHÂN QUYỀN
-- ==========================================================
CREATE ROLE role_admin;
CREATE ROLE role_giangvien;
CREATE ROLE role_sinhvien;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SinhVien TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON GiangVien TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON MonHoc TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON LopHocPhan TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Diem TO role_admin;
GO

GRANT SELECT, INSERT, UPDATE ON Diem TO role_giangvien;
GRANT SELECT ON vw_TongHopDiem TO role_giangvien;
GO

GRANT SELECT ON vw_TongHopDiem TO role_sinhvien;
GO
