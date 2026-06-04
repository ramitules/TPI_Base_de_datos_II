CREATE DATABASE GestionGimnasio
Collate Latin1_General_CI_AI
GO

USE GestionGimnasio;
GO

-- Tablas --

CREATE TABLE GruposMusculares (  -- Pecho, biceps, etc.
	IdGruposMusculares	TINYINT NOT NULL IDENTITY(1,1),
	Nombre 				NVARCHAR(100) NOT NULL,
	PRIMARY KEY (IdGruposMusculares)
);
GO

CREATE TABLE SuscripcionesEstados (  -- Activa, vencida, etc.
	IdSuscripcionesEstados	TINYINT NOT NULL IDENTITY(1,1),
	Nombre 					NVARCHAR(50) NOT NULL
	PRIMARY KEY (IdSuscripcionesEstados)
);
GO

CREATE TABLE Roles (  -- Entrenador, Administrativo, etc.
	IdRoles		TINYINT NOT NULL IDENTITY(1,1),
	Nombre 		NVARCHAR(50) NOT NULL
	PRIMARY KEY (IdRoles)
);
GO

CREATE TABLE Planes (  -- Los tipos de suscripcion que ofrece el gimnasio
	IdPlanes		SMALLINT NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(150) NOT NULL UNIQUE,
	PrecioMensual 	DECIMAL(8,2) NOT NULL DEFAULT 0,
	DuracionDias 	SMALLINT DEFAULT 0
	PRIMARY KEY (IdPlanes)
);
GO

CREATE TABLE Usuarios (  -- Almacena tanto a los clientes como al staff (entrenadores, administradores)
	IdUsuarios			INTEGER NOT NULL IDENTITY(1,1),
	Nombre		 		NVARCHAR(70) NOT NULL,
	Apellido	 		NVARCHAR(70) NOT NULL,
	Email 				NVARCHAR(150) NOT NULL UNIQUE,
	FechaNacimiento 	DATE,
	PesoCorporalKG 		DECIMAL(5,2) NOT NULL DEFAULT 0,
	IdRol 				TINYINT NOT NULL,
	FechaIngreso 		DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	Activo				BIT NOT NULL DEFAULT 1
	PRIMARY KEY (IdUsuarios),
	FOREIGN KEY(IdRol) REFERENCES Roles(IdRoles)
);
GO

CREATE TABLE Suscripciones (  -- Tabla puente (con datos extra) que relaciona a los usuarios con los planes a lo largo del tiempo
	IdSuscripciones		INTEGER NOT NULL IDENTITY(1,1),
	IdUsuario 			INTEGER NOT NULL,
	IdPlan 				SMALLINT NOT NULL,
	IdEstado 			TINYINT NOT NULL,
	FechaInicio			DATE NOT NULL,
	FechaVencimiento 	DATE NOT NULL
	PRIMARY KEY (IdSuscripciones),
	FOREIGN KEY(IdEstado) REFERENCES SuscripcionesEstados(IdSuscripcionesEstados),
	FOREIGN KEY(IdPlan) REFERENCES Planes(IdPlanes),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuarios),
	CHECK (FechaVencimiento > FechaInicio),
);
GO

CREATE TABLE Ejercicios (  -- Un catalogo estandarizado de movimientos
	IdEjercicios	INTEGER NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(200) NOT NULL,
	IdGrupoMuscular	TINYINT
	PRIMARY KEY (IdEjercicios),
	FOREIGN KEY(IdGrupoMuscular) REFERENCES GruposMusculares(IdGruposMusculares)
);
GO

CREATE TABLE Rutinas (  -- Plantillas de entrenamiento que un entrenador puede asignar o que el usuario arma (Ej: Empuje/Tiron/Piernas)
	IdRutinas		INTEGER NOT NULL IDENTITY(1,1),
	Nombre 			NVARCHAR(150),
	IdUsuario 		INTEGER, --<-- Si este atributo es NULL, es una rutina general que puede elegir cualquier cliente/entrenador.
	FechaCreacion 	DATETIME,
	Dia				VARCHAR(15), --<-- Si este atributo es NULL, es rutina libre (lo puede realizar cualquier dia de la semana).
	Activo			BIT NOT NULL DEFAULT 1
	PRIMARY KEY (IdRutinas),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuarios)
);
GO

CREATE TABLE RutinaEjercicios (  -- Asigna los ejercicios específicos a una plantilla de rutina
	IdRutinasEjercicios		INTEGER NOT NULL IDENTITY(1,1),
	IdEjercicio 			INTEGER NOT NULL,
	IdRutina				INTEGER NOT NULL,
	ObjetivoKG				INTEGER,
	ObjetivoSeries 			SMALLINT DEFAULT 1,
	ObjetivoRepeticiones 	SMALLINT DEFAULT 1,
	OrdenEjercicio 			TINYINT DEFAULT 1 --<-- Si debe ser el primer ejercicio de la rutina del dia, el ultimo, etc.
	PRIMARY KEY (IdRutinasEjercicios),
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(IdEjercicios),
	FOREIGN KEY(IdRutina) REFERENCES Rutinas(IdRutinas)
);
GO

CREATE TABLE SesionesEntrenamiento (  -- Registra el momento exacto en que un usuario pisa el gimnasio y entrena
	IdSesionesEntrenamiento		INTEGER NOT NULL IDENTITY(1,1),
	IdUsuario 					INTEGER NOT NULL,
	IdRutina 					INTEGER,
	FechaHoraInicio 			DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FechaHoraFin 				DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
	PRIMARY KEY (IdSesionesEntrenamiento),
	FOREIGN KEY(IdUsuario) REFERENCES Usuarios(IdUsuarios),
	FOREIGN KEY(IdRutina) REFERENCES Rutinas(IdRutinas),
	CHECK (FechaHoraFin >= FechaHoraInicio),
);
GO

CREATE TABLE SeriesCompletadas (  -- Guarda cada serie efectiva que hace el usuario. Ideal analisis
	IdSeriesCompletadas		INTEGER NOT NULL IDENTITY(1,1),
	IdSesion 				INTEGER NOT NULL,
	IdEjercicio 			INTEGER NOT NULL,
	PesoLevantadoKG 		SMALLINT NOT NULL DEFAULT 0,
	RepeticionesLogradas 	SMALLINT NOT NULL DEFAULT 0,
	RIR 					TINYINT,  --<-- Reps In Reserve, o repeticiones de reserva que le quedaban antes de llegar al fallo.
	EsRecordPersonal 		BIT NOT NULL DEFAULT 0
	PRIMARY KEY (IdSeriesCompletadas),
	FOREIGN KEY(IdSesion) REFERENCES SesionesEntrenamiento(IdSesionesEntrenamiento),
	FOREIGN KEY(IdEjercicio) REFERENCES Ejercicios(IdEjercicios)
);
GO
