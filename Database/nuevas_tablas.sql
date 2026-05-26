CREATE DATABASE GestionGimnasio
Collate Latin1_General_CI_AI
GO

USE GestionGimnasio;
GO

CREATE TABLE Usuarios (  -- Almacena tanto a los clientes como al staff (entrenadores, administradores)
	IdUsuarios			INTEGER NOT NULL IDENTITY(1,1),
	Nombre		 		NVARCHAR(70) NOT NULL,
	Apellido	 		NVARCHAR(70) NOT NULL,
	Email 				NVARCHAR(150) NOT NULL,
	FechaNacimiento 	DATE,
	PesoCorporalKG 		DECIMAL(5,2) NOT NULL DEFAULT 0,
	IdRol 				TINYINT NOT NULL,
	FechaIngreso 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(IdRol) REFERENCES Roles(ID)
)
GO

CREATE TABLE Planes (  -- Los tipos de suscripcion que ofrece el gimnasio
	IdPlanes		SMALLINT NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(150) NOT NULL UNIQUE,
	PrecioMensual 	DECIMAL(8,2) NOT NULL DEFAULT 0,
	DuracionDias 	SMALLINT DEFAULT 0
)
GO

CREATE TABLE Suscripciones (  -- Tabla puente (con datos extra) que relaciona a los usuarios con los planes a lo largo del tiempo
	IdSuscripciones		INTEGER NOT NULL IDENTITY(1,1),
	IdUsuario 			INTEGER NOT NULL,
	IdPlan 				SMALLINT NOT NULL,
	IdEstado 			TINYINT NOT NULL,
	FechaInicio			DATE NOT NULL,
	FechaVencimiento 	DATE NOT NULL,
	FOREIGN KEY(IdEstado) REFERENCES SuscripcionesEstados(ID),
	FOREIGN KEY(IdPlan) REFERENCES Planes(ID),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(ID)
)
GO

CREATE TABLE Ejercicios (  -- Un catalogo estandarizado de movimientos
	IdEjercicios	INTEGER NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(200) NOT NULL,
	IdGrupoMuscular	TINYINT,
	FOREIGN KEY(IdGrupoMuscular) REFERENCES GruposMusculares(ID)
)
GO

CREATE TABLE Rutinas (  -- Plantillas de entrenamiento que un entrenador puede asignar o que el usuario arma (Ej: Empuje/Tiron/Piernas)
	IdRutinas		INTEGER NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(150),
	IdUsuario 		INTEGER,
	FechaCreacion 	DATETIME,
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(ID)
)
GO

CREATE TABLE RutinaEjercicios (  -- Asigna los ejercicios específicos a una plantilla de rutina
	IdRutinasEjercicios		INTEGER NOT NULL IDENTITY(1,1),
	IdEjercicio 			INTEGER NOT NULL,
	ObjetivoSeries 			SMALLINT DEFAULT 1,
	ObjetivoRepeticiones 	SMALLINT DEFAULT 1,
	OrdenEjercicio 			TINYINT DEFAULT 1,
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(ID)
)
GO

CREATE TABLE SesionesEntrenamiento (  -- Registra el momento exacto en que un usuario pisa el gimnasio y entrena
	IdSesionesEntrenamiento		INTEGER NOT NULL IDENTITY(1,1),
	IdUsuario 					INTEGER NOT NULL,
	IdRutina 					INTEGER,
	FechaHoraInicio 			DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FechaHoraFin 				DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(ID),
	FOREIGN KEY(IdRutina) REFERENCES Rutinas(ID)
)
GO

CREATE TABLE SeriesCompletadas (  -- Guarda cada serie efectiva que hace el usuario. Ideal analisis
	IdSeriesCompletadas		INTEGER NOT NULL IDENTITY(1,1),
	IdSesion 				INTEGER NOT NULL,
	IdEjercicio 			INTEGER NOT NULL,
	PesoLevantadoKG 		SMALLINT NOT NULL DEFAULT 0,
	RepeticionesLogradas 	SMALLINT NOT NULL DEFAULT 0,
	RIR 					TINYINT,
	EsRecordPersonal 		BIT NOT NULL DEFAULT 0,
	FOREIGN KEY(IdSesion) REFERENCES SesionesEntrenamiento(ID),
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(ID)
)
GO

CREATE TABLE GruposMusculares (  -- Pecho, biceps, etc.
	IdGruposMusculares	TINYINT NOT NULL IDENTITY(1,1),
	Nombre 				NVARCHAR(100) NOT NULL
)
GO

CREATE TABLE SuscripcionesEstados (  -- Activa, vencida, etc.
	IdSuscripcionesEstados	TINYINT NOT NULL IDENTITY(1,1),
	Nombre 					NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Roles (  -- Entrenador, Administrativo, etc.
	IdRoles		TINYINT NOT NULL IDENTITY(1,1),
	Rol 		NVARCHAR(50) NOT NULL
);
