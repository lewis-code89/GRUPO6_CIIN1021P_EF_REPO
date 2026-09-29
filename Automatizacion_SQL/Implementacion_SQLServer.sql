
/*CREACIÓN DE LA BASE DE DATOS*/
CREATE DATABASE BD_DatosSalud_Junin;
GO

/*USO DE LA BASE DE DATOS*/
USE BD_DatosSalud_Junin;
GO

/*CREACIÓN DE LA TABLA stg_Gestantes*/
CREATE TABLE stg_Gestantes (
cod_pc VARCHAR(20),
fecha_nacimiento VARCHAR(20),
Id_Financiador VARCHAR(20),
valor_labo VARCHAR(10),
fecha_dosaje_1 VARCHAR(20),
hemoglobina_1 VARCHAR(20),
fecha_dosaje_2 VARCHAR(20),
hemoglobina_2 VARCHAR(20),
fecha_dosaje_3 VARCHAR(20),
hemoglobina_3 VARCHAR(20),
fecha_dosaje_4 VARCHAR(20),
hemoglobina_4 VARCHAR(20),
fecha_dosaje_5 VARCHAR(20),
hemoglobina_5 VARCHAR(20),
fecha_supT1 VARCHAR(20),
fecha_supT2 VARCHAR(20),
fecha_supT3 VARCHAR(20)
);
GO

/*VISUALIZACIÓN DE LA TABLA stg_Gestantes*/
SELECT * FROM stg_Gestantes;

/*CREACIÓN DE LA TABLA Gestantes*/
CREATE TABLE Gestantes (
Id_Gestante INT IDENTITY(1,1) PRIMARY KEY,
cod_pc VARCHAR(20),
fecha_nacimiento DATE,
Id_Financiador INT,
valor_labo VARCHAR(10),
fecha_dosaje_1 DATE,
hemoglobina_1 DECIMAL(5,2),
fecha_dosaje_2 DATE,
hemoglobina_2 DECIMAL(5,2),
fecha_dosaje_3 DATE,
hemoglobina_3 DECIMAL(5,2),
fecha_dosaje_4 DATE,
hemoglobina_4 DECIMAL(5,2),
fecha_dosaje_5 DATE,
hemoglobina_5 DECIMAL(5,2),
fecha_supT1 DATE,
fecha_supT2 DATE,
fecha_supT3 DATE
);
GO

/*VISUALIZACIÓN DE LA CREACIÓN DE LA TABLA Gestantes*/
SELECT * FROM Gestantes;

/*IMPORTACIÓN DEL DATASET DELIMITADO a srg_Gestantes*/
BULK INSERT stg_Gestantes
FROM 'C:\SQL\Dataset_Salud_BigData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

/*CREACIÓN DEL PROCEDIMIENTO sp_IngestarDatos*/
CREATE PROCEDURE sp_IngestarDatos
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM stg_Gestantes)
        BEGIN
            RAISERROR('No existen datos en la tabla de preparación.', 16, 1);
        END;
        SAVE TRANSACTION PuntoIngesta;
        INSERT INTO Gestantes (
            cod_pc,
            fecha_nacimiento,
            Id_Financiador,
            valor_labo,
            fecha_dosaje_1,
            hemoglobina_1,
            fecha_dosaje_2,
            hemoglobina_2,
            fecha_dosaje_3,
            hemoglobina_3,
            fecha_dosaje_4,
            hemoglobina_4,
            fecha_dosaje_5,
            hemoglobina_5,
            fecha_supT1,
            fecha_supT2,
            fecha_supT3
        )
        SELECT
            cod_pc,
            TRY_CONVERT(DATE, fecha_nacimiento, 103),
            TRY_CONVERT(INT, Id_Financiador),
            valor_labo,
            TRY_CONVERT(DATE, fecha_dosaje_1, 103),
            TRY_CONVERT(DECIMAL(5,2), hemoglobina_1),
            TRY_CONVERT(DATE, fecha_dosaje_2, 103),
            TRY_CONVERT(DECIMAL(5,2), hemoglobina_2),
            TRY_CONVERT(DATE, fecha_dosaje_3, 103),
            TRY_CONVERT(DECIMAL(5,2), hemoglobina_3),
            TRY_CONVERT(DATE, fecha_dosaje_4, 103),
            TRY_CONVERT(DECIMAL(5,2), hemoglobina_4),
            TRY_CONVERT(DATE, fecha_dosaje_5, 103),
            TRY_CONVERT(DECIMAL(5,2), hemoglobina_5),
            TRY_CONVERT(DATE, fecha_supT1, 103),
            TRY_CONVERT(DATE, fecha_supT2, 103),
            TRY_CONVERT(DATE, fecha_supT3, 103)
        FROM stg_Gestantes;
        COMMIT TRANSACTION;
        PRINT 'Ingesta realizada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'Error durante la ingesta:';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

/*PROCEDIMIENTO PARA LA LIMPIEZA DE ERRORES*/
CREATE PROCEDURE sp_ValidarDatos
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Punto de guardado de la transacción
        SAVE TRANSACTION PuntoValidacion;
        -- Tabla temporal para almacenar los problemas encontrados
        CREATE TABLE #Errores (
            cod_pc VARCHAR(20),
            TipoProblema VARCHAR(100),
            Detalle VARCHAR(255)
        );
        /* 1. VALIDAR VALOR_LABO */
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'valor_labo',
            'Categoría escrita en minúsculas: ' + valor_labo
        FROM Gestantes
        WHERE LOWER(LTRIM(RTRIM(valor_labo))) = 'lev'
          AND valor_labo <> 'LEV';
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'valor_labo',
            'Valor no válido: ' + valor_labo
        FROM Gestantes
        WHERE LTRIM(RTRIM(valor_labo)) = '2';
        /* 2. VALIDAR HEMOGLOBINA */
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'hemoglobina',
            'Valor anómalo en hemoglobina_1: ' +
            CAST(hemoglobina_1 AS VARCHAR(20))
        FROM Gestantes
        WHERE hemoglobina_1 > 20 OR hemoglobina_1 < 0;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'hemoglobina',
            'Valor anómalo en hemoglobina_2: ' +
            CAST(hemoglobina_2 AS VARCHAR(20))
        FROM Gestantes
        WHERE hemoglobina_2 > 20 OR hemoglobina_2 < 0;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'hemoglobina',
            'Valor anómalo en hemoglobina_3: ' +
            CAST(hemoglobina_3 AS VARCHAR(20))
        FROM Gestantes
        WHERE hemoglobina_3 > 20 OR hemoglobina_3 < 0;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'hemoglobina',
            'Valor anómalo en hemoglobina_4: ' +
            CAST(hemoglobina_4 AS VARCHAR(20))
        FROM Gestantes
        WHERE hemoglobina_4 > 20 OR hemoglobina_4 < 0;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'hemoglobina',
            'Valor anómalo en hemoglobina_5: ' +
            CAST(hemoglobina_5 AS VARCHAR(20))
        FROM Gestantes
        WHERE hemoglobina_5 > 20 OR hemoglobina_5 < 0;
        /* 3. VALIDAR ORDEN DE FECHAS DE DOSAJE */
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'fecha_dosaje',
            'fecha_dosaje_2 es anterior a fecha_dosaje_1'
        FROM Gestantes
        WHERE fecha_dosaje_1 IS NOT NULL
          AND fecha_dosaje_2 IS NOT NULL
          AND fecha_dosaje_2 < fecha_dosaje_1;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'fecha_dosaje',
            'fecha_dosaje_3 es anterior a fecha_dosaje_2'
        FROM Gestantes
        WHERE fecha_dosaje_2 IS NOT NULL
          AND fecha_dosaje_3 IS NOT NULL
          AND fecha_dosaje_3 < fecha_dosaje_2;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'fecha_dosaje',
            'fecha_dosaje_4 es anterior a fecha_dosaje_3'
        FROM Gestantes
        WHERE fecha_dosaje_3 IS NOT NULL
          AND fecha_dosaje_4 IS NOT NULL
          AND fecha_dosaje_4 < fecha_dosaje_3;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'fecha_dosaje',
            'fecha_dosaje_5 es anterior a fecha_dosaje_4'
        FROM Gestantes
        WHERE fecha_dosaje_4 IS NOT NULL
          AND fecha_dosaje_5 IS NOT NULL
          AND fecha_dosaje_5 < fecha_dosaje_4;
        /* 4. VALIDAR ORDEN DE FECHAS DE SUPLEMENTACIÓN */
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'fecha_suplementacion',
            'fecha_supT2 es anterior a fecha_supT1'
        FROM Gestantes
        WHERE fecha_supT1 IS NOT NULL
          AND fecha_supT2 IS NOT NULL
          AND fecha_supT2 < fecha_supT1;
        INSERT INTO #Errores
        SELECT
            cod_pc,
            'fecha_suplementacion',
            'fecha_supT3 es anterior a fecha_supT2'
        FROM Gestantes
        WHERE fecha_supT2 IS NOT NULL
          AND fecha_supT3 IS NOT NULL
          AND fecha_supT3 < fecha_supT2;
        /* MOSTRAR RESULTADOS */
        SELECT *
        FROM #Errores
        ORDER BY cod_pc, TipoProblema;
        COMMIT TRANSACTION;
        PRINT 'Validación ejecutada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'Error durante la validación:';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

/*COMPROBACIÓN DEL PROCEDIMIENTO sp_ValidarDatos*/
EXEC sp_ValidarDatos;
GO

/*CREACIÓN DE LA TABLA LOG*/
CREATE TABLE Log_Auditoria (
    Id_Log INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME DEFAULT GETDATE(),
    Usuario VARCHAR(128),
    Operacion VARCHAR(30),
    Tabla VARCHAR(50),
    Descripcion VARCHAR(255)
);
GO

/*CREACIÓN DEL TRIGGER DE AUDITORÍA*/
CREATE TRIGGER trg_Auditoria_Gestantes
ON Gestantes
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- INSERT
    IF EXISTS (SELECT 1 FROM inserted)
       AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Log_Auditoria
            (Usuario, Operacion, Tabla, Descripcion)
        VALUES
            (SYSTEM_USER, 'INSERT', 'Gestantes',
             'Se insertaron registros en la tabla Gestantes.');
    END;
    -- UPDATE
    IF EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Log_Auditoria
            (Usuario, Operacion, Tabla, Descripcion)
        VALUES
            (SYSTEM_USER, 'UPDATE', 'Gestantes',
             'Se actualizaron registros en la tabla Gestantes.');
    END;
    -- DELETE
    IF NOT EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Log_Auditoria
            (Usuario, Operacion, Tabla, Descripcion)
        VALUES
            (SYSTEM_USER, 'DELETE', 'Gestantes',
             'Se eliminaron registros de la tabla Gestantes.');
    END;
END;
GO

/*CREACIÓN DEL TRIGGER DE INTEGRIDAD*/
CREATE TRIGGER trg_Integridad_Gestantes
ON Gestantes
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    /* 1. VALOR_LABO NO VÁLIDO */
    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Valor de laboratorio no válido: ' + ISNULL(valor_labo, 'NULL')
    FROM inserted
    WHERE valor_labo IS NOT NULL
      AND UPPER(LTRIM(RTRIM(valor_labo))) NOT IN ('LEV', 'MOD', 'SEV');
    /* 2. HEMOGLOBINA ANÓMALA */
    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Valor anómalo en hemoglobina_1: ' +
        CAST(hemoglobina_1 AS VARCHAR(20))
    FROM inserted
    WHERE hemoglobina_1 > 20 OR hemoglobina_1 < 0;
    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Valor anómalo en hemoglobina_2: ' +
        CAST(hemoglobina_2 AS VARCHAR(20))
    FROM inserted
    WHERE hemoglobina_2 > 20 OR hemoglobina_2 < 0;

    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Valor anómalo en hemoglobina_3: ' +
        CAST(hemoglobina_3 AS VARCHAR(20))
    FROM inserted
    WHERE hemoglobina_3 > 20 OR hemoglobina_3 < 0;
    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Valor anómalo en hemoglobina_4: ' +
        CAST(hemoglobina_4 AS VARCHAR(20))
    FROM inserted
    WHERE hemoglobina_4 > 20 OR hemoglobina_4 < 0;
    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Valor anómalo en hemoglobina_5: ' +
        CAST(hemoglobina_5 AS VARCHAR(20))
    FROM inserted
    WHERE hemoglobina_5 > 20 OR hemoglobina_5 < 0;
    /* 3. FECHAS DE DOSAJE FUERA DE ORDEN */
    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Fecha de dosaje fuera del orden cronológico.'
    FROM inserted
    WHERE (fecha_dosaje_1 IS NOT NULL AND fecha_dosaje_2 IS NOT NULL
           AND fecha_dosaje_2 < fecha_dosaje_1)
       OR (fecha_dosaje_2 IS NOT NULL AND fecha_dosaje_3 IS NOT NULL
           AND fecha_dosaje_3 < fecha_dosaje_2)
       OR (fecha_dosaje_3 IS NOT NULL AND fecha_dosaje_4 IS NOT NULL
           AND fecha_dosaje_4 < fecha_dosaje_3)
       OR (fecha_dosaje_4 IS NOT NULL AND fecha_dosaje_5 IS NOT NULL
           AND fecha_dosaje_5 < fecha_dosaje_4);
    /* 4. FECHAS DE SUPLEMENTACIÓN FUERA DE ORDEN */
    INSERT INTO Log_Auditoria
        (Usuario, Operacion, Tabla, Descripcion)
    SELECT
        SYSTEM_USER,
        'INTEGRIDAD',
        'Gestantes',
        'Fecha de suplementación fuera del orden cronológico.'
    FROM inserted
    WHERE (fecha_supT1 IS NOT NULL AND fecha_supT2 IS NOT NULL
           AND fecha_supT2 < fecha_supT1)
       OR (fecha_supT2 IS NOT NULL AND fecha_supT3 IS NOT NULL
           AND fecha_supT3 < fecha_supT2);
END;
GO
/*CASOS PRUEBA PARA EL TRIGGER DE AUDITORIA*/
INSERT INTO Gestantes (
    cod_pc,
    fecha_nacimiento,
    Id_Financiador,
    valor_labo
)
VALUES (
    'PRUEBA001',
    '2000-01-01',
    2,
    'LEV'
);
GO
INSERT INTO Gestantes (
    cod_pc,
    fecha_nacimiento,
    Id_Financiador,
    valor_labo
)
VALUES (
    'PRUEBA002',
    '2000-01-01',
    2,
    'LEV'
);
GO
SELECT *
FROM Log_Auditoria
ORDER BY Id_Log DESC;
GO
UPDATE Gestantes
SET valor_labo = 'MOD'
WHERE cod_pc = 'PRUEBA001';
GO
UPDATE Gestantes
SET valor_labo = 'MOD'
WHERE cod_pc = 'PRUEBA002';
GO
DELETE FROM Gestantes
WHERE cod_pc = 'PRUEBA001';
GO
DELETE FROM Gestantes
WHERE cod_pc = 'PRUEBA002';
GO
SELECT *
FROM Log_Auditoria
ORDER BY Id_Log;
GO

/*CASOS PRUEBA PARA EL TRIGGER DE INTEGRIDAD*/
INSERT INTO Gestantes (
    cod_pc,
    fecha_nacimiento,
    Id_Financiador,
    valor_labo,
    hemoglobina_3
)
VALUES (
    'PRUEBA002',
    '2000-01-01',
    2,
    '2', /*Incosistencia controlada*/
    112 /*Incosistencia controlada*/
);
GO
SELECT *
FROM Log_Auditoria
WHERE Operacion = 'INTEGRIDAD'
ORDER BY Id_Log DESC;
GO

/*CREACIÓN DE UNA FUNCIÓN ESCALAR */
CREATE FUNCTION fn_NormalizarValorLabo
(
    @valor VARCHAR(10)
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @resultado VARCHAR(20);
    SET @valor = UPPER(LTRIM(RTRIM(@valor)));
    SET @resultado =
        CASE
            WHEN @valor = 'LEV' THEN 'LEV'
            WHEN @valor = 'MOD' THEN 'MOD'
            WHEN @valor = 'SEV' THEN 'SEV'
            WHEN @valor = '2' THEN 'INVALIDO'
            WHEN @valor IS NULL OR @valor = '' THEN 'SIN DATO'
            ELSE 'NO RECONOCIDO'
        END;
    RETURN @resultado;
END;
GO

/*VERIFIACIÓN DE LA FUNCIÓN*/
SELECT
    valor_labo,
    dbo.fn_NormalizarValorLabo(valor_labo) AS valor_normalizado
FROM Gestantes
WHERE valor_labo IS NOT NULL;
GO
