
USE BD_DatosSalud_Junin;
GO

DECLARE @Inicio DATETIME2 = SYSDATETIME();
SELECT
    valor_labo,
    COUNT(*) AS Cantidad
FROM Gestantes
GROUP BY valor_labo
ORDER BY Cantidad DESC;
DECLARE @Fin DATETIME2 = SYSDATETIME();
SELECT
    DATEDIFF(MILLISECOND, @Inicio, @Fin) AS TiempoMilisegundos;