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
