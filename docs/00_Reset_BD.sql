-- =========================================
-- RESET de la base de datos
-- Borra la BD si existe. Después correr en orden:
--   01_Creacion_BD.sql  ->  02_Datos_Iniciales.sql
-- =========================================

USE master;
GO

IF DB_ID('BBDD2_TPI_GRUPO45') IS NOT NULL
BEGIN
    -- Corta cualquier conexión abierta a la base (si no, el DROP falla)
    ALTER DATABASE BBDD2_TPI_GRUPO45 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BBDD2_TPI_GRUPO45;
END
GO
