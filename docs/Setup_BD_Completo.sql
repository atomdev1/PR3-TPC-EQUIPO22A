-- =========================================================================
-- Setup_BD_Completo.sql
-- Setup completo de la base: creación, datos, vista, SP y trigger, todo junto.
-- Orden: creación de tablas -> datos iniciales -> vista -> SP -> trigger.
--
-- El reset (00_Reset_BD.sql) va aparte: este script CREA la base, así que si
-- ya existe hay que dropearla primero con el reset.
--
-- =========================================================================

-- Creación de la Base de Datos
CREATE DATABASE BBDD2_TPI_GRUPO45;
GO

USE BBDD2_TPI_GRUPO45;
GO


-- =========================================
-- TABLAS MAESTRAS
-- =========================================

CREATE TABLE Roles (
    IDRol       INT          IDENTITY(1,1) PRIMARY KEY,
    NombreRol   VARCHAR(50)  NOT NULL
);

CREATE TABLE Deportes (
    IDDeporte        INT         IDENTITY(1,1) PRIMARY KEY,
    Nombre           VARCHAR(50) NOT NULL,
    DuracionMinutos  INT         NOT NULL,
    Activa           BIT         NOT NULL DEFAULT 1
);

CREATE TABLE EstadoReserva (
    IDEstado       INT         IDENTITY(1,1) PRIMARY KEY,
    NombreEstado   VARCHAR(50) NOT NULL
);

CREATE TABLE EstadoPago (
    IDEstadoPago       INT         IDENTITY(1,1) PRIMARY KEY,
    NombreEstadoPago   VARCHAR(50) NOT NULL
);

CREATE TABLE FormasPago (
    IDFormaPago       INT         IDENTITY(1,1) PRIMARY KEY,
    NombreFormaPago   VARCHAR(50) NOT NULL
);

CREATE TABLE EstadoCupon (
    IDEstadoCupon   INT          IDENTITY(1,1) PRIMARY KEY,
    NombreEstado    VARCHAR(50)  NOT NULL
);

CREATE TABLE TipoDescuento (
    IDTipoDescuento   INT          IDENTITY(1,1) PRIMARY KEY,
    Nombre            VARCHAR(50)  NOT NULL
);

-- =========================================
-- USUARIOS (clientes + staff unificados)
-- =========================================

CREATE TABLE Usuarios (
    IDUsuario            INT           IDENTITY(1,1) PRIMARY KEY,
    DNI                  VARCHAR(20)   UNIQUE NOT NULL,
    Nombre               VARCHAR(100)  NOT NULL,
    Apellido             VARCHAR(100)  NOT NULL,
    Telefono             VARCHAR(20)   NULL,
    Email                VARCHAR(100)  UNIQUE NOT NULL,
    Password             VARCHAR(255)  NOT NULL,  -- SHA256
    FechaNacimiento      DATETIME      NULL,
    FechaRegistro        DATETIME      NOT NULL DEFAULT GETDATE(),
    Activo               BIT           NOT NULL DEFAULT 1,
    CantidadAsistencias  INT           NOT NULL DEFAULT 0,
    IDRol                INT           NOT NULL,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IDRol) REFERENCES Roles(IDRol)
);

-- =========================================
-- CANCHAS
-- =========================================

CREATE TABLE Canchas (
    IDCancha            INT            IDENTITY(1,1) PRIMARY KEY,
    Numero              INT            NOT NULL,
    NombreFantasia      VARCHAR(100)   NULL,
    Descripcion         VARCHAR(255)   NULL,
    CapacidadJugadores  INT            NULL,
    Precio              DECIMAL(10,2)  NOT NULL,
    MontoSena           DECIMAL(10,2)  NULL,
    Activa              BIT            NOT NULL DEFAULT 1,
    IDDeporte           INT            NOT NULL,
    CONSTRAINT FK_Canchas_Deportes FOREIGN KEY (IDDeporte) REFERENCES Deportes(IDDeporte)
);

CREATE TABLE DisponibilidadCanchas (
    IDDisponibilidad   INT   IDENTITY(1,1) PRIMARY KEY,
    IDCancha           INT   NOT NULL,
    DiaSemana          TINYINT NOT NULL,  -- 0=Lunes, 6=Domingo
    HoraApertura       TIME  NOT NULL,
    HoraCierre         TIME  NOT NULL,
    Activa             BIT   NOT NULL DEFAULT 1,
    CONSTRAINT FK_Disponibilidad_Canchas FOREIGN KEY (IDCancha) REFERENCES Canchas(IDCancha),
    CONSTRAINT CK_DiaSemana CHECK (DiaSemana BETWEEN 0 AND 6)
);

-- =========================================
-- CUPONES
-- =========================================

CREATE TABLE Cupones (
    IDCupon             INT            IDENTITY(1,1) PRIMARY KEY,
    Codigo              VARCHAR(50)    UNIQUE NOT NULL,
    Descripcion         VARCHAR(255)   NOT NULL,
    IDEstadoCupon       INT            NOT NULL DEFAULT 1,   -- 1=Activo (ver tabla EstadoCupon)
    IDTipoDescuento     INT            NOT NULL,             -- Porcentaje | ReservaGratis
    ValorDescuento      DECIMAL(10,2)  NULL,                 -- NULL cuando IDTipoDescuento = ReservaGratis
    ReservasRequeridas  INT            NOT NULL DEFAULT 10,
    ValidoDesde         DATE           NULL,
    ValidoHasta         DATE           NULL,
    LimiteUsos          INT            NULL,                 -- NULL = sin límite
    UsosActuales        INT            NOT NULL DEFAULT 0,
    IDUsuario           INT            NOT NULL,             -- dueño del cupón (cupón personal)
    CONSTRAINT FK_Cupones_Usuarios       FOREIGN KEY (IDUsuario)       REFERENCES Usuarios(IDUsuario),
    CONSTRAINT FK_Cupones_EstadoCupon    FOREIGN KEY (IDEstadoCupon)   REFERENCES EstadoCupon(IDEstadoCupon),
    CONSTRAINT FK_Cupones_TipoDescuento  FOREIGN KEY (IDTipoDescuento) REFERENCES TipoDescuento(IDTipoDescuento)
);

-- =========================================
-- BENEFICIOS DE FIDELIDAD
-- Catálogo fijo del complejo: la REGLA "a las X reservas, tal beneficio".
-- No es el cupón emitido — el trigger genera el cupón al alcanzar el umbral.
-- =========================================

CREATE TABLE BeneficiosFidelidad (
    IDBeneficio         INT            IDENTITY(1,1) PRIMARY KEY,
    Nombre              VARCHAR(100)   NOT NULL,
    Descripcion         VARCHAR(255)   NOT NULL,
    ReservasRequeridas  INT            NOT NULL,             -- el umbral a alcanzar
    IDTipoDescuento     INT            NOT NULL,             -- Porcentaje | ReservaGratis
    ValorDescuento      DECIMAL(10,2)  NULL,                 -- NULL cuando es Reserva gratis
    DiasValidez         INT            NULL,                 -- vigencia del cupón generado (NULL = sin vencimiento)
    Activo              BIT            NOT NULL DEFAULT 1,
    CONSTRAINT FK_Beneficios_TipoDescuento FOREIGN KEY (IDTipoDescuento) REFERENCES TipoDescuento(IDTipoDescuento),
    CONSTRAINT UQ_Beneficios_Umbral        UNIQUE (ReservasRequeridas)   -- un beneficio por umbral
);

-- =========================================
-- RESERVAS
-- =========================================

CREATE TABLE Reservas (
    IDReserva          INT            IDENTITY(1,1) PRIMARY KEY,
    Fecha              DATE           NOT NULL,
    HoraInicio         TIME           NOT NULL,
    HoraFin            TIME           NOT NULL,
    PrecioTotal        DECIMAL(10,2)  NOT NULL,
    Observaciones      VARCHAR(255)   NULL,
    IDUsuario_Cliente  INT            NOT NULL,
    IDUsuario_Staff    INT            NULL,        -- NULL si fue autogestión web
    IDCancha           INT            NOT NULL,
    IDEstado           INT            NOT NULL,
    IDEstadoPago       INT            NOT NULL,
    IDCupon            INT            NULL,        -- NULL si no se aplicó cupón
    CONSTRAINT FK_Reservas_Cliente    FOREIGN KEY (IDUsuario_Cliente) REFERENCES Usuarios(IDUsuario),
    CONSTRAINT FK_Reservas_Staff      FOREIGN KEY (IDUsuario_Staff)   REFERENCES Usuarios(IDUsuario),
    CONSTRAINT FK_Reservas_Canchas    FOREIGN KEY (IDCancha)          REFERENCES Canchas(IDCancha),
    CONSTRAINT FK_Reservas_Estado     FOREIGN KEY (IDEstado)          REFERENCES EstadoReserva(IDEstado),
    CONSTRAINT FK_Reservas_EstadoPago FOREIGN KEY (IDEstadoPago)      REFERENCES EstadoPago(IDEstadoPago),
    CONSTRAINT FK_Reservas_Cupon      FOREIGN KEY (IDCupon)           REFERENCES Cupones(IDCupon)
);

-- =========================================
-- PAGOS
-- =========================================

CREATE TABLE Pagos (
    IDPago        INT            IDENTITY(1,1) PRIMARY KEY,
    Monto         DECIMAL(10,2)  NOT NULL,
    FechaHora     DATETIME       NOT NULL DEFAULT GETDATE(),
    IDReserva     INT            NOT NULL,
    IDFormaPago   INT            NOT NULL,
    CONSTRAINT FK_Pagos_Reservas   FOREIGN KEY (IDReserva)   REFERENCES Reservas(IDReserva),
    CONSTRAINT FK_Pagos_FormasPago FOREIGN KEY (IDFormaPago) REFERENCES FormasPago(IDFormaPago)
);

GO
-- ----------------------------------------------------------------------
-- (siguiente script)
-- ----------------------------------------------------------------------

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
    -- para que los cupones que tiene cada uno cuenten una historia coherente.
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
-- Todos los días: 08:00-22:00
-- -------------------------------------------------------
INSERT INTO DisponibilidadCanchas (IDCancha, DiaSemana, HoraApertura, HoraCierre, Activa)
VALUES
    (1,0,'08:00','22:00',1),(1,1,'08:00','22:00',1),(1,2,'08:00','22:00',1),(1,3,'08:00','22:00',1),(1,4,'08:00','22:00',1),(1,5,'08:00','22:00',1),(1,6,'08:00','22:00',1),
    (2,0,'08:00','22:00',1),(2,1,'08:00','22:00',1),(2,2,'08:00','22:00',1),(2,3,'08:00','22:00',1),(2,4,'08:00','22:00',1),(2,5,'08:00','22:00',1),(2,6,'08:00','22:00',1),
    (3,0,'08:00','22:00',1),(3,1,'08:00','22:00',1),(3,2,'08:00','22:00',1),(3,3,'08:00','22:00',1),(3,4,'08:00','22:00',1),(3,5,'08:00','22:00',1),(3,6,'08:00','22:00',1),
    (4,0,'08:00','22:00',1),(4,1,'08:00','22:00',1),(4,2,'08:00','22:00',1),(4,3,'08:00','22:00',1),(4,4,'08:00','22:00',1),(4,5,'08:00','22:00',1),(4,6,'08:00','22:00',1),
    (5,0,'08:00','22:00',1),(5,1,'08:00','22:00',1),(5,2,'08:00','22:00',1),(5,3,'08:00','22:00',1),(5,4,'08:00','22:00',1),(5,5,'08:00','22:00',1),(5,6,'08:00','22:00',1);
GO


-- -------------------------------------------------------
-- CUPONES (personales: cada cupón pertenece a UN cliente por IDUsuario)
-- Ventanas de validez alineadas al mes de los datos (mayo-junio 2026).
-- IDEstadoCupon:   1=Activo | 2=Canjeado | 3=Vencido | 4=Agotado
-- IDTipoDescuento: 1=Porcentaje | 2=Reserva gratis
-- -------------------------------------------------------
INSERT INTO Cupones (Codigo, Descripcion, IDEstadoCupon, IDTipoDescuento, ValorDescuento, ReservasRequeridas, ValidoDesde, ValidoHasta, LimiteUsos, UsosActuales, IDUsuario)
VALUES
    ('FID-LUC-05', '10% OFF — Primer paso', 2, 1, 10.00, 5, '2026-05-01', '2026-06-30', 1, 1, 5),  -- IDCupon 1
    ('FID-LUC-10', '25% OFF — Cliente frecuente', 2, 1, 25.00, 10, '2026-05-01', '2026-06-30', 1, 1, 5),  -- IDCupon 2
    ('FID-LUC-15', '50% OFF — Jugador fiel', 1, 1, 50.00, 15, '2026-06-01', '2026-07-31', 1, 0, 5),  -- IDCupon 3
    ('FID-LUC-25', 'Reserva gratis — Leyenda', 1, 2, NULL, 25, '2026-06-01', '2026-07-31', 1, 0, 5),  -- IDCupon 4
    ('FID-SOF-05', '10% OFF — Primer paso', 2, 1, 10.00, 5, '2026-05-01', '2026-06-30', 1, 1, 6),  -- IDCupon 5
    ('FID-SOF-10', '25% OFF — Cliente frecuente', 1, 1, 25.00, 10, '2026-06-01', '2026-07-31', 1, 0, 6),  -- IDCupon 6
    ('FID-MAT-05', '10% OFF — Primer paso', 2, 1, 10.00, 5, '2026-05-01', '2026-06-30', 1, 1, 7),  -- IDCupon 7
    ('FID-MAT-10', '25% OFF — Cliente frecuente', 1, 1, 25.00, 10, '2026-06-01', '2026-07-31', 1, 0, 7),  -- IDCupon 8
    ('FID-MAT-15', '50% OFF — Jugador fiel', 1, 1, 50.00, 15, '2026-06-01', '2026-07-31', 1, 0, 7),  -- IDCupon 9
    ('FID-VAL-05', '10% OFF — Primer paso', 1, 1, 10.00, 5, '2026-06-01', '2026-07-31', 1, 0, 8),  -- IDCupon 10
    ('FID-AGU-05', '10% OFF — Primer paso', 2, 1, 10.00, 5, '2026-05-01', '2026-06-30', 1, 1, 9),  -- IDCupon 11
    ('FID-AGU-10', '25% OFF — Cliente frecuente', 1, 1, 25.00, 10, '2026-06-01', '2026-07-31', 1, 0, 9),  -- IDCupon 12
    ('FID-NIC-05', '10% OFF — Primer paso', 2, 1, 10.00, 5, '2026-05-01', '2026-06-30', 1, 1, 11),  -- IDCupon 13
    ('FID-NIC-10', '25% OFF — Cliente frecuente', 2, 1, 25.00, 10, '2026-05-01', '2026-06-30', 1, 1, 11),  -- IDCupon 14
    ('FID-NIC-15', '50% OFF — Jugador fiel', 1, 1, 50.00, 15, '2026-06-01', '2026-07-31', 1, 0, 11),  -- IDCupon 15
    ('FID-TOM-05', '10% OFF — Primer paso (vencido)', 3, 1, 10.00, 5, '2026-04-01', '2026-05-01', 1, 0, 13),  -- IDCupon 16
    ('FID-TOM-10', '25% OFF — Cliente frecuente', 2, 1, 25.00, 10, '2026-05-01', '2026-06-30', 1, 1, 13),  -- IDCupon 17
    ('FID-TOM-15', '50% OFF — Jugador fiel', 1, 1, 50.00, 15, '2026-06-01', '2026-07-31', 1, 0, 13),  -- IDCupon 18
    ('FID-JUL-05', '10% OFF — Primer paso', 4, 1, 10.00, 5, '2026-05-01', '2026-06-30', 2, 2, 14);  -- IDCupon 19
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
-- Todas concentradas en una ventana de ~1 mes (25/05/2026 al 22/06/2026).
-- "Hoy" = 2026-06-17: finalizadas/canceladas son pasadas, las próximas son futuras.
-- IDEstado:     1=Nueva | 2=Reprogramada | 3=Cancelada | 4=No Asistió | 5=Finalizada
-- IDEstadoPago: 1=Pendiente | 2=Señado | 3=Pagado | 4=Reembolsado
-- Staff:        2=María López | 3=Juan Pérez | NULL=autogestión web
--
-- BLOQUE 1 — Reservas "narrativas" (escenarios para SPs/triggers). Van primero
-- para conservar IDReserva 1..27.
-- -------------------------------------------------------
INSERT INTO Reservas (Fecha, HoraInicio, HoraFin, PrecioTotal, Observaciones, IDUsuario_Cliente, IDUsuario_Staff, IDCancha, IDEstado, IDEstadoPago, IDCupon)
VALUES
    ('2026-05-26', '08:00', '09:00', 5400.00, 'Cupón FID-LUC-05 (10%) aplicado', 5, 2, 1, 5, 3, 1),  -- IDReserva 1
    ('2026-06-02', '18:00', '19:00', 3375.00, 'Cupón FID-LUC-10 (25%) aplicado', 5, NULL, 5, 5, 3, 2),  -- IDReserva 2
    ('2026-05-27', '12:00', '13:00', 3600.00, 'Cupón FID-SOF-05 (10%) aplicado', 6, NULL, 4, 5, 3, 5),  -- IDReserva 3
    ('2026-05-28', '19:00', '20:00', 3150.00, 'Cupón FID-MAT-05 (10%) aplicado', 7, 3, 3, 5, 3, 7),  -- IDReserva 4
    ('2026-05-29', '14:00', '15:00', 5400.00, 'Cupón FID-AGU-05 (10%) aplicado', 9, NULL, 1, 5, 3, 11),  -- IDReserva 5
    ('2026-06-03', '12:00', '13:00', 3600.00, 'Cupón FID-NIC-05 (10%) aplicado', 11, 2, 4, 5, 3, 13),  -- IDReserva 6
    ('2026-06-05', '20:00', '21:00', 3375.00, 'Cupón FID-NIC-10 (25%) aplicado', 11, NULL, 5, 5, 3, 14),  -- IDReserva 7
    ('2026-06-09', '08:00', '09:00', 4500.00, 'Cupón FID-TOM-10 (25%) aplicado', 13, NULL, 1, 5, 3, 17),  -- IDReserva 8
    ('2026-05-30', '08:00', '09:00', 4500.00, NULL, 5, 2, 5, 5, 3, NULL),  -- IDReserva 9
    ('2026-05-31', '13:00', '14:00', 4000.00, NULL, 6, NULL, 4, 5, 3, NULL),  -- IDReserva 10
    ('2026-06-06', '21:00', '22:00', 6000.00, 'Torneo interno', 7, 3, 1, 5, 3, NULL),  -- IDReserva 11
    ('2026-06-01', '08:00', '09:00', 6000.00, NULL, 8, NULL, 1, 5, 3, NULL),  -- IDReserva 12
    ('2026-06-07', '20:00', '21:00', 6000.00, NULL, 9, 2, 1, 5, 3, NULL),  -- IDReserva 13
    ('2026-06-10', '19:00', '20:00', 6000.00, NULL, 11, 3, 1, 5, 3, NULL),  -- IDReserva 14
    ('2026-06-11', '08:00', '09:00', 6000.00, NULL, 13, NULL, 2, 5, 3, NULL),  -- IDReserva 15
    ('2026-06-12', '14:00', '15:00', 6000.00, NULL, 10, NULL, 1, 5, 3, NULL),  -- IDReserva 16
    ('2026-06-13', '14:00', '15:00', 4500.00, NULL, 12, NULL, 5, 5, 3, NULL),  -- IDReserva 17
    ('2026-06-14', '20:00', '21:00', 6000.00, NULL, 14, NULL, 1, 5, 3, NULL),  -- IDReserva 18
    ('2026-06-04', '13:00', '14:00', 6000.00, 'Cliente canceló por lluvia', 6, 2, 1, 3, 4, NULL),  -- IDReserva 19
    ('2026-06-08', '19:00', '20:00', 6000.00, 'No se presentó', 9, NULL, 1, 4, 3, NULL),  -- IDReserva 20
    ('2026-06-18', '18:00', '19:00', 6000.00, NULL, 5, NULL, 1, 1, 2, NULL),  -- IDReserva 21
    ('2026-06-19', '18:00', '19:00', 6000.00, NULL, 7, NULL, 1, 1, 2, NULL),  -- IDReserva 22
    ('2026-06-20', '08:00', '09:00', 6000.00, NULL, 11, NULL, 1, 1, 2, NULL),  -- IDReserva 23
    ('2026-06-21', '08:00', '09:00', 6000.00, NULL, 8, NULL, 1, 1, 2, NULL),  -- IDReserva 24
    ('2026-06-18', '08:00', '09:00', 6000.00, NULL, 10, NULL, 1, 1, 1, NULL),  -- IDReserva 25
    ('2026-06-20', '18:00', '19:00', 6000.00, NULL, 12, NULL, 1, 1, 1, NULL),  -- IDReserva 26
    ('2026-06-22', '08:00', '09:00', 6000.00, NULL, 13, NULL, 1, 1, 1, NULL);  -- IDReserva 27
GO


-- -------------------------------------------------------
-- BLOQUE 2 — CARGA DE OCUPACIÓN (demanda para la vista vw_OcupacionPorTurno)
-- Reservas finalizadas por día de la semana y turno, con un patrón realista:
-- mañanas de semana casi vacías y noches/findes llenos.
-- 3 semanas desde el lunes 2026-05-25 (3 fechas de cada día → COUNT(DISTINCT Fecha)=3).
-- Capacidad por fecha: Mañana 20 cupos, Tarde 30, Noche 20 (cupos del turno × 5 canchas).
--
-- Reservas TOTALES por celda (demanda + finalizadas narrativas que caen ahí, ya
-- descontadas de la demanda para que el total cierre con esta matriz):
--   Día         Mañana       Tarde        Noche
--   Lunes       1  (5%)      3  (10%)     5  (25%)
--   Martes      1  (5%)      3  (10%)     5  (25%)
--   Miércoles   1  (5%)      4  (13%)     6  (30%)
--   Jueves      2  (10%)     5  (17%)     8  (40%)
--   Viernes     2  (10%)     11 (37%)     15 (75%)
--   Sábado      5  (25%)     15 (50%)     16 (80%)
--   Domingo     7  (35%)     9  (30%)     11 (55%)
--
-- Todas: estado 5 (Finalizada), pago 3 (Pagado), autogestión web. Cliente rotado 5..14.
-- -------------------------------------------------------
INSERT INTO Reservas (Fecha, HoraInicio, HoraFin, PrecioTotal, Observaciones, IDUsuario_Cliente, IDUsuario_Staff, IDCancha, IDEstado, IDEstadoPago, IDCupon)
VALUES
    -- ===== SEMANA 1 =====
    -- Lunes 2026-05-25 - Mañana (1)
    ('2026-05-25', '08:00', '09:00', 6000.00, 'Carga de ocupación', 5, NULL, 1, 5, 3, NULL),
    -- Lunes 2026-05-25 - Tarde (3)
    ('2026-05-25', '12:00', '13:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-05-25', '12:00', '13:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-05-25', '12:00', '13:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    -- Lunes 2026-05-25 - Noche (5)
    ('2026-05-25', '18:00', '19:00', 6000.00, 'Carga de ocupación', 9, NULL, 1, 5, 3, NULL),
    ('2026-05-25', '18:00', '19:00', 6000.00, 'Carga de ocupación', 10, NULL, 2, 5, 3, NULL),
    ('2026-05-25', '18:00', '19:00', 3500.00, 'Carga de ocupación', 11, NULL, 3, 5, 3, NULL),
    ('2026-05-25', '18:00', '19:00', 4000.00, 'Carga de ocupación', 12, NULL, 4, 5, 3, NULL),
    ('2026-05-25', '18:00', '19:00', 4500.00, 'Carga de ocupación', 13, NULL, 5, 5, 3, NULL),
    -- Martes 2026-05-26 - Tarde (3)
    ('2026-05-26', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-05-26', '12:00', '13:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    ('2026-05-26', '12:00', '13:00', 3500.00, 'Carga de ocupación', 6, NULL, 3, 5, 3, NULL),
    -- Martes 2026-05-26 - Noche (5)
    ('2026-05-26', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-05-26', '18:00', '19:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-05-26', '18:00', '19:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-05-26', '18:00', '19:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-05-26', '18:00', '19:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    -- Miércoles 2026-05-27 - Mañana (1)
    ('2026-05-27', '08:00', '09:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    -- Miércoles 2026-05-27 - Tarde (3)
    ('2026-05-27', '12:00', '13:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-05-27', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-05-27', '12:00', '13:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    -- Miércoles 2026-05-27 - Noche (6)
    ('2026-05-27', '18:00', '19:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-05-27', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-05-27', '18:00', '19:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-05-27', '18:00', '19:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    ('2026-05-27', '18:00', '19:00', 4500.00, 'Carga de ocupación', 10, NULL, 5, 5, 3, NULL),
    ('2026-05-27', '19:00', '20:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    -- Jueves 2026-05-28 - Mañana (2)
    ('2026-05-28', '08:00', '09:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-05-28', '08:00', '09:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    -- Jueves 2026-05-28 - Tarde (5)
    ('2026-05-28', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-05-28', '12:00', '13:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    ('2026-05-28', '12:00', '13:00', 3500.00, 'Carga de ocupación', 6, NULL, 3, 5, 3, NULL),
    ('2026-05-28', '12:00', '13:00', 4000.00, 'Carga de ocupación', 7, NULL, 4, 5, 3, NULL),
    ('2026-05-28', '12:00', '13:00', 4500.00, 'Carga de ocupación', 8, NULL, 5, 5, 3, NULL),
    -- Jueves 2026-05-28 - Noche (7)
    ('2026-05-28', '18:00', '19:00', 6000.00, 'Carga de ocupación', 9, NULL, 1, 5, 3, NULL),
    ('2026-05-28', '18:00', '19:00', 6000.00, 'Carga de ocupación', 10, NULL, 2, 5, 3, NULL),
    ('2026-05-28', '18:00', '19:00', 3500.00, 'Carga de ocupación', 11, NULL, 3, 5, 3, NULL),
    ('2026-05-28', '18:00', '19:00', 4000.00, 'Carga de ocupación', 12, NULL, 4, 5, 3, NULL),
    ('2026-05-28', '18:00', '19:00', 4500.00, 'Carga de ocupación', 13, NULL, 5, 5, 3, NULL),
    ('2026-05-28', '19:00', '20:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-05-28', '19:00', '20:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    -- Viernes 2026-05-29 - Mañana (2)
    ('2026-05-29', '08:00', '09:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-05-29', '08:00', '09:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    -- Viernes 2026-05-29 - Tarde (10)
    ('2026-05-29', '12:00', '13:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-05-29', '12:00', '13:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-05-29', '12:00', '13:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-05-29', '12:00', '13:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    ('2026-05-29', '12:00', '13:00', 4500.00, 'Carga de ocupación', 12, NULL, 5, 5, 3, NULL),
    ('2026-05-29', '13:00', '14:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-05-29', '13:00', '14:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-05-29', '13:00', '14:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    ('2026-05-29', '13:00', '14:00', 4000.00, 'Carga de ocupación', 6, NULL, 4, 5, 3, NULL),
    ('2026-05-29', '13:00', '14:00', 4500.00, 'Carga de ocupación', 7, NULL, 5, 5, 3, NULL),
    -- Viernes 2026-05-29 - Noche (15)
    ('2026-05-29', '18:00', '19:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-05-29', '18:00', '19:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-05-29', '18:00', '19:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-05-29', '18:00', '19:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    ('2026-05-29', '18:00', '19:00', 4500.00, 'Carga de ocupación', 12, NULL, 5, 5, 3, NULL),
    ('2026-05-29', '19:00', '20:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-05-29', '19:00', '20:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-05-29', '19:00', '20:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    ('2026-05-29', '19:00', '20:00', 4000.00, 'Carga de ocupación', 6, NULL, 4, 5, 3, NULL),
    ('2026-05-29', '19:00', '20:00', 4500.00, 'Carga de ocupación', 7, NULL, 5, 5, 3, NULL),
    ('2026-05-29', '20:00', '21:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-05-29', '20:00', '21:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-05-29', '20:00', '21:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-05-29', '20:00', '21:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    ('2026-05-29', '20:00', '21:00', 4500.00, 'Carga de ocupación', 12, NULL, 5, 5, 3, NULL),
    -- Sábado 2026-05-30 - Mañana (4)
    ('2026-05-30', '08:00', '09:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-05-30', '08:00', '09:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-05-30', '08:00', '09:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    ('2026-05-30', '08:00', '09:00', 4000.00, 'Carga de ocupación', 6, NULL, 4, 5, 3, NULL),
    -- Sábado 2026-05-30 - Tarde (15)
    ('2026-05-30', '12:00', '13:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-05-30', '12:00', '13:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-05-30', '12:00', '13:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-05-30', '12:00', '13:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-05-30', '12:00', '13:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    ('2026-05-30', '13:00', '14:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-05-30', '13:00', '14:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-05-30', '13:00', '14:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-05-30', '13:00', '14:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-05-30', '13:00', '14:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    ('2026-05-30', '14:00', '15:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-05-30', '14:00', '15:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-05-30', '14:00', '15:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-05-30', '14:00', '15:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-05-30', '14:00', '15:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    -- Sábado 2026-05-30 - Noche (16)
    ('2026-05-30', '18:00', '19:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-05-30', '18:00', '19:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-05-30', '18:00', '19:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-05-30', '18:00', '19:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-05-30', '18:00', '19:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    ('2026-05-30', '19:00', '20:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-05-30', '19:00', '20:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-05-30', '19:00', '20:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-05-30', '19:00', '20:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-05-30', '19:00', '20:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    ('2026-05-30', '20:00', '21:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-05-30', '20:00', '21:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-05-30', '20:00', '21:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-05-30', '20:00', '21:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-05-30', '20:00', '21:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    ('2026-05-30', '21:00', '22:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    -- Domingo 2026-05-31 - Mañana (7)
    ('2026-05-31', '08:00', '09:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-05-31', '08:00', '09:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-05-31', '08:00', '09:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-05-31', '08:00', '09:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    ('2026-05-31', '08:00', '09:00', 4500.00, 'Carga de ocupación', 12, NULL, 5, 5, 3, NULL),
    ('2026-05-31', '09:00', '10:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-05-31', '09:00', '10:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    -- Domingo 2026-05-31 - Tarde (8)
    ('2026-05-31', '12:00', '13:00', 6000.00, 'Carga de ocupación', 5, NULL, 1, 5, 3, NULL),
    ('2026-05-31', '12:00', '13:00', 6000.00, 'Carga de ocupación', 6, NULL, 2, 5, 3, NULL),
    ('2026-05-31', '12:00', '13:00', 3500.00, 'Carga de ocupación', 7, NULL, 3, 5, 3, NULL),
    ('2026-05-31', '12:00', '13:00', 4000.00, 'Carga de ocupación', 8, NULL, 4, 5, 3, NULL),
    ('2026-05-31', '12:00', '13:00', 4500.00, 'Carga de ocupación', 9, NULL, 5, 5, 3, NULL),
    ('2026-05-31', '13:00', '14:00', 6000.00, 'Carga de ocupación', 10, NULL, 1, 5, 3, NULL),
    ('2026-05-31', '13:00', '14:00', 6000.00, 'Carga de ocupación', 11, NULL, 2, 5, 3, NULL),
    ('2026-05-31', '13:00', '14:00', 3500.00, 'Carga de ocupación', 12, NULL, 3, 5, 3, NULL),
    -- Domingo 2026-05-31 - Noche (11)
    ('2026-05-31', '18:00', '19:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-05-31', '18:00', '19:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-05-31', '18:00', '19:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    ('2026-05-31', '18:00', '19:00', 4000.00, 'Carga de ocupación', 6, NULL, 4, 5, 3, NULL),
    ('2026-05-31', '18:00', '19:00', 4500.00, 'Carga de ocupación', 7, NULL, 5, 5, 3, NULL),
    ('2026-05-31', '19:00', '20:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-05-31', '19:00', '20:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-05-31', '19:00', '20:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-05-31', '19:00', '20:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    ('2026-05-31', '19:00', '20:00', 4500.00, 'Carga de ocupación', 12, NULL, 5, 5, 3, NULL),
    ('2026-05-31', '20:00', '21:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    -- ===== SEMANA 2 =====
    -- Lunes 2026-06-01 - Tarde (3)
    ('2026-06-01', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-06-01', '12:00', '13:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    ('2026-06-01', '12:00', '13:00', 3500.00, 'Carga de ocupación', 6, NULL, 3, 5, 3, NULL),
    -- Lunes 2026-06-01 - Noche (5)
    ('2026-06-01', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-01', '18:00', '19:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-01', '18:00', '19:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-01', '18:00', '19:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-01', '18:00', '19:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    -- Martes 2026-06-02 - Mañana (1)
    ('2026-06-02', '08:00', '09:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    -- Martes 2026-06-02 - Tarde (3)
    ('2026-06-02', '12:00', '13:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-06-02', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-06-02', '12:00', '13:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    -- Martes 2026-06-02 - Noche (4)
    ('2026-06-02', '18:00', '19:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-02', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-02', '18:00', '19:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-02', '18:00', '19:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    -- Miércoles 2026-06-03 - Mañana (1)
    ('2026-06-03', '08:00', '09:00', 6000.00, 'Carga de ocupación', 10, NULL, 1, 5, 3, NULL),
    -- Miércoles 2026-06-03 - Tarde (3)
    ('2026-06-03', '12:00', '13:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-03', '12:00', '13:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-03', '12:00', '13:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    -- Miércoles 2026-06-03 - Noche (6)
    ('2026-06-03', '18:00', '19:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-06-03', '18:00', '19:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    ('2026-06-03', '18:00', '19:00', 3500.00, 'Carga de ocupación', 6, NULL, 3, 5, 3, NULL),
    ('2026-06-03', '18:00', '19:00', 4000.00, 'Carga de ocupación', 7, NULL, 4, 5, 3, NULL),
    ('2026-06-03', '18:00', '19:00', 4500.00, 'Carga de ocupación', 8, NULL, 5, 5, 3, NULL),
    ('2026-06-03', '19:00', '20:00', 6000.00, 'Carga de ocupación', 9, NULL, 1, 5, 3, NULL),
    -- Jueves 2026-06-04 - Mañana (2)
    ('2026-06-04', '08:00', '09:00', 6000.00, 'Carga de ocupación', 10, NULL, 1, 5, 3, NULL),
    ('2026-06-04', '08:00', '09:00', 6000.00, 'Carga de ocupación', 11, NULL, 2, 5, 3, NULL),
    -- Jueves 2026-06-04 - Tarde (5)
    ('2026-06-04', '12:00', '13:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-04', '12:00', '13:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-04', '12:00', '13:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-06-04', '12:00', '13:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-06-04', '12:00', '13:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    -- Jueves 2026-06-04 - Noche (8)
    ('2026-06-04', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-04', '18:00', '19:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-04', '18:00', '19:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-04', '18:00', '19:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-04', '18:00', '19:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    ('2026-06-04', '19:00', '20:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-04', '19:00', '20:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-04', '19:00', '20:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    -- Viernes 2026-06-05 - Mañana (2)
    ('2026-06-05', '08:00', '09:00', 6000.00, 'Carga de ocupación', 5, NULL, 1, 5, 3, NULL),
    ('2026-06-05', '08:00', '09:00', 6000.00, 'Carga de ocupación', 6, NULL, 2, 5, 3, NULL),
    -- Viernes 2026-06-05 - Tarde (11)
    ('2026-06-05', '12:00', '13:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-05', '12:00', '13:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-05', '12:00', '13:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-05', '12:00', '13:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-05', '12:00', '13:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    ('2026-06-05', '13:00', '14:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-05', '13:00', '14:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-05', '13:00', '14:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-06-05', '13:00', '14:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-06-05', '13:00', '14:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    ('2026-06-05', '14:00', '15:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    -- Viernes 2026-06-05 - Noche (14)
    ('2026-06-05', '18:00', '19:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-06-05', '18:00', '19:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-06-05', '18:00', '19:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-06-05', '18:00', '19:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    ('2026-06-05', '18:00', '19:00', 4500.00, 'Carga de ocupación', 12, NULL, 5, 5, 3, NULL),
    ('2026-06-05', '19:00', '20:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-06-05', '19:00', '20:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-06-05', '19:00', '20:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    ('2026-06-05', '19:00', '20:00', 4000.00, 'Carga de ocupación', 6, NULL, 4, 5, 3, NULL),
    ('2026-06-05', '19:00', '20:00', 4500.00, 'Carga de ocupación', 7, NULL, 5, 5, 3, NULL),
    ('2026-06-05', '20:00', '21:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-06-05', '20:00', '21:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-06-05', '20:00', '21:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-06-05', '20:00', '21:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    -- Sábado 2026-06-06 - Mañana (5)
    ('2026-06-06', '08:00', '09:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-06', '08:00', '09:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-06', '08:00', '09:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-06-06', '08:00', '09:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-06-06', '08:00', '09:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    -- Sábado 2026-06-06 - Tarde (15)
    ('2026-06-06', '12:00', '13:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-06', '12:00', '13:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-06', '12:00', '13:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-06', '12:00', '13:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-06', '12:00', '13:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    ('2026-06-06', '13:00', '14:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-06', '13:00', '14:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-06', '13:00', '14:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-06-06', '13:00', '14:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-06-06', '13:00', '14:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    ('2026-06-06', '14:00', '15:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-06', '14:00', '15:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-06', '14:00', '15:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-06', '14:00', '15:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-06', '14:00', '15:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    -- Sábado 2026-06-06 - Noche (15)
    ('2026-06-06', '18:00', '19:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-06', '18:00', '19:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-06', '18:00', '19:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-06-06', '18:00', '19:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-06-06', '18:00', '19:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    ('2026-06-06', '19:00', '20:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-06', '19:00', '20:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-06', '19:00', '20:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-06', '19:00', '20:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-06', '19:00', '20:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    ('2026-06-06', '20:00', '21:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-06', '20:00', '21:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-06', '20:00', '21:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-06-06', '20:00', '21:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-06-06', '20:00', '21:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    -- Domingo 2026-06-07 - Mañana (7)
    ('2026-06-07', '08:00', '09:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-07', '08:00', '09:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-07', '08:00', '09:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-07', '08:00', '09:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-07', '08:00', '09:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    ('2026-06-07', '09:00', '10:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-07', '09:00', '10:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    -- Domingo 2026-06-07 - Tarde (9)
    ('2026-06-07', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-06-07', '12:00', '13:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    ('2026-06-07', '12:00', '13:00', 3500.00, 'Carga de ocupación', 6, NULL, 3, 5, 3, NULL),
    ('2026-06-07', '12:00', '13:00', 4000.00, 'Carga de ocupación', 7, NULL, 4, 5, 3, NULL),
    ('2026-06-07', '12:00', '13:00', 4500.00, 'Carga de ocupación', 8, NULL, 5, 5, 3, NULL),
    ('2026-06-07', '13:00', '14:00', 6000.00, 'Carga de ocupación', 9, NULL, 1, 5, 3, NULL),
    ('2026-06-07', '13:00', '14:00', 6000.00, 'Carga de ocupación', 10, NULL, 2, 5, 3, NULL),
    ('2026-06-07', '13:00', '14:00', 3500.00, 'Carga de ocupación', 11, NULL, 3, 5, 3, NULL),
    ('2026-06-07', '13:00', '14:00', 4000.00, 'Carga de ocupación', 12, NULL, 4, 5, 3, NULL),
    -- Domingo 2026-06-07 - Noche (10)
    ('2026-06-07', '18:00', '19:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-06-07', '18:00', '19:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-06-07', '18:00', '19:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    ('2026-06-07', '18:00', '19:00', 4000.00, 'Carga de ocupación', 6, NULL, 4, 5, 3, NULL),
    ('2026-06-07', '18:00', '19:00', 4500.00, 'Carga de ocupación', 7, NULL, 5, 5, 3, NULL),
    ('2026-06-07', '19:00', '20:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-06-07', '19:00', '20:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-06-07', '19:00', '20:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-06-07', '19:00', '20:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    ('2026-06-07', '19:00', '20:00', 4500.00, 'Carga de ocupación', 12, NULL, 5, 5, 3, NULL),
    -- ===== SEMANA 3 =====
    -- Lunes 2026-06-08 - Mañana (1)
    ('2026-06-08', '08:00', '09:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    -- Lunes 2026-06-08 - Tarde (3)
    ('2026-06-08', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-06-08', '12:00', '13:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    ('2026-06-08', '12:00', '13:00', 3500.00, 'Carga de ocupación', 6, NULL, 3, 5, 3, NULL),
    -- Lunes 2026-06-08 - Noche (5)
    ('2026-06-08', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-08', '18:00', '19:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-08', '18:00', '19:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-08', '18:00', '19:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-08', '18:00', '19:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL),
    -- Martes 2026-06-09 - Tarde (3)
    ('2026-06-09', '12:00', '13:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-09', '12:00', '13:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-09', '12:00', '13:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    -- Martes 2026-06-09 - Noche (5)
    ('2026-06-09', '18:00', '19:00', 6000.00, 'Carga de ocupación', 5, NULL, 1, 5, 3, NULL),
    ('2026-06-09', '18:00', '19:00', 6000.00, 'Carga de ocupación', 6, NULL, 2, 5, 3, NULL),
    ('2026-06-09', '18:00', '19:00', 3500.00, 'Carga de ocupación', 7, NULL, 3, 5, 3, NULL),
    ('2026-06-09', '18:00', '19:00', 4000.00, 'Carga de ocupación', 8, NULL, 4, 5, 3, NULL),
    ('2026-06-09', '18:00', '19:00', 4500.00, 'Carga de ocupación', 9, NULL, 5, 5, 3, NULL),
    -- Miércoles 2026-06-10 - Mañana (1)
    ('2026-06-10', '08:00', '09:00', 6000.00, 'Carga de ocupación', 10, NULL, 1, 5, 3, NULL),
    -- Miércoles 2026-06-10 - Tarde (4)
    ('2026-06-10', '12:00', '13:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-10', '12:00', '13:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-10', '12:00', '13:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    ('2026-06-10', '12:00', '13:00', 4000.00, 'Carga de ocupación', 14, NULL, 4, 5, 3, NULL),
    -- Miércoles 2026-06-10 - Noche (5)
    ('2026-06-10', '18:00', '19:00', 6000.00, 'Carga de ocupación', 5, NULL, 1, 5, 3, NULL),
    ('2026-06-10', '18:00', '19:00', 6000.00, 'Carga de ocupación', 6, NULL, 2, 5, 3, NULL),
    ('2026-06-10', '18:00', '19:00', 3500.00, 'Carga de ocupación', 7, NULL, 3, 5, 3, NULL),
    ('2026-06-10', '18:00', '19:00', 4000.00, 'Carga de ocupación', 8, NULL, 4, 5, 3, NULL),
    ('2026-06-10', '18:00', '19:00', 4500.00, 'Carga de ocupación', 9, NULL, 5, 5, 3, NULL),
    -- Jueves 2026-06-11 - Mañana (1)
    ('2026-06-11', '08:00', '09:00', 6000.00, 'Carga de ocupación', 10, NULL, 1, 5, 3, NULL),
    -- Jueves 2026-06-11 - Tarde (5)
    ('2026-06-11', '12:00', '13:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-11', '12:00', '13:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-11', '12:00', '13:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    ('2026-06-11', '12:00', '13:00', 4000.00, 'Carga de ocupación', 14, NULL, 4, 5, 3, NULL),
    ('2026-06-11', '12:00', '13:00', 4500.00, 'Carga de ocupación', 5, NULL, 5, 5, 3, NULL),
    -- Jueves 2026-06-11 - Noche (8)
    ('2026-06-11', '18:00', '19:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-11', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-11', '18:00', '19:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-11', '18:00', '19:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    ('2026-06-11', '18:00', '19:00', 4500.00, 'Carga de ocupación', 10, NULL, 5, 5, 3, NULL),
    ('2026-06-11', '19:00', '20:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-11', '19:00', '20:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-11', '19:00', '20:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    -- Viernes 2026-06-12 - Mañana (2)
    ('2026-06-12', '08:00', '09:00', 6000.00, 'Carga de ocupación', 14, NULL, 1, 5, 3, NULL),
    ('2026-06-12', '08:00', '09:00', 6000.00, 'Carga de ocupación', 5, NULL, 2, 5, 3, NULL),
    -- Viernes 2026-06-12 - Tarde (10)
    ('2026-06-12', '12:00', '13:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-12', '12:00', '13:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-12', '12:00', '13:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-12', '12:00', '13:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    ('2026-06-12', '12:00', '13:00', 4500.00, 'Carga de ocupación', 10, NULL, 5, 5, 3, NULL),
    ('2026-06-12', '13:00', '14:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-12', '13:00', '14:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-12', '13:00', '14:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    ('2026-06-12', '13:00', '14:00', 4000.00, 'Carga de ocupación', 14, NULL, 4, 5, 3, NULL),
    ('2026-06-12', '13:00', '14:00', 4500.00, 'Carga de ocupación', 5, NULL, 5, 5, 3, NULL),
    -- Viernes 2026-06-12 - Noche (15)
    ('2026-06-12', '18:00', '19:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-12', '18:00', '19:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-12', '18:00', '19:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-12', '18:00', '19:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    ('2026-06-12', '18:00', '19:00', 4500.00, 'Carga de ocupación', 10, NULL, 5, 5, 3, NULL),
    ('2026-06-12', '19:00', '20:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-12', '19:00', '20:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-12', '19:00', '20:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    ('2026-06-12', '19:00', '20:00', 4000.00, 'Carga de ocupación', 14, NULL, 4, 5, 3, NULL),
    ('2026-06-12', '19:00', '20:00', 4500.00, 'Carga de ocupación', 5, NULL, 5, 5, 3, NULL),
    ('2026-06-12', '20:00', '21:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-12', '20:00', '21:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-12', '20:00', '21:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-12', '20:00', '21:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    ('2026-06-12', '20:00', '21:00', 4500.00, 'Carga de ocupación', 10, NULL, 5, 5, 3, NULL),
    -- Sábado 2026-06-13 - Mañana (5)
    ('2026-06-13', '08:00', '09:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-13', '08:00', '09:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-13', '08:00', '09:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    ('2026-06-13', '08:00', '09:00', 4000.00, 'Carga de ocupación', 14, NULL, 4, 5, 3, NULL),
    ('2026-06-13', '08:00', '09:00', 4500.00, 'Carga de ocupación', 5, NULL, 5, 5, 3, NULL),
    -- Sábado 2026-06-13 - Tarde (14)
    ('2026-06-13', '12:00', '13:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-13', '12:00', '13:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-13', '12:00', '13:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-13', '12:00', '13:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    ('2026-06-13', '12:00', '13:00', 4500.00, 'Carga de ocupación', 10, NULL, 5, 5, 3, NULL),
    ('2026-06-13', '13:00', '14:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-13', '13:00', '14:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    ('2026-06-13', '13:00', '14:00', 3500.00, 'Carga de ocupación', 13, NULL, 3, 5, 3, NULL),
    ('2026-06-13', '13:00', '14:00', 4000.00, 'Carga de ocupación', 14, NULL, 4, 5, 3, NULL),
    ('2026-06-13', '13:00', '14:00', 4500.00, 'Carga de ocupación', 5, NULL, 5, 5, 3, NULL),
    ('2026-06-13', '14:00', '15:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-13', '14:00', '15:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-13', '14:00', '15:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-13', '14:00', '15:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    -- Sábado 2026-06-13 - Noche (16)
    ('2026-06-13', '18:00', '19:00', 6000.00, 'Carga de ocupación', 10, NULL, 1, 5, 3, NULL),
    ('2026-06-13', '18:00', '19:00', 6000.00, 'Carga de ocupación', 11, NULL, 2, 5, 3, NULL),
    ('2026-06-13', '18:00', '19:00', 3500.00, 'Carga de ocupación', 12, NULL, 3, 5, 3, NULL),
    ('2026-06-13', '18:00', '19:00', 4000.00, 'Carga de ocupación', 13, NULL, 4, 5, 3, NULL),
    ('2026-06-13', '18:00', '19:00', 4500.00, 'Carga de ocupación', 14, NULL, 5, 5, 3, NULL),
    ('2026-06-13', '19:00', '20:00', 6000.00, 'Carga de ocupación', 5, NULL, 1, 5, 3, NULL),
    ('2026-06-13', '19:00', '20:00', 6000.00, 'Carga de ocupación', 6, NULL, 2, 5, 3, NULL),
    ('2026-06-13', '19:00', '20:00', 3500.00, 'Carga de ocupación', 7, NULL, 3, 5, 3, NULL),
    ('2026-06-13', '19:00', '20:00', 4000.00, 'Carga de ocupación', 8, NULL, 4, 5, 3, NULL),
    ('2026-06-13', '19:00', '20:00', 4500.00, 'Carga de ocupación', 9, NULL, 5, 5, 3, NULL),
    ('2026-06-13', '20:00', '21:00', 6000.00, 'Carga de ocupación', 10, NULL, 1, 5, 3, NULL),
    ('2026-06-13', '20:00', '21:00', 6000.00, 'Carga de ocupación', 11, NULL, 2, 5, 3, NULL),
    ('2026-06-13', '20:00', '21:00', 3500.00, 'Carga de ocupación', 12, NULL, 3, 5, 3, NULL),
    ('2026-06-13', '20:00', '21:00', 4000.00, 'Carga de ocupación', 13, NULL, 4, 5, 3, NULL),
    ('2026-06-13', '20:00', '21:00', 4500.00, 'Carga de ocupación', 14, NULL, 5, 5, 3, NULL),
    ('2026-06-13', '21:00', '22:00', 6000.00, 'Carga de ocupación', 5, NULL, 1, 5, 3, NULL),
    -- Domingo 2026-06-14 - Mañana (7)
    ('2026-06-14', '08:00', '09:00', 6000.00, 'Carga de ocupación', 6, NULL, 1, 5, 3, NULL),
    ('2026-06-14', '08:00', '09:00', 6000.00, 'Carga de ocupación', 7, NULL, 2, 5, 3, NULL),
    ('2026-06-14', '08:00', '09:00', 3500.00, 'Carga de ocupación', 8, NULL, 3, 5, 3, NULL),
    ('2026-06-14', '08:00', '09:00', 4000.00, 'Carga de ocupación', 9, NULL, 4, 5, 3, NULL),
    ('2026-06-14', '08:00', '09:00', 4500.00, 'Carga de ocupación', 10, NULL, 5, 5, 3, NULL),
    ('2026-06-14', '09:00', '10:00', 6000.00, 'Carga de ocupación', 11, NULL, 1, 5, 3, NULL),
    ('2026-06-14', '09:00', '10:00', 6000.00, 'Carga de ocupación', 12, NULL, 2, 5, 3, NULL),
    -- Domingo 2026-06-14 - Tarde (9)
    ('2026-06-14', '12:00', '13:00', 6000.00, 'Carga de ocupación', 13, NULL, 1, 5, 3, NULL),
    ('2026-06-14', '12:00', '13:00', 6000.00, 'Carga de ocupación', 14, NULL, 2, 5, 3, NULL),
    ('2026-06-14', '12:00', '13:00', 3500.00, 'Carga de ocupación', 5, NULL, 3, 5, 3, NULL),
    ('2026-06-14', '12:00', '13:00', 4000.00, 'Carga de ocupación', 6, NULL, 4, 5, 3, NULL),
    ('2026-06-14', '12:00', '13:00', 4500.00, 'Carga de ocupación', 7, NULL, 5, 5, 3, NULL),
    ('2026-06-14', '13:00', '14:00', 6000.00, 'Carga de ocupación', 8, NULL, 1, 5, 3, NULL),
    ('2026-06-14', '13:00', '14:00', 6000.00, 'Carga de ocupación', 9, NULL, 2, 5, 3, NULL),
    ('2026-06-14', '13:00', '14:00', 3500.00, 'Carga de ocupación', 10, NULL, 3, 5, 3, NULL),
    ('2026-06-14', '13:00', '14:00', 4000.00, 'Carga de ocupación', 11, NULL, 4, 5, 3, NULL),
    -- Domingo 2026-06-14 - Noche (10)
    ('2026-06-14', '18:00', '19:00', 6000.00, 'Carga de ocupación', 12, NULL, 1, 5, 3, NULL),
    ('2026-06-14', '18:00', '19:00', 6000.00, 'Carga de ocupación', 13, NULL, 2, 5, 3, NULL),
    ('2026-06-14', '18:00', '19:00', 3500.00, 'Carga de ocupación', 14, NULL, 3, 5, 3, NULL),
    ('2026-06-14', '18:00', '19:00', 4000.00, 'Carga de ocupación', 5, NULL, 4, 5, 3, NULL),
    ('2026-06-14', '18:00', '19:00', 4500.00, 'Carga de ocupación', 6, NULL, 5, 5, 3, NULL),
    ('2026-06-14', '19:00', '20:00', 6000.00, 'Carga de ocupación', 7, NULL, 1, 5, 3, NULL),
    ('2026-06-14', '19:00', '20:00', 6000.00, 'Carga de ocupación', 8, NULL, 2, 5, 3, NULL),
    ('2026-06-14', '19:00', '20:00', 3500.00, 'Carga de ocupación', 9, NULL, 3, 5, 3, NULL),
    ('2026-06-14', '19:00', '20:00', 4000.00, 'Carga de ocupación', 10, NULL, 4, 5, 3, NULL),
    ('2026-06-14', '19:00', '20:00', 4500.00, 'Carga de ocupación', 11, NULL, 5, 5, 3, NULL);
GO


-- -------------------------------------------------------
-- PAGOS
-- BLOQUE 1 — pagos de las reservas narrativas (señados, pagados, reembolso).
-- IDFormaPago: 1=Efectivo | 2=Transferencia | 3=Débito | 4=Crédito | 5=MercadoPago
-- -------------------------------------------------------
INSERT INTO Pagos (Monto, FechaHora, IDReserva, IDFormaPago)
VALUES
    (5400.00, '2026-05-26 09:05', 1, 1),
    (3375.00, '2026-06-02 19:05', 2, 5),
    (3600.00, '2026-05-27 13:05', 3, 2),
    (3150.00, '2026-05-28 20:05', 4, 4),
    (5400.00, '2026-05-29 15:05', 5, 3),
    (3600.00, '2026-06-03 13:05', 6, 1),
    (3375.00, '2026-06-05 21:05', 7, 5),
    (4500.00, '2026-06-09 09:05', 8, 2),
    (4500.00, '2026-05-30 09:05', 9, 4),
    (4000.00, '2026-05-31 14:05', 10, 3),
    (6000.00, '2026-06-06 22:05', 11, 1),
    (6000.00, '2026-06-01 09:05', 12, 5),
    (6000.00, '2026-06-07 21:05', 13, 2),
    (6000.00, '2026-06-10 20:05', 14, 4),
    (6000.00, '2026-06-11 09:05', 15, 3),
    (6000.00, '2026-06-12 15:05', 16, 1),
    (4500.00, '2026-06-13 15:05', 17, 5),
    (6000.00, '2026-06-14 21:05', 18, 2),
    (6000.00, '2026-06-01 10:00', 19, 2),  -- pago original
    (6000.00, '2026-06-04 18:00', 19, 2),  -- reembolso
    (6000.00, '2026-06-08 20:05', 20, 3),
    (2000.00, '2026-06-15 12:00', 21, 1),  -- seña
    (2000.00, '2026-06-15 12:00', 22, 5),  -- seña
    (2000.00, '2026-06-15 12:00', 23, 2),  -- seña
    (2000.00, '2026-06-15 12:00', 24, 4)  -- seña
GO


-- BLOQUE 2 — un pago por cada reserva de carga: monto completo, en efectivo.
-- Se usa INSERT ... SELECT para no escribir cientos de pagos a mano: toma las
-- reservas de carga (filtradas por su Observaciones) y les crea el pago.
INSERT INTO Pagos (Monto, FechaHora, IDReserva, IDFormaPago)
SELECT PrecioTotal, CAST(Fecha AS DATETIME), IDReserva, 1
FROM Reservas WHERE Observaciones = 'Carga de ocupación';
GO

GO
-- ----------------------------------------------------------------------
-- (siguiente script)
-- ----------------------------------------------------------------------

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

GO
-- ----------------------------------------------------------------------
-- (siguiente script)
-- ----------------------------------------------------------------------

-- =========================================
-- SP: sp_CanjearCupon
-- Autor: Tomas Oliveres
-- Aplica un cupón de fidelidad a una reserva validando todas las
-- reglas de negocio (estado, titularidad, vigencia y límite de usos)
-- dentro de una transacción: pasa todo o no se aplica nada.
-- =========================================

USE BBDD2_TPI_GRUPO45;
GO

CREATE OR ALTER PROCEDURE sp_CanjearCupon
    @IDReserva    INT,
    @CodigoCupon  VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Variables de la reserva.
        DECLARE @IDClienteReserva INT,
            @PrecioActual DECIMAL(10,2),
            @IDCuponEnReserva INT;

        -- Variables del cupón.
        DECLARE @IDCupon INT,
            @IDUsuarioCupon INT,
            @IDEstadoCupon INT,
            @IDTipoDescuento INT,
            @ValorDescuento DECIMAL(10,2),
            @ValidoDesde DATE,
            @ValidoHasta DATE,
            @LimiteUsos INT,
            @UsosActuales INT;

        DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

        -- 1) Traer la reserva.
        SELECT @IDClienteReserva = IDUsuario_Cliente,
            @PrecioActual = PrecioTotal,
            @IDCuponEnReserva = IDCupon
        FROM Reservas
        WHERE IDReserva = @IDReserva;

        IF @IDClienteReserva IS NULL
            THROW 50001, 'La reserva no existe.', 1;

        IF @IDCuponEnReserva IS NOT NULL
            THROW 50002, 'La reserva ya tiene un cupón aplicado.', 1;

        -- 2) Traer el cupón por su código.
        SELECT @IDCupon = IDCupon,
            @IDUsuarioCupon = IDUsuario,
            @IDEstadoCupon = IDEstadoCupon,
            @IDTipoDescuento = IDTipoDescuento,
            @ValorDescuento = ValorDescuento,
            @ValidoDesde = ValidoDesde,
            @ValidoHasta = ValidoHasta,
            @LimiteUsos = LimiteUsos,
            @UsosActuales = UsosActuales
        FROM Cupones
        WHERE Codigo = @CodigoCupon;

        -- 3) Validaciones de negocio.
        IF @IDCupon IS NULL
            THROW 50003, 'El cupón no existe.', 1;

        IF @IDEstadoCupon <> 1   -- 1 = Activo
            THROW 50004, 'El cupón no está activo (puede estar canjeado, vencido, agotado o anulado).', 1;

        IF @IDUsuarioCupon <> @IDClienteReserva
            THROW 50005, 'El cupón no pertenece al cliente de la reserva.', 1;

        IF (@ValidoDesde IS NOT NULL AND @Hoy < @ValidoDesde)
           OR (@ValidoHasta IS NOT NULL AND @Hoy > @ValidoHasta)
            THROW 50006, 'El cupón está fuera de su período de validez.', 1;

        IF (@LimiteUsos IS NOT NULL AND @UsosActuales >= @LimiteUsos)
            THROW 50007, 'El cupón ya alcanzó su límite de usos.', 1;

        -- 4) Calcular el nuevo precio según el tipo de descuento.
        DECLARE @NuevoPrecio DECIMAL(10,2);

        IF @IDTipoDescuento = 2                 -- Reserva gratis
            SET @NuevoPrecio = 0;
        ELSE IF @IDTipoDescuento = 1            -- Porcentaje
            SET @NuevoPrecio = @PrecioActual - (@PrecioActual * @ValorDescuento / 100.0);
        ELSE
            SET @NuevoPrecio = @PrecioActual;

        IF @NuevoPrecio < 0
            SET @NuevoPrecio = 0;

        -- 5) Aplicar el cupón a la reserva.
        UPDATE Reservas
        SET PrecioTotal = @NuevoPrecio,
            IDCupon = @IDCupon
        WHERE IDReserva = @IDReserva;

        -- 6) Registrar el uso y cerrar el cupón si llegó al límite
        --    (Canjeado si era de un solo uso, Agotado si era multiuso).
        UPDATE Cupones
        SET UsosActuales = UsosActuales + 1,
            IDEstadoCupon = CASE
                WHEN @LimiteUsos IS NOT NULL AND (@UsosActuales + 1) >= @LimiteUsos
                    THEN CASE WHEN @LimiteUsos = 1 THEN 2 ELSE 4 END
                ELSE IDEstadoCupon
            END
        WHERE IDCupon = @IDCupon;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;   -- propaga el error original al que llamó al SP
    END CATCH
END;
GO

-- Prueba manual
-- EXEC sp_CanjearCupon @IDReserva = 21, @CodigoCupon = 'FID-LUC-15';

GO
-- ----------------------------------------------------------------------
-- (siguiente script)
-- ----------------------------------------------------------------------

-- =========================================
-- TRIGGER: Sincronizar estado de pago
-- Autor: Tomas Oliveres
-- Recalcula el estado de pago de la reserva al registrarse un pago.
-- Escrito pensando en que inserted puede traer varias filas.
-- No toca reservas Canceladas.
-- "Señado" exige alcanzar la MontoSena de la cancha: un pago menor a la seña
-- deja la reserva en Pendiente, NO en Señado. Si la cancha no define seña
-- (MontoSena NULL), no hay umbral que alcanzar: la reserva queda Pendiente
-- hasta cubrir el total (pasa directo a Pagado).
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
    SET r.IDEstadoPago = CASE  -- La subconsulta suma TODOS los pagos de cada reserva y decide el estado
            WHEN ISNULL(pg.Pagado, 0) >= r.PrecioTotal
                THEN 3   -- Pagado: cubrió el total
            WHEN c.MontoSena IS NOT NULL AND pg.Pagado >= c.MontoSena
                THEN 2   -- Señado: solo si hay seña definida y el pago la alcanzó
            WHEN ISNULL(pg.Pagado, 0) > 0
                THEN 1   -- pagó algo pero no llega a la seña (o no hay seña): sigue Pendiente
            ELSE r.IDEstadoPago
        END
    FROM Reservas r
    INNER JOIN inserted i ON i.IDReserva = r.IDReserva
    WHERE r.IDEstado <> 3;   -- no tocar Canceladas
END;
GO

-- Uso:  INSERT INTO Pagos (Monto, IDReserva, IDFormaPago) VALUES (2000, 25, 1);
