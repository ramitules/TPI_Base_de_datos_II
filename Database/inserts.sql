CREATE DATABASE GestionGimnasio
Collate Latin1_General_CI_AI
GO

USE GestionGimnasio;
GO

CREATE TABLE SuscripcionesEstados (  -- Activa, vencida, etc.
	IdSuscripcionEstado  TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Nombre 	             NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Roles (  -- Entrenador, Administrativo, etc.
	IdRol 	TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Rol     NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE Planes (  -- Los tipos de suscripcion que ofrece el gimnasio
	IdPlan 			SMALLINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Nombre 			NVARCHAR(150) NOT NULL UNIQUE,
	PrecioMensual 	DECIMAL(8,2) NOT NULL DEFAULT 0,
	DuracionDias 	SMALLINT DEFAULT 0
)
GO

CREATE TABLE GruposMusculares (  -- Pecho, biceps, etc.
	IdGrupoMuscular TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Nombre 	        NVARCHAR(100) NOT NULL
)
GO

CREATE TABLE Usuarios (  -- Almacena tanto a los clientes como al staff (entrenadores, administradores)
	IdUsuario 			INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Nombre 				NVARCHAR(155) NOT NULL,
	Apellido	 		NVARCHAR(155) NOT NULL,
	Email 				NVARCHAR(150) NOT NULL,
	FechaNacimiento 	DATE,
	PesoCorporalKG 		DECIMAL(5,2) NOT NULL DEFAULT 0,
	IdRol 				TINYINT NOT NULL,
	FechaIngreso 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(IdRol) REFERENCES Roles(IdRol)
)
GO

CREATE TABLE Ejercicios (  -- Un catalogo estandarizado de movimientos
	IdEjercicio 	INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Nombre 			NVARCHAR(200) NOT NULL,
	IdGrupoMuscular	TINYINT,
	FOREIGN KEY(IdGrupoMuscular) REFERENCES GruposMusculares(IdGrupoMuscular)
)
GO

CREATE TABLE Rutinas (  -- Plantillas de entrenamiento que un entrenador puede asignar o que el usuario arma (Ej: Empuje/Tiron/Piernas)
	IdRutina 		INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Nombre 			NVARCHAR(150),
	IdUsuario 		INTEGER,
	FechaCreacion 	DATETIME,
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuario)
)
GO

CREATE TABLE Suscripciones (  -- Tabla puente (con datos extra) que relaciona a los usuarios con los planes a lo largo del tiempo
	IdSuscripcion 		INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
	IdUsuario 			INTEGER NOT NULL,
	IdPlan 				SMALLINT NOT NULL,
	IdSuscripcionEstado TINYINT NOT NULL,
	FechaInicio			DATE NOT NULL,
	FechaVencimiento 	DATE NOT NULL,
	FOREIGN KEY(IdSuscripcionEstado) REFERENCES SuscripcionesEstados(IdSuscripcionEstado),
	FOREIGN KEY(IdPlan) REFERENCES Planes(IdPlan),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuario)
)
GO


CREATE TABLE RutinaEjercicios (  -- Asigna los ejercicios específicos a una plantilla de rutina
	IdRutinaEjercicio 		INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
	IdEjercicio 			INTEGER NOT NULL,
	ObjetivoSeries 			SMALLINT DEFAULT 1,
	ObjetivoRepeticiones 	SMALLINT DEFAULT 1,
	OrdenEjercicio 			TINYINT DEFAULT 1,
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(IdEjercicio)
)
GO

CREATE TABLE SesionesEntrenamiento (  -- Registra el momento exacto en que un usuario pisa el gimnasio y entrena
	IdSesionEntrenamiento INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
	IdUsuario 		      INTEGER NOT NULL,
	IdRutina 		      INTEGER,
	FechaHoraInicio       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FechaHoraFin 	      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuario),
	FOREIGN KEY(IdRutina) REFERENCES Rutinas(IdRutina)
)
GO

CREATE TABLE SeriesCompletadas (  -- Guarda cada serie efectiva que hace el usuario. Ideal analisis
	IdSerieCompletada 		INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
	IdSesionEntrenamiento 	INTEGER NOT NULL,
	IdEjercicio 			INTEGER NOT NULL,
	PesoLevantadoKG 		SMALLINT NOT NULL DEFAULT 0,
	RepeticionesLogradas 	SMALLINT NOT NULL DEFAULT 0,
	RIR 					TINYINT,
	EsRecordPersonal 		BIT NOT NULL DEFAULT 0,
	FOREIGN KEY(IdSesionEntrenamiento) REFERENCES SesionesEntrenamiento(IdSesionEntrenamiento),
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(IdEjercicio)
)
GO



--DATOS PARA CARGAR EN LAS TABLAS--

INSERT INTO GruposMusculares (Nombre)
VALUES 
('Pecho / Pectorales'),
('Espalda / Dorsales'),
('Piernas / Tren Inferior'),
('Hombros / Deltoides'),
('Brazos (Bíceps/Tríceps)'),
('Core / Abdominales');

INSERT INTO SuscripcionesEstados (Nombre)
VALUES 
('Activa'),
('Vencida'),
('Cancelada');

INSERT INTO Roles (Rol)
VALUES 
('Administrador'),
('Entrenador'),
('Cliente');

INSERT INTO Planes (Nombre, PrecioMensual, DuracionDias)
VALUES 
('Pase Diario', 2500.00, 1),
('Plan Mensual Estándar', 18000.00, 30),
('Plan Mensual Pase Libre', 22000.00, 30),
('Trimestre Promocional', 15000.00, 90),
('Pase Libre Semestral', 13500.00, 180);

INSERT INTO Usuarios (Nombre, Apellido, Email, FechaNacimiento, PesoCorporalKG, IdRol, FechaIngreso)
VALUES 
('Alejandro', 'Rossi', 'alejandro.rossi@email.com', '1988-04-12', 82.50, 1, '2025-01-10 09:00:00'),
('Mariana', 'Fernández', 'mariana.f@email.com', '1992-09-25', 64.20, 2, '2025-02-15 14:30:00'),
('Carlos', 'Mendoza', 'carlos.mendoza@email.com', '1985-11-05', 91.80, 2, '2025-03-01 08:15:00'),
('Sofía', 'Benítez', 'sofia.b@email.com', '1998-07-19', 58.70, 3, '2026-01-05 10:00:00'),
('Lucas', 'Giménez', 'lucas.gimenez@email.com', '1994-02-28', 78.40, 3, '2026-01-12 18:20:00'),
('Florencia', 'Herrera', 'flor.herrera@email.com', '1991-05-14', 61.10, 3, '2026-01-20 11:45:00'),
('Diego', 'Romero', 'diego.romero@email.com', '1990-12-01', 85.30, 3, '2026-02-02 16:00:00'),
('Camila', 'Maidana', 'camila.m@email.com', '2000-03-22', 55.00, 3, '2026-02-10 09:30:00'),
('Martín', 'Silva', 'martin.silva@email.com', '1987-08-30', 95.20, 3, '2026-02-18 20:15:00'),
('Valentina', 'Ríos', 'vale.rios@email.com', '1996-10-10', 67.80, 3, '2026-03-01 07:00:00'),
('Facundo', 'Castro', 'facu.castro@email.com', '1993-01-15', 73.90, 3, '2026-03-05 15:30:00'),
('Agustina', 'Álvarez', 'agus.alvarez@email.com', '1995-06-08', 62.40, 3, '2026-03-12 19:00:00'),
('Gonzalo', 'Pereyra', 'gonza.p@email.com', '1989-11-23', 88.10, 3, '2026-03-20 08:00:00'),
('Natalia', 'Torres', 'natalia.torres@email.com', '1997-04-04', 59.50, 3, '2026-04-02 12:15:00'),
('Joaquín', 'Domínguez', 'joaco.d@email.com', '1992-02-17', 81.00, 3, '2026-04-10 17:45:00'),
('Elena', 'Acosta', 'elena.acosta@email.com', '1986-07-29', 70.30, 3, '2026-04-18 10:30:00'),
('Bautista', 'Morales', 'bauti.morales@email.com', '2001-09-05', 76.60, 3, '2026-04-25 16:20:00'),
('Victoria', 'Ortega', 'viqui.ortega@email.com', '1994-12-12', 63.80, 3, '2026-05-02 09:00:00'),
('Juan Pablo', 'López', 'juanpi.lopez@email.com', '1991-03-27', 89.40, 3, '2026-05-10 14:00:00'),
('Micaela', 'Núñez', 'mica.nunez@email.com', '1999-05-18', 57.20, 3, '2026-05-15 11:10:00');

INSERT INTO Ejercicios (Nombre, IdGrupoMuscular)
VALUES 
('Press de Banca con Barra', 1),
('Press Inclinado con Mancuernas', 1),
('Aperturas en Polea Alta (Cruces)', 1),

('Dominadas Pronas', 2),
('Remo con Barra', 2),
('Jalón al Pecho en Polea', 2),

('Sentadilla Libre con Barra', 3),
('Prensa de Piernas 45 Grados', 3),
('Sillón de Extensiones de Cuádriceps', 3),
('Peso Muerto Rumano con Mancuernas', 3),

('Press Militar con Barra', 4),
('Vuelos Laterales con Mancuernas', 4),
('Pájaros en Polea (Deltoides Posterior)', 4),

('Curl de Bíceps con Barra W', 5),
('Curl de Bíceps en Banco Scott', 5),
('Extensiones de Tríceps en Polea Alta', 5),
('Fondos en Paralelas para Tríceps', 5),

('Plancha Abdominal Isométrica', 6);

INSERT INTO Rutinas (Nombre, IdUsuario, FechaCreacion)
VALUES 
-- Rutinas generales (IdUsuario es NULL)
('Rutina Fullbody Principiantes', NULL, '2025-01-15 10:00:00'),
('Torso / Pierna Avanzado', NULL, '2025-02-20 11:30:00'),
('Rutina de Fuerza (5x5)', NULL, '2025-03-05 09:15:00'),

-- Rutinas personalizadas (IDs del script de Usuarios)
('Hipertrofia Piernas - Sofía', 4, '2026-01-06 18:00:00'),
('Acondicionamiento General - Lucas', 5, '2026-01-13 19:45:00'),
('Definición / Quema Calórica - Florencia', 6, '2026-01-22 15:30:00'),
('Fuerza Máxima - Diego', 7, '2026-02-03 20:00:00'),
('Rutina Adaptada - Martín', 9, '2026-02-19 10:20:00');

INSERT INTO Suscripciones (IdUsuario, IdPlan, IdSuscripcionEstado, FechaInicio, FechaVencimiento)
VALUES 
(4, 2, 2, '2026-01-05', '2026-02-04'),
(5, 3, 2, '2026-01-12', '2026-02-11'),
(6, 2, 2, '2026-01-20', '2026-02-19'),
(7, 2, 2, '2026-02-02', '2026-03-04'),
(8, 4, 2, '2026-02-10', '2026-05-11'), 
(4, 3, 1, '2026-05-01', '2026-05-31'), 
(5, 3, 1, '2026-05-12', '2026-06-11'), 
(6, 2, 1, '2026-05-05', '2026-06-04'), 
(9, 5, 1, '2026-02-18', '2026-08-17'), 
(10, 2, 1, '2026-04-25', '2026-05-25'),
(11, 3, 1, '2026-05-05', '2026-06-04'), 
(12, 2, 1, '2026-05-12', '2026-06-11'), 
(13, 2, 1, '2026-05-15', '2026-06-14'), 
(14, 1, 2, '2026-04-02', '2026-04-03'),
(15, 1, 2, '2026-04-10', '2026-04-11');



INSERT INTO RutinaEjercicios (IdEjercicio, ObjetivoSeries, ObjetivoRepeticiones, OrdenEjercicio)
VALUES 
(7,  3, 10, 1),
(1,  3, 12, 2),
(6,  3, 10, 3),
(12, 2, 12, 4),
(18, 3, 45, 5),
(1,  4, 8,  1),
(5,  4, 8,  2),
(11, 3, 10, 3),
(14, 3, 12, 4),
(16, 3, 12, 5),
(7,  4, 8,  1),
(8,  3, 12, 2),
(10, 4, 10, 3),
(9,  3, 15, 4),
(7,  5, 5,  1),
(1,  5, 5,  2),
(5,  5, 5,  3);

INSERT INTO SesionesEntrenamiento (IdUsuario, IdRutina, FechaHoraInicio, FechaHoraFin)
VALUES 
(4, 4, '2026-01-08 18:30:00', '2026-01-08 19:45:00'),
(5, 5, '2026-01-15 19:00:00', '2026-01-15 20:15:00'),
(6, 6, '2026-01-25 16:00:00', '2026-01-25 17:00:00'),
(7, 7, '2026-02-05 20:15:00', '2026-02-05 21:45:00'),
(4, 4, '2026-02-12 18:15:00', '2026-02-12 19:30:00'),
(9, 8, '2026-02-22 09:30:00', '2026-02-22 10:45:00'),
(7, 7, '2026-03-02 20:00:00', '2026-03-02 21:30:00'),
(5, NULL, '2026-03-10 19:30:00', '2026-03-10 20:30:00'),
(10, NULL, '2026-04-26 08:00:00', '2026-04-26 09:00:00'),
(4, 1, '2026-05-02 10:00:00', '2026-05-02 11:15:00'),
(11, 2, '2026-05-08 17:00:00', '2026-05-08 18:20:00'),
(12, 2, '2026-05-14 19:15:00', '2026-05-14 20:30:00');

INSERT INTO SeriesCompletadas (IdSesionEntrenamiento, IdEjercicio, PesoLevantadoKG, RepeticionesLogradas, RIR, EsRecordPersonal)
VALUES 
(1, 7, 40, 10, 3, 0), 
(1, 7, 50, 8,  2, 0),
(1, 7, 50, 8,  1, 0),
(1, 7, 55, 6,  0, 1),
(1, 8, 100, 12, 2, 0),
(1, 8, 120, 12, 1, 0),
(1, 8, 130, 10, 0, 1),
(4, 7, 100, 5, 2, 0),
(4, 7, 100, 5, 2, 0),
(4, 7, 105, 5, 1, 0),
(4, 7, 105, 5, 1, 0),
(4, 7, 110, 5, 0, 1),
(4, 1, 80, 5, 2, 0),
(4, 1, 85, 5, 1, 0),
(4, 1, 85, 5, 1, 0),
(4, 1, 90, 4, 0, 0),
(8, 14, 25, 12, 2, 0),
(8, 14, 25, 10, 1, 0),
(8, 14, 30, 8,  0, 0),
(8, 16, 20, 15, 3, 0),
(8, 16, 25, 12, 2, 0),
(8, 16, 25, 12, 1, 0),
(11, 1, 60, 8, 2, 0),
(11, 1, 65, 8, 2, 0),
(11, 1, 70, 8, 1, 0),
(11, 1, 70, 7, 0, 0),
(11, 5, 50, 10, 2, 0),
(11, 5, 55, 10, 1, 0),
(11, 5, 60, 8,  0, 0);

