-- =========================================
-- VISTA: vw_OcupacionPorTurno
-- Ocupación del complejo por día de la semana y turno (Mañana/Tarde/Noche).
-- Autor: Tomás Oliveres — Base de Datos 2 (TPI Complejo Deportivo)
--
-- Por cada celda día x turno informa:
--   - CantidadReservas    : volumen de reservas efectivas (cuánta demanda hubo).
--   - PorcentajeOcupacion : cupos usados sobre cupos ofrecidos.
--
-- Regla de negocio: cada reserva ocupa un cupo de 1 hora, así que el uso y la
-- capacidad se miden en la misma unidad. La capacidad se asume FIJA: todas las
-- canchas activas operan el turno completo todos los días.
-- =========================================

USE BBDD2_TPI_GRUPO45;
GO

-- Fija el inicio de semana en Lunes para que DATEPART(WEEKDAY) dé el mismo
-- resultado en cualquier servidor (1=Lunes ... 7=Domingo).
SET DATEFIRST 1;
GO

CREATE OR ALTER VIEW vw_OcupacionPorTurno AS

-- Paso 1: etiqueta cada reserva efectiva con su día de la semana y su turno.
WITH ReservasClasificadas AS (
    SELECT
        r.Fecha,
        (DATEPART(WEEKDAY, r.Fecha) - 1) AS DiaNum,   -- 0=Lunes ... 6=Domingo
        CASE
            WHEN r.HoraInicio >= '08:00' AND r.HoraInicio < '12:00' THEN 1
            WHEN r.HoraInicio >= '12:00' AND r.HoraInicio < '18:00' THEN 2
            WHEN r.HoraInicio >= '18:00' AND r.HoraInicio < '22:00' THEN 3
        END AS TurnoOrden                             -- 1=Mañana 2=Tarde 3=Noche
    FROM Reservas r
    WHERE r.IDEstado NOT IN (3, 4)            -- excluye Cancelada y No Asistió: no hubo uso real
      AND r.Fecha < CAST(GETDATE() AS DATE)   -- solo ocupación ya ocurrida (no cuenta reservas futuras)
)

-- Paso 2: agrupa por día y turno, cuenta el volumen y calcula el % de ocupación.
SELECT
    DiaNum,
    CASE DiaNum
        WHEN 0 THEN 'Lunes'   WHEN 1 THEN 'Martes'  WHEN 2 THEN 'Miércoles'
        WHEN 3 THEN 'Jueves'  WHEN 4 THEN 'Viernes' WHEN 5 THEN 'Sábado'
        WHEN 6 THEN 'Domingo'
    END AS Dia,
    TurnoOrden,
    CASE TurnoOrden WHEN 1 THEN 'Mañana' WHEN 2 THEN 'Tarde' WHEN 3 THEN 'Noche' END AS Turno,

    COUNT(*) AS CantidadReservas,    -- cada reserva es un cupo de 1 hora

    -- % = cupos usados / cupos ofrecidos.
    -- Cupos ofrecidos = cupos del turno (Mañana 4, Tarde 6, Noche 4)
    --                 x canchas activas
    --                 x cantidad de fechas: numerador y denominador deben cubrir
    --                   la misma cantidad de días, así el % nunca pasa de 100.
    CAST(
        COUNT(*) * 100.0
        / NULLIF(
              (CASE TurnoOrden WHEN 1 THEN 4 WHEN 2 THEN 6 WHEN 3 THEN 4 END)
              * (SELECT COUNT(*) FROM Canchas WHERE Activa = 1)
              * COUNT(DISTINCT Fecha)
          , 0)                       -- NULLIF evita la división por cero
        AS DECIMAL(5,2)
    ) AS PorcentajeOcupacion

FROM ReservasClasificadas
GROUP BY DiaNum, TurnoOrden;
GO

-- El orden se aplica al consultar.
-- DiaNum y TurnoOrden se muestran para ordenar Lun->Dom y Mañana->Noche.
SELECT Dia, Turno, CantidadReservas, PorcentajeOcupacion
FROM vw_OcupacionPorTurno
ORDER BY DiaNum, TurnoOrden;
