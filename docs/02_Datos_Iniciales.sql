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
    ('Porcentaje'), ('Reserva gratis');

INSERT INTO Deportes (Nombre, DuracionMinutos, Activa) VALUES
    ('Fútbol', 60, 1), ('Tenis', 60, 1), ('Pádel', 60, 1), ('Básquet', 60, 1), ('Vóley', 60, 1);
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
    -- CantidadAsistencias alineada a los umbrales de fidelidad (5/10/15/25)
    -- para que los cupones que tiene cada uno reflejen el concepto.
    ('27555555', 'Lucas',     'Martínez',  '1166661111', 'lmartinez@gmail.com',  'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1995-02-14', '2024-03-10', 1, 27, 4),  -- 5  Leyenda (pasó los 4)
    ('27666666', 'Sofía',     'Rodríguez', '1166662222', 'srodriguez@gmail.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1998-07-30', '2024-03-15', 1, 12, 4),  -- 6  tiene 10% y 25%
    ('27777777', 'Matías',    'Fernández', '1166663333', 'mfernandez@gmail.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1993-12-05', '2024-04-01', 1, 16, 4),  -- 7  tiene 10/25/50
    ('27888888', 'Valentina', 'García',    '1166664444', 'vgarcia@gmail.com',    'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '2000-04-18', '2024-04-20', 1, 6,  4),  -- 8  solo 10%
    ('27999999', 'Agustín',   'Torres',    '1166665555', 'atorres@gmail.com',    'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1992-09-22', '2024-05-05', 1, 10, 4),  -- 9  tiene 10% y 25%
    ('28111111', 'Florencia', 'Díaz',      '1166666666', 'fdiaz@gmail.com',      'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1997-01-08', '2024-05-12', 1, 3,  4),  -- 10 sin cupones (todo en camino)
    ('28222222', 'Nicolás',   'Sánchez',   '1166667777', 'nsanchez@gmail.com',   'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1991-06-17', '2024-06-01', 1, 23, 4),  -- 11 a 2 reservas de la Leyenda
    ('28333333', 'Camila',    'Ruiz',      '1166668888', 'cruiz@gmail.com',      'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1999-10-29', '2024-06-15', 1, 1,  4),  -- 12 recién empieza
    ('28444444', 'Tomás',     'Acosta',    '1166669999', 'tacosta@gmail.com',    'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1994-03-21', '2024-02-20', 1, 15, 4),  -- 13 tiene uno vencido
    ('28555555', 'Julieta',   'Romero',    '1166660000', 'jromero@gmail.com',    'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '1996-11-11', '2024-03-05', 1, 8,  4);  -- 14 tiene uno agotado
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
-- Simulan lo que generará el trigger: a cada cliente le aparece un cupón por
-- cada umbral de fidelidad que ya superó. ReservasRequeridas = umbral con que se ganó.
-- IDEstadoCupon:   1=Activo | 2=Canjeado | 3=Vencido | 4=Agotado
-- IDTipoDescuento: 1=Porcentaje | 2=Reserva gratis
-- -------------------------------------------------------
INSERT INTO Cupones (Codigo, Descripcion, IDEstadoCupon, IDTipoDescuento, ValorDescuento, ReservasRequeridas, ValidoDesde, ValidoHasta, LimiteUsos, UsosActuales, IDUsuario)
VALUES
    -- Lucas (5) — 27 reservas, Leyenda: ganó los 4 beneficios
    ('FID-LUC-05', '10% OFF — Primer paso',          2, 1, 10.00, 5,  '2026-02-01', '2026-03-03', 1, 1, 5),   -- IDCupon 1  Canjeado
    ('FID-LUC-10', '25% OFF — Cliente frecuente',    2, 1, 25.00, 10, '2026-03-20', '2026-04-19', 1, 1, 5),   -- IDCupon 2  Canjeado
    ('FID-LUC-15', '50% OFF — Jugador fiel',         1, 1, 50.00, 15, '2026-05-25', '2026-07-24', 1, 0, 5),   -- IDCupon 3  Activo
    ('FID-LUC-25', 'Reserva gratis — Leyenda',       1, 2, NULL,  25, '2026-05-25', '2026-07-24', 1, 0, 5),   -- IDCupon 4  Activo
    -- Sofía (6) — 12 reservas: 10% y 25%
    ('FID-SOF-05', '10% OFF — Primer paso',          2, 1, 10.00, 5,  '2026-03-01', '2026-03-31', 1, 1, 6),   -- IDCupon 5  Canjeado
    ('FID-SOF-10', '25% OFF — Cliente frecuente',    1, 1, 25.00, 10, '2026-05-25', '2026-06-24', 1, 0, 6),   -- IDCupon 6  Activo
    -- Matías (7) — 16 reservas: 10/25/50
    ('FID-MAT-05', '10% OFF — Primer paso',          2, 1, 10.00, 5,  '2026-02-15', '2026-03-17', 1, 1, 7),   -- IDCupon 7  Canjeado
    ('FID-MAT-10', '25% OFF — Cliente frecuente',    1, 1, 25.00, 10, '2026-05-25', '2026-06-24', 1, 0, 7),   -- IDCupon 8  Activo
    ('FID-MAT-15', '50% OFF — Jugador fiel',         1, 1, 50.00, 15, '2026-05-25', '2026-07-24', 1, 0, 7),   -- IDCupon 9  Activo
    -- Valentina (8) — 6 reservas: solo 10%
    ('FID-VAL-05', '10% OFF — Primer paso',          1, 1, 10.00, 5,  '2026-05-25', '2026-06-24', 1, 0, 8),   -- IDCupon 10 Activo
    -- Agustín (9) — 10 reservas: 10% y 25%
    ('FID-AGU-05', '10% OFF — Primer paso',          2, 1, 10.00, 5,  '2026-03-01', '2026-03-31', 1, 1, 9),   -- IDCupon 11 Canjeado
    ('FID-AGU-10', '25% OFF — Cliente frecuente',    1, 1, 25.00, 10, '2026-05-25', '2026-06-24', 1, 0, 9),   -- IDCupon 12 Activo
    -- Nicolás (11) — 23 reservas: 10/25/50, a 2 de la Leyenda
    ('FID-NIC-05', '10% OFF — Primer paso',          2, 1, 10.00, 5,  '2026-02-01', '2026-03-03', 1, 1, 11),  -- IDCupon 13 Canjeado
    ('FID-NIC-10', '25% OFF — Cliente frecuente',    2, 1, 25.00, 10, '2026-03-15', '2026-04-14', 1, 1, 11),  -- IDCupon 14 Canjeado
    ('FID-NIC-15', '50% OFF — Jugador fiel',         1, 1, 50.00, 15, '2026-05-25', '2026-07-24', 1, 0, 11),  -- IDCupon 15 Activo
    -- Tomás (13) — 15 reservas: 10 (vencido), 25, 50
    ('FID-TOM-05', '10% OFF — Primer paso (vencido)',3, 1, 10.00, 5,  '2026-04-01', '2026-05-01', 1, 0, 13),  -- IDCupon 16 Vencido
    ('FID-TOM-10', '25% OFF — Cliente frecuente',    2, 1, 25.00, 10, '2026-04-20', '2026-05-20', 1, 1, 13),  -- IDCupon 17 Canjeado
    ('FID-TOM-15', '50% OFF — Jugador fiel',         1, 1, 50.00, 15, '2026-05-25', '2026-07-24', 1, 0, 13),  -- IDCupon 18 Activo
    -- Julieta (14) — 8 reservas: 10% agotado (se usó hasta el límite)
    ('FID-JUL-05', '10% OFF — Primer paso',          4, 1, 10.00, 5,  '2026-05-01', '2026-06-30', 2, 2, 14);  -- IDCupon 19 Agotado
GO


-- -------------------------------------------------------
-- BENEFICIOS DE FIDELIDAD (catálogo fijo del complejo)
-- IDTipoDescuento: 1=Porcentaje | 2=Reserva gratis
-- -------------------------------------------------------
INSERT INTO BeneficiosFidelidad (Nombre, Descripcion, ReservasRequeridas, IDTipoDescuento, ValorDescuento, DiasValidez, Activo)
VALUES
    ('Primer paso',          'Tu primer reconocimiento por elegirnos: 10% OFF en tu próxima reserva.', 5,  1, 10.00, 30, 1),
    ('Cliente frecuente',    'Ya sos de la casa: 25% OFF para que sigas jugando.',                    10, 1, 25.00, 30, 1),
    ('Jugador fiel',         'Mitad de precio en tu próxima reserva. Te lo ganaste.',                  15, 1, 50.00, 60, 1),
    ('Leyenda del complejo', 'Una reserva totalmente gratis. Sos parte de la historia del lugar.',     25, 2, NULL,  60, 1);
GO


-- -------------------------------------------------------
-- RESERVAS
-- IDEstado:     1=Nueva | 2=Reprogramada | 3=Cancelada | 4=No Asistió | 5=Finalizada
-- IDEstadoPago: 1=Pendiente | 2=Señado | 3=Pagado | 4=Reembolsado
-- Staff:        2=María López | 3=Juan Pérez | NULL=autogestión web
-- -------------------------------------------------------
INSERT INTO Reservas (Fecha, HoraInicio, HoraFin, PrecioTotal, Observaciones, IDUsuario_Cliente, IDUsuario_Staff, IDCancha, IDEstado, IDEstadoPago, IDCupon)
VALUES
    -- Finalizadas con cupón aplicado (estado 5 Finalizada, pago 3 Pagado)
    ('2026-03-15', '10:00', '11:00', 5400.00, 'Cupón FID-LUC-05 (10%) aplicado', 5,  2,    1, 5, 3, 1),   -- IDReserva 1
    ('2026-04-20', '18:00', '19:00', 4500.00, 'Cupón FID-LUC-10 (25%) aplicado', 5,  NULL, 2, 5, 3, 2),   -- IDReserva 2
    ('2026-03-20', '11:00', '12:00', 3150.00, 'Cupón FID-SOF-05 (10%) aplicado', 6,  NULL, 3, 5, 3, 5),   -- IDReserva 3
    ('2026-03-10', '19:00', '20:00', 5400.00, 'Cupón FID-MAT-05 (10%) aplicado', 7,  3,    1, 5, 3, 7),   -- IDReserva 4
    ('2026-03-18', '20:00', '21:00', 4050.00, 'Cupón FID-AGU-05 (10%) aplicado', 9,  NULL, 5, 5, 3, 11),  -- IDReserva 5
    ('2026-02-20', '16:00', '17:00', 5400.00, 'Cupón FID-NIC-05 (10%) aplicado', 11, 2,    1, 5, 3, 13),  -- IDReserva 6
    ('2026-04-05', '17:00', '18:00', 4500.00, 'Cupón FID-NIC-10 (25%) aplicado', 11, NULL, 2, 5, 3, 14),  -- IDReserva 7
    ('2026-05-10', '09:00', '10:00', 3000.00, 'Cupón FID-TOM-10 (25%) aplicado', 13, NULL, 4, 5, 3, 17),  -- IDReserva 8
    -- Finalizadas sin cupón (estado 5, pago 3)
    ('2026-05-05', '10:00', '11:00', 6000.00, NULL,                             5,  2,    1, 5, 3, NULL),  -- IDReserva 9
    ('2026-05-12', '11:00', '12:00', 3500.00, NULL,                             6,  NULL, 3, 5, 3, NULL),  -- IDReserva 10
    ('2026-05-15', '18:00', '19:00', 6000.00, 'Torneo interno',                 7,  3,    2, 5, 3, NULL),  -- IDReserva 11
    ('2026-05-18', '09:00', '10:00', 4000.00, NULL,                             8,  NULL, 4, 5, 3, NULL),  -- IDReserva 12
    ('2026-05-20', '20:00', '21:00', 4500.00, NULL,                             9,  2,    5, 5, 3, NULL),  -- IDReserva 13
    ('2026-05-22', '16:00', '17:00', 6000.00, NULL,                             11, 3,    1, 5, 3, NULL),  -- IDReserva 14
    ('2026-05-25', '08:00', '09:00', 6000.00, NULL,                             13, NULL, 2, 5, 3, NULL),  -- IDReserva 15
    ('2026-05-28', '10:00', '11:00', 3500.00, NULL,                             10, NULL, 3, 5, 3, NULL),  -- IDReserva 16
    ('2026-05-30', '14:00', '15:00', 4000.00, NULL,                             12, NULL, 4, 5, 3, NULL),  -- IDReserva 17
    ('2026-06-01', '19:00', '20:00', 4500.00, NULL,                             14, NULL, 5, 5, 3, NULL),  -- IDReserva 18
    -- Cancelada con reembolso (estado 3 Cancelada, pago 4 Reembolsado)
    ('2026-05-26', '14:00', '15:00', 6000.00, 'Cliente canceló por lluvia',     6,  2,    1, 3, 4, NULL),  -- IDReserva 19
    -- No Asistió (estado 4, pago 3: había pagado y no vino)
    ('2026-05-29', '19:00', '20:00', 4000.00, NULL,                             9,  NULL, 4, 4, 3, NULL),  -- IDReserva 20
    -- Próximas con seña abonada (estado 1 Nueva, pago 2 Señado)
    ('2026-06-12', '18:00', '19:00', 6000.00, NULL,                             5,  NULL, 1, 1, 2, NULL),  -- IDReserva 21
    ('2026-06-13', '19:00', '20:00', 6000.00, NULL,                             7,  NULL, 2, 1, 2, NULL),  -- IDReserva 22
    ('2026-06-14', '09:00', '10:00', 3500.00, NULL,                             11, NULL, 3, 1, 2, NULL),  -- IDReserva 23
    ('2026-06-15', '10:00', '11:00', 4000.00, NULL,                             8,  NULL, 4, 1, 2, NULL),  -- IDReserva 24
    -- Futuras sin seña (estado 1 Nueva, pago 1 Pendiente)
    ('2026-06-18', '10:00', '11:00', 6000.00, NULL,                             10, NULL, 1, 1, 1, NULL),  -- IDReserva 25
    ('2026-06-20', '16:00', '17:00', 4500.00, NULL,                             12, NULL, 5, 1, 1, NULL),  -- IDReserva 26
    ('2026-06-22', '08:00', '09:00', 6000.00, NULL,                             13, NULL, 2, 1, 1, NULL);  -- IDReserva 27
GO


-- -------------------------------------------------------
-- PAGOS
-- Solo para reservas con IDEstadoPago = 2 (Señado), 3 (Pagado) o 4 (Reembolsado)
-- IDFormaPago: 1=Efectivo | 2=Transferencia | 3=Débito | 4=Crédito | 5=MercadoPago
-- -------------------------------------------------------
INSERT INTO Pagos (Monto, FechaHora, IDReserva, IDFormaPago)
VALUES
    -- Finalizadas con cupón aplicado (IDReserva 1-8): el monto ya tiene el descuento
    (5400.00, '2026-03-15 11:10', 1,  1),  -- Efectivo
    (4500.00, '2026-04-20 19:10', 2,  5),  -- MercadoPago
    (3150.00, '2026-03-20 12:05', 3,  2),  -- Transferencia
    (5400.00, '2026-03-10 20:05', 4,  4),  -- Crédito
    (4050.00, '2026-03-18 21:05', 5,  1),  -- Efectivo
    (5400.00, '2026-02-20 17:05', 6,  5),  -- MercadoPago
    (4500.00, '2026-04-05 18:05', 7,  2),  -- Transferencia
    (3000.00, '2026-05-10 10:05', 8,  3),  -- Débito
    -- Finalizadas sin cupón (IDReserva 9-18): pago completo
    (6000.00, '2026-05-05 11:05', 9,  1),  -- Efectivo
    (3500.00, '2026-05-12 12:05', 10, 5),  -- MercadoPago
    (6000.00, '2026-05-15 19:05', 11, 2),  -- Transferencia
    (4000.00, '2026-05-18 10:05', 12, 4),  -- Crédito
    (4500.00, '2026-05-20 21:05', 13, 3),  -- Débito
    (6000.00, '2026-05-22 17:05', 14, 5),  -- MercadoPago
    (6000.00, '2026-05-25 09:05', 15, 2),  -- Transferencia
    (3500.00, '2026-05-28 11:05', 16, 1),  -- Efectivo
    (4000.00, '2026-05-30 15:05', 17, 5),  -- MercadoPago
    (4500.00, '2026-06-01 20:05', 18, 3),  -- Débito
    -- Cancelada: pago original + reembolso (IDReserva 19)
    (6000.00, '2026-05-24 10:00', 19, 2),  -- Pago original
    (6000.00, '2026-05-26 16:00', 19, 2),  -- Reembolso
    -- No Asistió, pero había pagado (IDReserva 20)
    (4000.00, '2026-05-27 18:00', 20, 1),  -- Efectivo
    -- Señas de reservas próximas (IDReserva 21-24)
    (2000.00, '2026-06-08 12:00', 21, 2),  -- Seña transferencia (cancha 1)
    (2000.00, '2026-06-08 13:00', 22, 5),  -- Seña MercadoPago (cancha 2)
    (1000.00, '2026-06-09 09:00', 23, 3),  -- Seña débito (cancha 3)
    (1500.00, '2026-06-09 14:00', 24, 1);  -- Seña efectivo (cancha 4)
GO