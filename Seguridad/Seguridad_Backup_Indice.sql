
USE BD_DatosSalud_Junin;
GO

/*CREACIÓN DE LOS ROLES*/
--ROL PARA EL ADMINISTRADOR
CREATE ROLE rol_Administrador;
GO
--ROL PARA EL ANALISTA DE DATOS
CREATE ROLE rol_Analista;
GO
--ROL PARA EL AUDITOR
CREATE ROLE rol_Auditor;
GO

/*CREACIÓN DE PERMISOS PARA CADA ROL*/

--PERMISOS PARA EL ROL DE ADMINISTADOR
-- Permitir consultar y modificar la tabla Gestantes
GRANT SELECT, INSERT, UPDATE, DELETE
ON dbo.Gestantes
TO rol_Administrador;
GO
-- Permitir consultar y modificar la tabla de preparación
GRANT SELECT, INSERT, UPDATE, DELETE
ON dbo.stg_Gestantes
TO rol_Administrador;
GO
-- Permitir consultar los registros de auditoría
GRANT SELECT
ON dbo.Log_Auditoria
TO rol_Administrador;
GO
-- Permitir ejecutar el procedimiento de ingesta
GRANT EXECUTE
ON dbo.sp_IngestarDatos
TO rol_Administrador;
GO
-- Permitir ejecutar el procedimiento de validación
GRANT EXECUTE
ON dbo.sp_ValidarDatos
TO rol_Administrador;
GO

--PERMISOS PARA EL ROL DE ANALISTA
-- Permitir consultar los datos de las gestantes
GRANT SELECT
ON dbo.Gestantes
TO rol_Analista;
GO
-- Permitir consultar los registros de auditoría
GRANT SELECT
ON dbo.Log_Auditoria
TO rol_Analista;
GO
-- Permitir utilizar la función de normalización
GRANT EXECUTE
ON dbo.fn_NormalizarValorLabo
TO rol_Analista;
GO

--PERMISOS PARA EL ROL DE AUDITOR
-- Permitir consultar la bitácora de auditoría
GRANT SELECT
ON dbo.Log_Auditoria
TO rol_Auditor;
GO
-- Permitir consultar los datos para contrastar registros
GRANT SELECT
ON dbo.Gestantes
TO rol_Auditor;
GO

SELECT
    dp.name AS Rol,
    o.name AS Objeto,
    p.permission_name AS Permiso
FROM sys.database_permissions p
INNER JOIN sys.database_principals dp
    ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects o
    ON p.major_id = o.object_id
WHERE dp.name IN (
    'rol_Administrador',
    'rol_Analista',
    'rol_Auditor'
)
ORDER BY dp.name, o.name, p.permission_name;
GO

/*CREACION DEL BACKUP FULL*/
USE master;
GO

-- Backup completo de toda la base de datos
BACKUP DATABASE BD_DatosSalud_Junin
TO DISK = 'C:\SQL\Backups\BD_DatosSalud_Junin_FULL.bak'
WITH
    INIT,
    FORMAT,
    NAME = 'Backup FULL BD_DatosSalud_Junin';
GO

/*CREACION DEL BACKUP DIFERENCIAL*/
USE master;
GO

-- Backup diferencial de la base de datos
BACKUP DATABASE BD_DatosSalud_Junin
TO DISK = 'C:\SQL\Backups\BD_DatosSalud_Junin_DIFF.bak'
WITH
    DIFFERENTIAL,
    INIT,
    NAME = 'Backup DIFFERENTIAL BD_DatosSalud_Junin';
GO

/*PREPARACION PARA LA RESTAURACION*/
USE master;
GO

-- Mostrar los archivos internos del backup FULL
RESTORE FILELISTONLY
FROM DISK = 'C:\SQL\Backups\BD_DatosSalud_Junin_FULL.bak';
GO

/*RESTAURACIÓN DEL BACKUP FULL*/
-- Restaurar el backup FULL en una base de prueba
USE master;
GO
RESTORE DATABASE BD_DatosSalud_Junin_Restore
FROM DISK = 'C:\SQL\Backups\BD_DatosSalud_Junin_FULL.bak'
WITH
    MOVE 'BD_DatosSalud_Junin'
        TO 'C:\SQL\Backups\BD_DatosSalud_Junin_Restore.mdf',

    MOVE 'BD_DatosSalud_Junin_log'
        TO 'C:\SQL\Backups\BD_DatosSalud_Junin_Restore.ldf',

    NORECOVERY,
    REPLACE;
GO

/*RESTAURACION DEL BACKUP DIFERENCIAL*/
USE master;
GO

-- Aplicar el respaldo diferencial sobre la restauración FULL
RESTORE DATABASE BD_DatosSalud_Junin_Restore
FROM DISK = 'C:\SQL\Backups\BD_DatosSalud_Junin_DIFF.bak'
WITH
    RECOVERY;
GO

/*VERIFICACION DE LA RESTAURACION*/
SELECT COUNT(*) AS RegistrosRestaurados
FROM BD_DatosSalud_Junin_Restore.dbo.Gestantes;
GO
/*RENDIMIENTOS ANTES DEL ÍNDICE*/
USE BD_DatosSalud_Junin;
GO
-- Activar estadísticas de rendimiento
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- Consulta crítica que analizaremos
SELECT
    cod_pc,
    valor_labo,
    hemoglobina_1,
    hemoglobina_2,
    hemoglobina_3,
    hemoglobina_4,
    hemoglobina_5
FROM Gestantes
WHERE cod_pc = '*****561';
-- Desactivar estadísticas
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/*CREACION DEL INDICE*/
USE BD_DatosSalud_Junin;
GO
-- Crear un índice para acelerar las búsquedas por cod_pc
CREATE NONCLUSTERED INDEX IX_Gestantes_cod_pc
ON Gestantes(cod_pc);
GO

/*RENDIMIENTO DESPUES DE LA CREACION DEL INDICE*/
USE BD_DatosSalud_Junin;
GO
-- Activar estadísticas de rendimiento
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- La misma consulta utilizada antes del índice
SELECT
    cod_pc,
    valor_labo,
    hemoglobina_1,
    hemoglobina_2,
    hemoglobina_3,
    hemoglobina_4,
    hemoglobina_5
FROM Gestantes
WHERE cod_pc = '*****561';
-- Desactivar estadísticas
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO