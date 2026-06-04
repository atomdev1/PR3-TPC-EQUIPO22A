USE BBDD2_TPI_GRUPO45;
GO

-- =========================================
-- DATOS INICIALES
-- =========================================

INSERT INTO Roles (NombreRol) VALUES
    ('Administrador'), ('Recepcionista'), ('Encargado de Cancha'), ('Cliente');

INSERT INTO EstadoReserva (NombreEstado) VALUES
    ('Nueva'), ('Reprogramada'), ('Cancelada'), ('No Asistió'), ('Finalizada');

INSERT INTO EstadoPago (NombreEstadoPago) VALUES
    ('Pendiente'), ('Señado'), ('Pagado'), ('Reembolsado');

INSERT INTO FormasPago (NombreFormaPago) VALUES
    ('Efectivo'), ('Transferencia'), ('Tarjeta de Débito'), ('Tarjeta de Crédito'), ('MercadoPago');

INSERT INTO EstadoCupon (NombreEstado) VALUES
    ('Activo'), ('Canjeado'), ('Vencido'), ('Agotado'), ('Anulado');

INSERT INTO TipoDescuento (Nombre) VALUES
    ('Porcentaje'), ('MontoFijo'), ('Reserva gratis');

INSERT INTO Deportes (Nombre, DuracionMinutos) VALUES
    ('Fútbol', 60), ('Tenis', 60), ('Pádel', 60), ('Básquet', 60), ('Vóley', 60);
GO


-- =========================================
-- DATOS DE PRUEBA
-- =========================================

-- -------------------------------------------------------
-- USUARIOS
-- Password de todos: 'password123' (SHA-256)
-- IDRol: 1=Administrador | 2=Recepcionista | 3=Encargado de Cancha | 4=Cliente
-- -------------------------------------------------------
INSERT INTO Usuarios (DNI, Nombre, Apellido, Telefono, Email, Password, FechaNacimiento, FechaRegistro, Activo, CantidadAsistencias, IDRol)
VALUES
    -- Staff
    ('20111111', 'Carlos',    'Gómez',     '1155551111', 'cgomez@complejo.com',  'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1980-05-15', '2024-01-01', 1, 0,  1),
    ('20222222', 'María',     'López',     '1155552222', 'mlopez@complejo.com',  'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1990-08-20', '2024-01-01', 1, 0,  2),
    ('20333333', 'Juan',      'Pérez',     '1155553333', 'jperez@complejo.com',  'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1988-03-10', '2024-01-01', 1, 0,  2),
    ('20444444', 'Roberto',   'Silva',     '1155554444', 'rsilva@complejo.com',  'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1985-11-25', '2024-01-01', 1, 0,  3),
    -- Clientes
    ('27555555', 'Lucas',     'Martínez',  '1166661111', 'lmartinez@gmail.com',  'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1995-02-14', '2024-03-10', 1, 12, 4),
    ('27666666', 'Sofía',     'Rodríguez', '1166662222', 'srodriguez@gmail.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1998-07-30', '2024-03-15', 1, 8,  4),
    ('27777777', 'Matías',    'Fernández', '1166663333', 'mfernandez@gmail.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1993-12-05', '2024-04-01', 1, 15, 4),
    ('27888888', 'Valentina', 'García',    '1166664444', 'vgarcia@gmail.com',    'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '2000-04-18', '2024-04-20', 1, 5,  4),
    ('27999999', 'Agustín',   'Torres',    '1166665555', 'atorres@gmail.com',    'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1992-09-22', '2024-05-05', 1, 10, 4),
    ('28111111', 'Florencia', 'Díaz',      '1166666666', 'fdiaz@gmail.com',      'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1997-01-08', '2024-05-12', 1, 3,  4),
    ('28222222', 'Nicolás',   'Sánchez',   '1166667777', 'nsanchez@gmail.com',   'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1991-06-17', '2024-06-01', 1, 7,  4),
    ('28333333', 'Camila',    'Ruiz',      '1166668888', 'cruiz@gmail.com',      'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1999-10-29', '2024-06-15', 1, 2,  4);
GO


-- -------------------------------------------------------
-- CANCHAS
-- IDDeporte: 1=Fútbol | 2=Tenis | 3=Pádel | 4=Básquet
-- -------------------------------------------------------
INSERT INTO Canchas (Numero, NombreFantasia, Descripcion, CapacidadJugadores, Precio, MontoSena, Activa, IDDeporte)
VALUES
    (1, 'La Bombonera',    'Cancha de fútbol 5 con césped sintético',           10, 6000.00, 2000.00, 1, 1),
    (2, 'El Monumental',   'Cancha de fútbol 5 con césped sintético iluminada', 10, 6000.00, 2000.00, 1, 1),
    (3, 'La Raqueta',      'Cancha de tenis con superficie dura',               4,  3500.00, 1000.00, 1, 2),
    (4, 'Pádel 1',         'Cancha de pádel cubierta',                         4,  4000.00, 1500.00, 1, 3),
    (5, 'Básquet Central', 'Cancha de básquet con tableros oficiales',          10, 4500.00, 1500.00, 1, 4);
GO


-- -------------------------------------------------------
-- DISPONIBILIDAD DE CANCHAS
-- DiaSemana: 0=Lunes | 1=Martes | ... | 5=Sábado | 6=Domingo
-- Lun-Vie: 08:00-22:00 | Sáb-Dom: 08:00-20:00
-- -------------------------------------------------------
INSERT INTO DisponibilidadCanchas (IDCancha, DiaSemana, HoraApertura, HoraCierre, Activa)
VALUES
    (1,0,'08:00','22:00',1),(1,1,'08:00','22:00',1),(1,2,'08:00','22:00',1),(1,3,'08:00','22:00',1),(1,4,'08:00','22:00',1),(1,5,'08:00','20:00',1),(1,6,'08:00','20:00',1),
    (2,0,'08:00','22:00',1),(2,1,'08:00','22:00',1),(2,2,'08:00','22:00',1),(2,3,'08:00','22:00',1),(2,4,'08:00','22:00',1),(2,5,'08:00','20:00',1),(2,6,'08:00','20:00',1),
    (3,0,'08:00','22:00',1),(3,1,'08:00','22:00',1),(3,2,'08:00','22:00',1),(3,3,'08:00','22:00',1),(3,4,'08:00','22:00',1),(3,5,'08:00','20:00',1),(3,6,'08:00','20:00',1),
    (4,0,'08:00','22:00',1),(4,1,'08:00','22:00',1),(4,2,'08:00','22:00',1),(4,3,'08:00','22:00',1),(4,4,'08:00','22:00',1),(4,5,'08:00','20:00',1),(4,6,'08:00','20:00',1),
    (5,0,'08:00','22:00',1),(5,1,'08:00','22:00',1),(5,2,'08:00','22:00',1),(5,3,'08:00','22:00',1),(5,4,'08:00','22:00',1),(5,5,'08:00','20:00',1),(5,6,'08:00','20:00',1);
GO


-- -------------------------------------------------------
-- CUPONES (personales: cada cupón pertenece a UN cliente por IDUsuario)
-- IDEstadoCupon:   1=Activo | 2=Canjeado | 3=Vencido | 4=Agotado
-- IDTipoDescuento: 1=Porcentaje | 2=MontoFijo | 3=Reserva gratis
-- IDUsuario:       5=Lucas | 7=Matías | 9=Agustín | 11=Nicolás
-- -------------------------------------------------------
INSERT INTO Cupones (Codigo, Descripcion, IDEstadoCupon, IDTipoDescuento, ValorDescuento, ReservasRequeridas, ValidoDesde, ValidoHasta, LimiteUsos, UsosActuales, IDUsuario)
VALUES
    ('DESC-LUC-001', '20% de descuento por fidelidad (ya utilizado)',    2, 1, 20.00,  10, '2026-01-01', '2026-12-31', 1, 1, 5),
    ('FREE-MAT-001', 'Reserva gratis por alcanzar 15 asistencias',       1, 3, NULL,   10, '2026-06-01', '2026-12-31', 1, 0, 7),
    ('DESC-AGU-001', '10% de descuento acumulado (histórico canjeado)',   2, 1, 10.00,  10, '2025-01-01', '2025-12-31', 1, 1, 9),
    ('DESC-NIC-001', '$500 de descuento por fidelidad',                  1, 2, 500.00, 10, '2026-05-01', '2026-11-30', 1, 0, 11);
GO


-- -------------------------------------------------------
-- RESERVAS
-- IDEstado:     1=Nueva | 2=Reprogramada | 3=Cancelada | 4=No Asistió | 5=Finalizada
-- IDEstadoPago: 1=Pendiente | 2=Señado | 3=Pagado | 4=Reembolsado
-- Staff:        2=María López | 3=Juan Pérez | NULL=autogestión web
-- -------------------------------------------------------
INSERT INTO Reservas (Fecha, HoraInicio, HoraFin, PrecioTotal, Observaciones, IDUsuario_Cliente, IDUsuario_Staff, IDCancha, IDEstado, IDEstadoPago, IDCupon)
VALUES
    -- Finalizadas y pagadas (históricas)
    ('2026-05-10', '10:00', '11:00', 6000.00, NULL,                             5,  2,    1, 5, 3, NULL),  -- IDReserva 1
    ('2026-05-10', '11:00', '12:00', 3500.00, NULL,                             6,  NULL, 3, 5, 3, NULL),  -- IDReserva 2
    ('2026-05-12', '18:00', '19:00', 6000.00, 'Torneo interno',                 7,  3,    2, 5, 3, NULL),  -- IDReserva 3
    ('2026-05-14', '09:00', '10:00', 4000.00, NULL,                             8,  NULL, 4, 5, 3, NULL),  -- IDReserva 4
    ('2026-05-15', '20:00', '21:00', 6000.00, NULL,                             9,  2,    1, 5, 3, NULL),  -- IDReserva 5
    ('2026-05-17', '10:00', '11:00', 4500.00, NULL,                             10, NULL, 5, 5, 3, NULL),  -- IDReserva 6
    ('2026-05-20', '16:00', '17:00', 6000.00, NULL,                             11, 3,    2, 5, 3, NULL),  -- IDReserva 7
    ('2026-05-22', '08:00', '09:00', 3500.00, NULL,                             12, NULL, 3, 5, 3, NULL),  -- IDReserva 8
    -- Cancelada con reembolso
    ('2026-05-25', '14:00', '15:00', 6000.00, 'Cliente canceló por lluvia',     5,  2,    1, 3, 4, NULL),  -- IDReserva 9
    -- No Asistió (pagó pero no vino)
    ('2026-05-28', '19:00', '20:00', 4000.00, NULL,                             6,  NULL, 4, 4, 3, NULL),  -- IDReserva 10
    -- Finalizada con cupón de 20% (6000 * 0.80 = 4800)
    ('2026-05-30', '10:00', '11:00', 4800.00, 'Cupón DESC-LUC-001 aplicado',    5,  NULL, 1, 5, 3, 1),    -- IDReserva 11
    -- Próximas con seña abonada
    ('2026-06-10', '18:00', '19:00', 6000.00, NULL,                             7,  NULL, 2, 1, 2, NULL),  -- IDReserva 12
    ('2026-06-11', '09:00', '10:00', 3500.00, NULL,                             8,  NULL, 3, 1, 2, NULL),  -- IDReserva 13
    ('2026-06-12', '20:00', '21:00', 4000.00, NULL,                             9,  NULL, 4, 1, 2, NULL),  -- IDReserva 14
    -- Futuras sin seña
    ('2026-06-15', '10:00', '11:00', 6000.00, NULL,                             10, NULL, 1, 1, 1, NULL),  -- IDReserva 15
    ('2026-06-16', '16:00', '17:00', 4500.00, NULL,                             11, NULL, 5, 1, 1, NULL),  -- IDReserva 16
    ('2026-06-18', '08:00', '09:00', 6000.00, NULL,                             12, NULL, 2, 1, 1, NULL),  -- IDReserva 17
    -- Reserva gratis con cupón FREE-MAT-001
    ('2026-06-20', '14:00', '15:00', 0.00,    'Reserva gratis FREE-MAT-001',    7,  NULL, 1, 1, 3, 2);    -- IDReserva 18
GO


-- -------------------------------------------------------
-- PAGOS
-- Solo para reservas con IDEstadoPago = 2 (Señado), 3 (Pagado) o 4 (Reembolsado)
-- IDFormaPago: 1=Efectivo | 2=Transferencia | 3=Débito | 4=Crédito | 5=MercadoPago
-- -------------------------------------------------------
INSERT INTO Pagos (Monto, FechaHora, IDReserva, IDFormaPago)
VALUES
    -- Pagos completos de reservas finalizadas (IDReserva 1-8)
    (6000.00, '2026-05-10 10:30', 1,  1),  -- Efectivo
    (3500.00, '2026-05-10 11:15', 2,  5),  -- MercadoPago
    (6000.00, '2026-05-12 18:10', 3,  2),  -- Transferencia
    (4000.00, '2026-05-14 09:05', 4,  4),  -- Crédito
    (6000.00, '2026-05-15 20:20', 5,  1),  -- Efectivo
    (4500.00, '2026-05-17 10:15', 6,  3),  -- Débito
    (6000.00, '2026-05-20 16:05', 7,  5),  -- MercadoPago
    (3500.00, '2026-05-22 08:10', 8,  2),  -- Transferencia
    -- Cancelada: pago original + reembolso (IDReserva 9)
    (6000.00, '2026-05-25 10:00', 9,  2),  -- Pago original
    (6000.00, '2026-05-26 09:00', 9,  2),  -- Reembolso
    -- No Asistió, pero había pagado (IDReserva 10)
    (4000.00, '2026-05-28 15:30', 10, 1),  -- Efectivo
    -- Finalizada con cupón (IDReserva 11)
    (4800.00, '2026-05-30 10:10', 11, 5),  -- MercadoPago
    -- Señas de reservas próximas (IDReserva 12-14)
    (2000.00, '2026-06-05 12:00', 12, 2),  -- Seña transferencia
    (1000.00, '2026-06-05 14:00', 13, 5),  -- Seña MercadoPago
    (1500.00, '2026-06-06 09:00', 14, 3);  -- Seña débito
GO