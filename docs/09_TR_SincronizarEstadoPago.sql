-- =========================================
-- TRIGGER: Sincronizar estado de pago
-- Autor: Tomas Oliveres
-- Recalcula el estado de pago de la reserva al registrarse un pago.
-- Escrito en modo CONJUNTO ('inserted' puede traer varias filas).
-- No toca reservas Canceladas (evita el problema del reembolso).
-- =========================================

USE BBDD2_TPI_GRUPO45;
GO

CREATE OR ALTER TRIGGER TR_SincronizarEstadoPago
ON Pagos
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE r
    SET r.IDEstadoPago = CASE
            WHEN (SELECT SUM(p.Monto) FROM Pagos p WHERE p.IDReserva = r.IDReserva) >= r.PrecioTotal
                THEN 3   -- Pagado
            WHEN (SELECT SUM(p.Monto) FROM Pagos p WHERE p.IDReserva = r.IDReserva) > 0
                THEN 2   -- Señado
            ELSE r.IDEstadoPago
        END
    FROM Reservas r
    INNER JOIN inserted i ON i.IDReserva = r.IDReserva
    WHERE r.IDEstado <> 3;   -- no tocar Canceladas
END;
GO

-- Uso (automático):  INSERT INTO Pagos (Monto, IDReserva, IDFormaPago) VALUES (2000, 25, 1);
