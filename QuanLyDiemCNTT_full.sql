
/* =========================================================
   HỆ THỐNG QUẢN LÝ ĐIỂM & KẾT QUẢ HỌC TẬP (CNTT)
   Môi trường: Microsoft SQL Server (T-SQL)
   Nội dung: Database, Tables, Constraints, Indexes, Views,
             Functions, Triggers, TVP, Stored Procedures,
             Sample Data, Roles, Row-Level Security (RLS)
   ========================================================= */

------------------------------------------------------------
-- 0) KHỞI TẠO CSDL
------------------------------------------------------------

CREATE DATABASE QuanLyDiemCNTT;
GO
USE QuanLyDiemCNTT;
GO

------------------------------------------------------------
-- 1) BẢNG DANH MỤC & NGHIỆP VỤ
------------------------------------------------------------

-- 1.1) SINH VIÊN

CREATE TABLE dbo.SinhVien (
    MaSV      VARCHAR(10)    NOT NULL,
    HoTen     NVARCHAR(100)  NOT NULL,
    NgaySinh  DATE           NULL,
    GioiTinh  NVARCHAR(5)    NULL,   -- Nam/Nu
    Lop       VARCHAR(10)    NULL,
    Nganh     NVARCHAR(50)   NULL,
    Khoa      NVARCHAR(50)   NULL,
    DiaChi    NVARCHAR(200)  NULL,
    SDT       VARCHAR(15)    NULL,
    CONSTRAINT PK_SinhVien PRIMARY KEY (MaSV),
    CONSTRAINT CK_SV_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nu', N'Nữ')),
    CONSTRAINT CK_SV_SDT CHECK (SDT IS NULL OR SDT LIKE '[0-9+ -]%')
);
GO

-- 1.2) MÔN HỌC

CREATE TABLE dbo.MonHoc (
    MaMH    VARCHAR(10)    NOT NULL,
    TenMH   NVARCHAR(100)  NOT NULL,
    SoTC    TINYINT        NOT NULL CHECK (SoTC BETWEEN 1 AND 10),
    HocKy   TINYINT        NULL CHECK (HocKy BETWEEN 1 AND 10),
    CONSTRAINT PK_MonHoc PRIMARY KEY (MaMH),
    CONSTRAINT UQ_MonHoc_TenMH UNIQUE (TenMH)
);
GO

-- 1.3) GIẢNG VIÊN

CREATE TABLE dbo.GiangVien (
    MaGV   VARCHAR(10)    NOT NULL,
    HoTen  NVARCHAR(100)  NOT NULL,
    BoMon  NVARCHAR(100)  NULL,
    Email  VARCHAR(150)   NULL,
    CONSTRAINT PK_GiangVien PRIMARY KEY (MaGV),
    CONSTRAINT UQ_GiangVien_Email UNIQUE (Email)
);
GO

-- 1.4) PHÂN CÔNG GIẢNG DẠY

CREATE TABLE dbo.PhanCong (
    MaGV    VARCHAR(10)   NOT NULL,
    MaMH    VARCHAR(10)   NOT NULL,
    Lop     VARCHAR(10)   NOT NULL,
    NamHoc  VARCHAR(9)    NOT NULL,   -- VD: '2024-2025'
    HocKy   TINYINT       NOT NULL CHECK (HocKy BETWEEN 1 AND 10),
    CONSTRAINT PK_PhanCong PRIMARY KEY (MaGV, MaMH, Lop, NamHoc, HocKy),
    CONSTRAINT FK_PC_GV FOREIGN KEY (MaGV) REFERENCES dbo.GiangVien(MaGV),
    CONSTRAINT FK_PC_MH FOREIGN KEY (MaMH) REFERENCES dbo.MonHoc(MaMH)
);
GO

-- 1.5) KẾT QUẢ HỌC TẬP

CREATE TABLE dbo.KetQua (
    MaSV     VARCHAR(10)   NOT NULL,
    MaMH     VARCHAR(10)   NOT NULL,
    NamHoc   VARCHAR(9)    NOT NULL,   -- '2024-2025'
    HocKy    TINYINT       NOT NULL CHECK (HocKy BETWEEN 1 AND 10),

    -- Điểm thành phần (0..10)

    DiemGK   DECIMAL(4,2)  NULL CHECK (DiemGK BETWEEN 0 AND 10),

    DiemCK   DECIMAL(4,2)  NULL CHECK (DiemCK BETWEEN 0 AND 10),

    -- Tự động tính
    DiemTB   DECIMAL(5,2)  NULL CHECK (DiemTB BETWEEN 0 AND 10),
    DiemChu  CHAR(2)       NULL,       -- A, A-, B, B-, C, D, F

    -- Dấu thời gian
    CreatedAt DATETIME2    NOT NULL CONSTRAINT DF_KQ_CreatedAt DEFAULT (SYSDATETIME()),
    UpdatedAt DATETIME2    NULL,

    CONSTRAINT PK_KetQua PRIMARY KEY (MaSV, MaMH, NamHoc, HocKy),
    CONSTRAINT FK_KQ_SV FOREIGN KEY (MaSV) REFERENCES dbo.SinhVien(MaSV),
    CONSTRAINT FK_KQ_MH FOREIGN KEY (MaMH) REFERENCES dbo.MonHoc(MaMH)
);
GO

-- 1.6) BẢNG CẢNH BÁO HỌC LẠI

CREATE TABLE dbo.CanhBaoHocLai (
    MaSV    VARCHAR(10)  NOT NULL,
    MaMH    VARCHAR(10)  NOT NULL,
    NamHoc  VARCHAR(9)   NOT NULL,
    HocKy   TINYINT      NOT NULL,
    DiemTB  DECIMAL(5,2) NOT NULL,
    DiemChu CHAR(2)      NOT NULL,
    GhiChu  NVARCHAR(200) NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_CBHL_CreatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_CanHBl PRIMARY KEY (MaSV, MaMH, NamHoc, HocKy)
);
GO

-- 1.7) CHỈ MỤC
CREATE INDEX IX_KetQua_MaSV ON dbo.KetQua (MaSV);
CREATE INDEX IX_KetQua_MaMH ON dbo.KetQua (MaMH);
CREATE INDEX IX_KetQua_NamHoc_HocKy ON dbo.KetQua (NamHoc, HocKy);
GO

------------------------------------------------------------
-- 2) VIEW
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_KetQuaDayDu','V') IS NOT NULL DROP VIEW dbo.vw_KetQuaDayDu;
GO
CREATE VIEW dbo.vw_KetQuaDayDu
AS
SELECT
    kq.MaSV, sv.HoTen AS TenSV, sv.Lop, sv.Nganh, sv.Khoa,
    kq.MaMH, mh.TenMH, mh.SoTC,
    kq.NamHoc, kq.HocKy,
	kq.DiemGK, kq.DiemCK,
    kq.DiemTB, kq.DiemChu,
    kq.CreatedAt, kq.UpdatedAt
FROM dbo.KetQua kq
JOIN dbo.SinhVien sv ON sv.MaSV = kq.MaSV
JOIN dbo.MonHoc  mh ON mh.MaMH = kq.MaMH;
GO

------------------------------------------------------------
-- 3) HÀM TÍNH TOÁN & TRA CỨU
------------------------------------------------------------

-- 3.1) Điểm số -> Điểm chữ
IF OBJECT_ID('dbo.fn_DiemSo_To_DiemChu','FN') IS NOT NULL DROP FUNCTION dbo.fn_DiemSo_To_DiemChu;
GO
CREATE FUNCTION dbo.fn_DiemSo_To_DiemChu (@DiemTB DECIMAL(5,2))
RETURNS CHAR(2)
AS
BEGIN
    DECLARE @Chu CHAR(2);
    IF @DiemTB IS NULL        SET @Chu = NULL;
    ELSE IF @DiemTB >= 9.0    SET @Chu = 'A+';
    ELSE IF @DiemTB >= 8.5    SET @Chu = 'A';
    ELSE IF @DiemTB >= 8.0    SET @Chu = 'B+';
    ELSE IF @DiemTB >= 7.0    SET @Chu = 'B';
    ELSE IF @DiemTB >= 6.5    SET @Chu = 'C+';
    ELSE IF @DiemTB >= 5.5    SET @Chu = 'C';
	ELSE IF @DiemTB >= 5.0    SET @Chu = 'D+';
    ELSE                      SET @Chu = 'F';
    RETURN @Chu;
END;
GO

-- 3.2) Điểm chữ -> Thang 4.0
IF OBJECT_ID('dbo.fn_DiemChu_To_Thang4','FN') IS NOT NULL DROP FUNCTION dbo.fn_DiemChu_To_Thang4;
GO
CREATE FUNCTION dbo.fn_DiemChu_To_Thang4 (@DiemChu CHAR(2))
RETURNS DECIMAL(3,2)
AS
BEGIN
    RETURN (
        CASE @DiemChu
            WHEN 'A+'  THEN 4.00
            WHEN 'A' THEN 3.70
            WHEN 'B+'  THEN 3.50
            WHEN 'B' THEN 3.00
            WHEN 'C+'  THEN 2.50
            WHEN 'C'  THEN 2.00
			WHEN 'D+'  THEN 1.50
            WHEN 'F'  THEN 1.00
            ELSE NULL
        END
    );
END;
GO

-- 3.3) Tính Điểm TB theo trọng số (GK 50%, CK 50%)
IF OBJECT_ID('dbo.fn_TinhDiemTB','FN') IS NOT NULL DROP FUNCTION dbo.fn_TinhDiemTB;
GO
CREATE FUNCTION dbo.fn_TinhDiemTB (
    @DiemGK DECIMAL(4,2),
    @DiemCK DECIMAL(4,2)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @tb DECIMAL(5,2);
    SET @tb =         
        ISNULL(@DiemGK,0)*0.50 +
        ISNULL(@DiemCK,0)*0.50;
    RETURN ROUND(@tb,2);
END;
GO

-- 3.4) GPA theo học kỳ hoặc tích lũy
IF OBJECT_ID('dbo.fn_GPA_SinhVien','FN') IS NOT NULL DROP FUNCTION dbo.fn_GPA_SinhVien;
GO
CREATE FUNCTION dbo.fn_GPA_SinhVien (
    @MaSV  VARCHAR(10),
    @NamHoc VARCHAR(9) = NULL,
    @HocKy  TINYINT    = NULL
)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @GPA DECIMAL(10,4);
    ;WITH Diem AS (
        SELECT mh.SoTC, dbo.fn_DiemChu_To_Thang4(kq.DiemChu) AS Diem4
        FROM dbo.KetQua kq
        JOIN dbo.MonHoc mh ON mh.MaMH = kq.MaMH
        WHERE kq.MaSV = @MaSV
          AND (@NamHoc IS NULL OR kq.NamHoc = @NamHoc)
          AND (@HocKy  IS NULL OR kq.HocKy  = @HocKy)
          AND kq.DiemChu IS NOT NULL
    )
    SELECT @GPA = 
        CASE WHEN SUM(SoTC) = 0 THEN NULL
             ELSE CAST(SUM(Diem4*SoTC) / SUM(SoTC) AS DECIMAL(10,4))
        END
    FROM Diem;

    RETURN CAST(@GPA AS DECIMAL(4,2));
END;
GO

-- 3.5) Bảng điểm SV (TVF trả về bảng)
IF OBJECT_ID('dbo.fn_BangDiem_SV','IF') IS NOT NULL DROP FUNCTION dbo.fn_BangDiem_SV;
GO
CREATE FUNCTION dbo.fn_BangDiem_SV (
    @MaSV  VARCHAR(10),
    @NamHoc VARCHAR(9) = NULL,
    @HocKy  TINYINT    = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        kq.MaSV, kq.MaMH, mh.TenMH, mh.SoTC,
        kq.NamHoc, kq.HocKy,
        kq.DiemGK, kq.DiemCK,
        kq.DiemTB, kq.DiemChu
    FROM dbo.KetQua kq
    JOIN dbo.MonHoc mh ON mh.MaMH = kq.MaMH
    WHERE kq.MaSV = @MaSV
      AND (@NamHoc IS NULL OR kq.NamHoc = @NamHoc)
      AND (@HocKy  IS NULL OR kq.HocKy  = @HocKy)
);
GO

------------------------------------------------------------
-- 4) TRIGGER TỰ ĐỘNG
------------------------------------------------------------

-- 4.1) Sau INSERT/UPDATE: tính DiemTB & DiemChu + cập nhật UpdatedAt
IF OBJECT_ID('dbo.tr_KQ_After_IU_TinhDiem','TR') IS NOT NULL DROP TRIGGER dbo.tr_KQ_After_IU_TinhDiem;
GO
CREATE TRIGGER dbo.tr_KQ_After_IU_TinhDiem
ON dbo.KetQua
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tính điểm TB và chữ
    UPDATE kq
    SET 
        kq.DiemTB = dbo.fn_TinhDiemTB( kq.DiemGK, kq.DiemCK),
        kq.DiemChu = dbo.fn_DiemSo_To_DiemChu(
                        dbo.fn_TinhDiemTB(kq.DiemGK, kq.DiemCK)
                     ),
        kq.UpdatedAt = SYSDATETIME()
    FROM dbo.KetQua kq
    JOIN inserted i
      ON i.MaSV = kq.MaSV AND i.MaMH = kq.MaMH 
     AND i.NamHoc = kq.NamHoc AND i.HocKy = kq.HocKy;

    -- Chèn/cập nhật cảnh báo học lại cho bản ghi có điểm F
    MERGE dbo.CanhBaoHocLai AS t
    USING (
        SELECT k.MaSV, k.MaMH, k.NamHoc, k.HocKy, k.DiemTB, k.DiemChu
        FROM dbo.KetQua k
        JOIN inserted i
          ON i.MaSV  = k.MaSV
         AND i.MaMH  = k.MaMH
         AND i.NamHoc= k.NamHoc
         AND i.HocKy = k.HocKy
        WHERE k.DiemChu = 'F'
    ) s
    ON  t.MaSV  = s.MaSV
    AND t.MaMH  = s.MaMH
    AND t.NamHoc= s.NamHoc
    AND t.HocKy = s.HocKy
    WHEN MATCHED THEN
        UPDATE SET DiemTB = s.DiemTB, DiemChu = s.DiemChu, GhiChu = N'Điểm F - cần học lại'
    WHEN NOT MATCHED THEN
        INSERT (MaSV, MaMH, NamHoc, HocKy, DiemTB, DiemChu, GhiChu)
        VALUES (s.MaSV, s.MaMH, s.NamHoc, s.HocKy, s.DiemTB, s.DiemChu, N'Điểm F - cần học lại');

    -- Xóa cảnh báo nếu điểm không còn F
    DELETE t
    FROM dbo.CanhBaoHocLai t
    JOIN inserted i
      ON i.MaSV  = t.MaSV
     AND i.MaMH  = t.MaMH
     AND i.NamHoc= t.NamHoc
     AND i.HocKy = t.HocKy
    WHERE EXISTS (
        SELECT 1 FROM dbo.KetQua k
        WHERE k.MaSV = t.MaSV AND k.MaMH = t.MaMH
          AND k.NamHoc = t.NamHoc AND k.HocKy = t.HocKy
          AND k.DiemChu <> 'F'
    );
END;
GO

------------------------------------------------------------
-- 5) TVP + STORED PROCEDURES
------------------------------------------------------------

-- 5.0) TVP nhập điểm hàng loạt
IF TYPE_ID('dbo.DiemInputType') IS NOT NULL DROP TYPE dbo.DiemInputType;
GO
CREATE TYPE dbo.DiemInputType AS TABLE (
    MaSV   VARCHAR(10)  NOT NULL,
    MaMH   VARCHAR(10)  NOT NULL,
    NamHoc VARCHAR(9)   NOT NULL,
    HocKy  TINYINT      NOT NULL,
    DiemGK DECIMAL(4,2) NULL,
    DiemCK DECIMAL(4,2) NULL
);
GO

-- 5.1) Upsert điểm một SV-môn
IF OBJECT_ID('dbo.sp_UpsertDiem','P') IS NOT NULL DROP PROCEDURE dbo.sp_UpsertDiem;
GO
CREATE PROCEDURE dbo.sp_UpsertDiem
    @MaSV   VARCHAR(10),
    @MaMH   VARCHAR(10),
    @NamHoc VARCHAR(9),
    @HocKy  TINYINT,
    @DiemGK DECIMAL(4,2) = NULL,
    @DiemCK DECIMAL(4,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        MERGE dbo.KetQua AS t
        USING (SELECT @MaSV AS MaSV, @MaMH AS MaMH, @NamHoc AS NamHoc, @HocKy AS HocKy) s
        ON  t.MaSV = s.MaSV AND t.MaMH = s.MaMH
        AND t.NamHoc = s.NamHoc AND t.HocKy = s.HocKy
        WHEN MATCHED THEN
            UPDATE SET DiemGK=@DiemGK, DiemCK=@DiemCK
        WHEN NOT MATCHED THEN
            INSERT (MaSV, MaMH, NamHoc, HocKy, DiemGK,  DiemCK)
            VALUES (@MaSV, @MaMH, @NamHoc, @HocKy,  @DiemGK,  @DiemCK);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- 5.2) Nhập điểm hàng loạt
IF OBJECT_ID('dbo.sp_NhapDiemHangLoat','P') IS NOT NULL DROP PROCEDURE dbo.sp_NhapDiemHangLoat;
GO
CREATE PROCEDURE dbo.sp_NhapDiemHangLoat
    @BangDiem dbo.DiemInputType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        MERGE dbo.KetQua AS t
        USING @BangDiem s
        ON  t.MaSV = s.MaSV AND t.MaMH = s.MaMH
        AND t.NamHoc = s.NamHoc AND t.HocKy = s.HocKy
        WHEN MATCHED THEN
            UPDATE SET  DiemGK=s.DiemGK,  DiemCK=s.DiemCK
        WHEN NOT MATCHED THEN
            INSERT (MaSV, MaMH, NamHoc, HocKy,  DiemGK,  DiemCK)
            VALUES (s.MaSV, s.MaMH, s.NamHoc, s.HocKy, s.DiemGK,  s.DiemCK);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

-- 5.3) Bảng điểm học kỳ cho 1 SV
IF OBJECT_ID('dbo.sp_BangDiem_HocKy','P') IS NOT NULL DROP PROCEDURE dbo.sp_BangDiem_HocKy;
GO
CREATE PROCEDURE dbo.sp_BangDiem_HocKy
    @MaSV   VARCHAR(10),
    @NamHoc VARCHAR(9),
    @HocKy  TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *, dbo.fn_GPA_SinhVien(@MaSV, @NamHoc, @HocKy) AS GPA_HocKy
    FROM dbo.fn_BangDiem_SV(@MaSV, @NamHoc, @HocKy);
END;
GO

-- 5.4) Báo cáo lớp theo học kỳ
IF OBJECT_ID('dbo.sp_BaoCao_Lop','P') IS NOT NULL DROP PROCEDURE dbo.sp_BaoCao_Lop;
GO
CREATE PROCEDURE dbo.sp_BaoCao_Lop
    @Lop    VARCHAR(10),
    @NamHoc VARCHAR(9),
    @HocKy  TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH DataCTE AS (
        SELECT sv.Lop, kq.MaSV, kq.MaMH, kq.DiemChu, mh.SoTC
        FROM dbo.KetQua kq
        JOIN dbo.SinhVien sv ON sv.MaSV = kq.MaSV
        JOIN dbo.MonHoc  mh ON mh.MaMH = kq.MaMH
        WHERE sv.Lop = @Lop AND kq.NamHoc = @NamHoc AND kq.HocKy = @HocKy
    ),
    GPACTE AS (
        SELECT MaSV,
               CAST(SUM(SoTC*dbo.fn_DiemChu_To_Thang4(DiemChu)) / NULLIF(SUM(SoTC),0) AS DECIMAL(4,2)) AS GPA_HK
        FROM DataCTE
        GROUP BY MaSV
    )
    SELECT 
        @Lop AS Lop, @NamHoc AS NamHoc, @HocKy AS HocKy,
        COUNT(DISTINCT d.MaSV) AS SoSV,
        CAST(AVG(g.GPA_HK) AS DECIMAL(4,2)) AS GPA_TB_Lop,
        SUM(CASE WHEN d.DiemChu='F' THEN 1 ELSE 0 END) AS SoLuong_F
    FROM DataCTE d
    LEFT JOIN GPACTE g ON g.MaSV = d.MaSV;
END;
GO

------------------------------------------------------------
-- 6) DỮ LIỆU MẪU
------------------------------------------------------------

-- 6.1) Sinh viên

INSERT INTO dbo.SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, Lop, Nganh, Khoa, DiaChi, SDT) VALUES
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

-- 6.2) Môn học

INSERT INTO dbo.MonHoc (MaMH, TenMH, SoTC, HocKy) VALUES
('CT101', N'Toan cao cap', 3, 1),
('CT102', N'Lap trinh co ban', 4, 1),
('CT201', N'Cau truc du lieu', 3, 2),
('CT202', N'Co so du lieu', 3, 2),
('CT301', N'He dieu hanh', 3, 3),
('CT302', N'Mang may tinh', 3, 3);
GO

-- 6.3) Giảng viên

INSERT INTO dbo.GiangVien (MaGV, HoTen, BoMon, Email) VALUES
('GV001', N'Nguyen Thanh Son', N'Hệ thống', 'sonnguyen@example.edu'),
('GV002', N'Huynh Xuan Phung',    N'Phần mềm', 'phunghuynh@example.edu');
GO

-- 6.4) Phân công

INSERT INTO dbo.PhanCong (MaGV, MaMH, Lop, NamHoc, HocKy) VALUES
('GV001', 'CT202', 'CTK45A', '2024-2025', 2),
('GV001', 'CT201', 'CTK45B', '2024-2025', 2),
('GV002', 'CT102', 'CTK46B', '2024-2025', 1);
GO


--------------------------------------------------------------
-- FIX PACK: ROLES + SCHEMA + GRANT + RLS (đã sửa lỗi)
------------------------------------------------------------
-- 0) Schema bảo mật cho RLS (tạo trước rồi mới GRANT)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'sec')
    EXEC('CREATE SCHEMA sec AUTHORIZATION dbo;');
GO

-- 1) Tạo ROLES nếu chưa có
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_app_admin')
    CREATE ROLE role_app_admin AUTHORIZATION dbo;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_giang_vien')
    CREATE ROLE role_giang_vien AUTHORIZATION dbo;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'role_sinh_vien')
    CREATE ROLE role_sinh_vien AUTHORIZATION dbo;
GO

-- 2) Phân quyền (đÃ loại Readonly, gộp Giáo vụ vào Admin)
-- Admin (bao gồm Giáo vụ): toàn quyền
GRANT CONTROL ON SCHEMA::dbo TO role_app_admin;
GRANT CONTROL ON SCHEMA::sec TO role_app_admin;
GRANT ALTER ANY SECURITY POLICY TO role_app_admin;

-- Giảng viên
GRANT SELECT, INSERT, UPDATE ON dbo.KetQua TO role_giang_vien;
GRANT SELECT ON dbo.SinhVien TO role_giang_vien;
GRANT SELECT ON dbo.MonHoc TO role_giang_vien;
GRANT SELECT ON dbo.GiangVien TO role_giang_vien;
GRANT SELECT ON dbo.PhanCong TO role_giang_vien;
GRANT SELECT ON dbo.vw_KetQuaDayDu TO role_giang_vien;
GRANT EXECUTE ON dbo.sp_UpsertDiem TO role_giang_vien;
GRANT EXECUTE ON dbo.sp_NhapDiemHangLoat TO role_giang_vien;
GRANT EXECUTE ON dbo.sp_BangDiem_HocKy TO role_giang_vien;

-- Sinh viên
GRANT SELECT ON dbo.KetQua TO role_sinh_vien;
GRANT SELECT ON dbo.vw_KetQuaDayDu TO role_sinh_vien;
GRANT SELECT ON dbo.MonHoc TO role_sinh_vien;
GO

-- 3) (Re)Tạo hàm predicate RLS (đặt bí danh cột rõ ràng)
IF OBJECT_ID('sec.fn_rls_ketqua','IF') IS NOT NULL
    DROP FUNCTION sec.fn_rls_ketqua;
GO
CREATE FUNCTION sec.fn_rls_ketqua
(
    @MaSV   VARCHAR(10),
    @MaMH   VARCHAR(10),
    @NamHoc VARCHAR(9),
    @HocKy  TINYINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    -- Admin: full access
    SELECT CAST(1 AS bit) AS AllowAccess
    WHERE TRY_CAST(SESSION_CONTEXT(N'IsAdmin') AS bit) = 1

    UNION ALL

    -- Sinh viên: chỉ truy cập hàng của chính mình
    SELECT CAST(1 AS bit) AS AllowAccess
    WHERE SESSION_CONTEXT(N'Role') = N'SinhVien'
      AND SESSION_CONTEXT(N'MaSV') = @MaSV

    UNION ALL

    -- Giảng viên: chỉ truy cập hàng thuộc phân công giảng dạy
    SELECT CAST(1 AS bit) AS AllowAccess
    FROM dbo.SinhVien AS sv
    JOIN dbo.PhanCong AS pc
      ON pc.Lop   = sv.Lop
     AND pc.MaMH  = @MaMH
     AND pc.NamHoc= @NamHoc
     AND pc.HocKy = @HocKy
    WHERE sv.MaSV = @MaSV
      AND SESSION_CONTEXT(N'Role') = N'GiangVien'
      AND SESSION_CONTEXT(N'MaGV') = pc.MaGV
);
GO

-- 4) SECURITY POLICY (tạo mới hoặc tạo lại)
IF OBJECT_ID('sec.Policy_KetQua','SO') IS NOT NULL
    DROP SECURITY POLICY sec.Policy_KetQua;
GO
CREATE SECURITY POLICY sec.Policy_KetQua
ADD FILTER PREDICATE sec.fn_rls_ketqua(MaSV, MaMH, NamHoc, HocKy) ON dbo.KetQua,
ADD BLOCK  PREDICATE sec.fn_rls_ketqua(MaSV, MaMH, NamHoc, HocKy) ON dbo.KetQua AFTER INSERT,
ADD BLOCK  PREDICATE sec.fn_rls_ketqua(MaSV, MaMH, NamHoc, HocKy) ON dbo.KetQua BEFORE UPDATE
WITH (STATE = ON);
GO
