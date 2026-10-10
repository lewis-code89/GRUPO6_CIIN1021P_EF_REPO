
CREATE DATABASE DW_DatosSalud_Junin;
GO

USE DW_DatosSalud_Junin;
GO

-- Dimensiones
CREATE TABLE Dim_Tiempo (
    Id_Tiempo INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    Anio INT,
    Mes INT,
    Trimestre INT
);

CREATE TABLE Dim_Financiador (
    Id_Financiador INT PRIMARY KEY,
    Descripcion VARCHAR(30) NOT NULL
);

CREATE TABLE Dim_ClasificacionAnemia (
    Id_Clasificacion INT IDENTITY(1,1) PRIMARY KEY,
    Codigo_Clasificacion VARCHAR(10),
    Descripcion VARCHAR(50)
);

INSERT INTO Dim_Financiador VALUES
(1, 'USUARIO'),
(2, 'SIS'),
(3, 'ESSALUD'),
(4, 'SOAT'),
(5, 'FAP'),
(6, 'SANIDAD NAVAL'),
(7, 'SANIDAD EP'),
(8, 'SANIDAD PNP'),
(9, 'PRIVADOS'),
(10, 'OTROS'),
(11, 'EXONERADO');

-- Tabla de hechos
CREATE TABLE Fact_Gestantes (
    Id_Hecho INT IDENTITY(1,1) PRIMARY KEY,
    Id_Tiempo INT NOT NULL,
    Id_Financiador INT,
    Id_Clasificacion INT NOT NULL,
    cod_pc VARCHAR(20),
    hemoglobina_1 DECIMAL(5,2),
    hemoglobina_2 DECIMAL(5,2),
    hemoglobina_3 DECIMAL(5,2),
    hemoglobina_4 DECIMAL(5,2),
    hemoglobina_5 DECIMAL(5,2),
    CantidadRegistros INT DEFAULT 1,
    FOREIGN KEY (Id_Tiempo) REFERENCES Dim_Tiempo(Id_Tiempo),
    FOREIGN KEY (Id_Financiador) REFERENCES Dim_Financiador(Id_Financiador),
    FOREIGN KEY (Id_Clasificacion) REFERENCES Dim_ClasificacionAnemia(Id_Clasificacion)
);

-- Tablas temporales: estructura de los CSV
CREATE TABLE stg_Dim_Tiempo (
    Id_Tiempo INT,
    Fecha DATE,
    Anio INT,
    Mes INT,
    Trimestre INT
);

CREATE TABLE stg_Dim_Financiador (
    Id_Financiador INT
);

CREATE TABLE stg_Dim_ClasificacionAnemia (
    Id_Clasificacion INT,
    Codigo_Clasificacion VARCHAR(10),
    Descripcion VARCHAR(50)
);

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

---------------Ingreso de datos-----------------
BULK INSERT stg_Dim_Tiempo
FROM 'C:\SQL\DW\Dim_Tiempo.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001'
);

BULK INSERT stg_Dim_Financiador
FROM 'C:\SQL\DW\Dim_Financiador.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001'
);

BULK INSERT stg_Dim_ClasificacionAnemia
FROM 'C:\SQL\DW\Dim_ClasificacionAnemia.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001'
);

BULK INSERT stg_Fact_Gestantes
FROM 'C:\SQL\DW\Fact_Gestantes.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001'
);
GO
--CARGA DE DIMENSIONES----
-- Cargar dimensión tiempo
INSERT INTO Dim_Tiempo (Fecha, Anio, Mes, Trimestre)
SELECT Fecha, Anio, Mes, Trimestre
FROM stg_Dim_Tiempo
ORDER BY Fecha;

-- Cargar dimensión clasificación de anemia
SET IDENTITY_INSERT Dim_ClasificacionAnemia ON;

INSERT INTO Dim_ClasificacionAnemia
    (Id_Clasificacion, Codigo_Clasificacion, Descripcion)
SELECT Id_Clasificacion, Codigo_Clasificacion, Descripcion
FROM stg_Dim_ClasificacionAnemia;

SET IDENTITY_INSERT Dim_ClasificacionAnemia OFF;
GO

-- Verificar dimensiones
SELECT 'Dim_Tiempo' AS Tabla, COUNT(*) AS Registros
FROM Dim_Tiempo
UNION ALL
SELECT 'Dim_Financiador', COUNT(*)
FROM Dim_Financiador
UNION ALL
SELECT 'Dim_ClasificacionAnemia', COUNT(*)
FROM Dim_ClasificacionAnemia;
GO

-------error----------
ALTER TABLE Fact_Gestantes
ALTER COLUMN Id_Tiempo INT NULL;
ALTER TABLE Fact_Gestantes
ALTER COLUMN Id_Clasificacion INT NULL;
GO

--Ingreso de datos a la tabla de hechos
SELECT COUNT(*) AS TotalHechos
FROM Fact_Gestantes;

SELECT
    SUM(CASE WHEN Id_Tiempo IS NULL THEN 1 ELSE 0 END) AS SinFecha,
    SUM(CASE WHEN Id_Clasificacion IS NULL THEN 1 ELSE 0 END) AS SinClasificacion,
    SUM(CASE WHEN Id_Financiador IS NULL THEN 1 ELSE 0 END) AS SinFinanciador
FROM Fact_Gestantes;

-- Verificar cantidad de registros
SELECT 'Dim_Tiempo' AS Tabla, COUNT(*) AS Registros
FROM Dim_Tiempo
UNION ALL
SELECT 'Dim_Financiador', COUNT(*)
FROM Dim_Financiador
UNION ALL
SELECT 'Dim_ClasificacionAnemia', COUNT(*)
FROM Dim_ClasificacionAnemia
UNION ALL
SELECT 'Fact_Gestantes', COUNT(*)
FROM Fact_Gestantes;

-- Verificar claves sin correspondencia
SELECT
    SUM(CASE WHEN t.Id_Tiempo IS NULL
                  AND h.Id_Tiempo IS NOT NULL
             THEN 1 ELSE 0 END) AS FechasSinCorrespondencia,
    SUM(CASE WHEN c.Id_Clasificacion IS NULL
                  AND h.Id_Clasificacion IS NOT NULL
             THEN 1 ELSE 0 END) AS ClasificacionesSinCorrespondencia,
    SUM(CASE WHEN f.Id_Financiador IS NULL
                  AND h.Id_Financiador IS NOT NULL
             THEN 1 ELSE 0 END) AS FinanciadoresSinCorrespondencia
FROM Fact_Gestantes h
LEFT JOIN Dim_Tiempo t
    ON h.Id_Tiempo = t.Id_Tiempo
LEFT JOIN Dim_ClasificacionAnemia c
    ON h.Id_Clasificacion = c.Id_Clasificacion
LEFT JOIN Dim_Financiador f
    ON h.Id_Financiador = f.Id_Financiador;
GO
-----------------------------------------------------
INSERT INTO Fact_Gestantes (
    Id_Tiempo,
    Id_Financiador,
    Id_Clasificacion,
    cod_pc,
    hemoglobina_1,
    hemoglobina_2,
    hemoglobina_3,
    hemoglobina_4,
    hemoglobina_5,
    CantidadRegistros
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
    g.hemoglobina_5,
    1
FROM stg_Fact_Gestantes g
LEFT JOIN Dim_Tiempo t
    ON t.Fecha = g.fecha_dosaje_1
LEFT JOIN Dim_Financiador f
    ON f.Id_Financiador = g.Id_Financiador
LEFT JOIN Dim_ClasificacionAnemia c
    ON c.Codigo_Clasificacion = g.valor_labo;
GO
