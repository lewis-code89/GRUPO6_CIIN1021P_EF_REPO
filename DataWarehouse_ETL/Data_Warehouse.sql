
/*CREACION DEL DATA WAREHOUSE*/
CREATE DATABASE DW_DatosSalud_Junin;
GO

USE DW_DatosSalud_Junin;
GO

--DIMENSION TIEMPO
CREATE TABLE Dim_Tiempo (
    Id_Tiempo INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    Anio INT,
    Mes INT,
    Trimestre INT
);
GO

--DIMENSION FINANCIADOR
CREATE TABLE Dim_Financiador (
    Id_Financiador INT PRIMARY KEY
);
GO

--DIMENSION CLASIFICACION DE ANEMIA
CREATE TABLE Dim_ClasificacionAnemia (
    Id_Clasificacion INT IDENTITY(1,1) PRIMARY KEY,
    Codigo_Clasificacion VARCHAR(10),
    Descripcion VARCHAR(50)
);
GO

--TABLA DE HECHOS
CREATE TABLE Fact_Gestantes (
    Id_Hecho INT IDENTITY(1,1) PRIMARY KEY,

    Id_Tiempo INT,
    Id_Financiador INT,
    Id_Clasificacion INT,

    cod_pc VARCHAR(20),

    hemoglobina_1 DECIMAL(5,2),
    hemoglobina_2 DECIMAL(5,2),
    hemoglobina_3 DECIMAL(5,2),
    hemoglobina_4 DECIMAL(5,2),
    hemoglobina_5 DECIMAL(5,2),

    CantidadRegistros INT DEFAULT 1,

    FOREIGN KEY (Id_Tiempo)
        REFERENCES Dim_Tiempo(Id_Tiempo),

    FOREIGN KEY (Id_Financiador)
        REFERENCES Dim_Financiador(Id_Financiador),

    FOREIGN KEY (Id_Clasificacion)
        REFERENCES Dim_ClasificacionAnemia(Id_Clasificacion)
);
GO

-------------------------------------------------------------------
USE DW_DatosSalud_Junin;
GO

/*Cargar dimensiones*/
--Dim_Tiempo:
USE DW_DatosSalud_Junin;
GO
INSERT INTO Dim_Tiempo (Fecha, Anio, Mes, Trimestre)
SELECT Fecha, Anio, Mes, Trimestre
FROM stg_Dim_Tiempo
ORDER BY Id_Tiempo;
GO
--Dim_Financiador
USE DW_DatosSalud_Junin;
GO
BULK INSERT Dim_Financiador
FROM 'C:\SQL\DW\Dim_Financiador.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
--Dim_ClasifiacionAnemia
CREATE TABLE stg_Fact_Gestantes (
    fecha_dosaje_1 DATE,
    Id_Financiador INT,
    valor_labo VARCHAR(10),
    cod_pc VARCHAR(20),
    hemoglobina_1 DECIMAL(5,2),
    hemoglobina_2 DECIMAL(5,2),
    hemoglobina_3 DECIMAL(5,2),
    hemoglobina_4 DECIMAL(5,2),
    hemoglobina_5 DECIMAL(5,2)
);
GO

BULK INSERT stg_Fact_Gestantes
FROM 'C:\SQL\DW\Fact_Gestantes.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a'
);
GO

INSERT INTO Fact_Gestantes (
    Id_Tiempo,
    Id_Financiador,
    Id_Clasificacion,
    cod_pc,
    hemoglobina_1,
    hemoglobina_2,
    hemoglobina_3,
    hemoglobina_4,
    hemoglobina_5
)
SELECT
    t.Id_Tiempo,
    f.Id_Financiador,
    c.Id_Clasificacion,
    g.cod_pc,
    g.hemoglobina_1,
    g.hemoglobina_2,
    g.hemoglobina_3,
    g.hemoglobina_4,
    g.hemoglobina_5
FROM stg_Fact_Gestantes g
LEFT JOIN Dim_Tiempo t
    ON t.Fecha = g.fecha_dosaje_1
LEFT JOIN Dim_Financiador f
    ON f.Id_Financiador = g.Id_Financiador
LEFT JOIN Dim_ClasificacionAnemia c
    ON c.Codigo_Clasificacion = g.valor_labo;
GO

------------------------------------------------------------
/*Creación de la tabla de log*/
USE DW_DatosSalud_Junin;
GO

CREATE TABLE Log_ETL (
    Id_Log INT IDENTITY(1,1) PRIMARY KEY,
    Proceso VARCHAR(50),
    FechaInicio DATETIME,
    FechaFin DATETIME,
    Registros INT,
    Estado VARCHAR(20)
);
GO

/*Registro de las acciones*/
INSERT INTO Log_ETL
    (Proceso, FechaInicio, FechaFin, Registros, Estado)
VALUES
    ('Carga Dim_Tiempo', GETDATE(), GETDATE(), 558, 'EXITOSO'),
    ('Carga Dim_Financiador', GETDATE(), GETDATE(),
        (SELECT COUNT(*) FROM Dim_Financiador), 'EXITOSO'),
    ('Carga Dim_ClasificacionAnemia', GETDATE(), GETDATE(),
        (SELECT COUNT(*) FROM Dim_ClasificacionAnemia), 'EXITOSO'),
    ('Carga Fact_Gestantes', GETDATE(), GETDATE(),
        (SELECT COUNT(*) FROM Fact_Gestantes), 'EXITOSO');
GO

/*Verificacion de la tabla de log*/
SELECT *
FROM Log_ETL
ORDER BY Id_Log;
GO

SELECT
    (SELECT COUNT(*) FROM Dim_Tiempo) AS Dim_Tiempo,
    (SELECT COUNT(*) FROM Dim_Financiador) AS Dim_Financiador,
    (SELECT COUNT(*) FROM Dim_ClasificacionAnemia) AS Dim_Clasificacion,
    (SELECT COUNT(*) FROM Fact_Gestantes) AS Fact_Gestantes;
GO
